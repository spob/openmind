require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'

class Project < ActiveRecord::Base
  validates_presence_of :pivotal_identifier
  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :pivotal_identifier, :case_sensitive => false

  has_one :latest_iteration, :class_name => "Iteration", :order => "iteration_number DESC"
  has_many :iterations

  STATUS_PUSHED = "pushed"

  named_scope :active, :conditions => {:active => true}


  def self.list(page, per_page)
    paginate :page     => page, :order => 'name',
             :per_page => per_page
  end

  def self.refresh_all
    Project.active.each { |project| project.refresh }
  end

  def refresh
    # fetch project
    logger.info("Refreshing project #{name}")
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}")
    response     = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      doc                   = Hpricot(response.body).at('project')

      self.name             = doc.at('name').innerHTML
      self.iteration_length = doc.at('iteration_length').innerHTML
      fetch_current_iteration unless self.new_record?
    else
      "#{pivotal_identifier} not found in pivotal tracker"
    end
  end

  def fetch_current_iteration
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}/iterations/current")
    response     = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      doc = Hpricot(response.body)

      (doc/"iteration").each do |iteration|
        iteration_number = iteration.at('id').inner_html.to_i
        @iteration       = self.iterations.by_iteration_number(iteration_number).first

        if @iteration
          @iteration.update_attributes!(:start_on => iteration.at('start').inner_html,
                                        :end_on   => iteration.at('finish').inner_html)
          @iteration.stories.each { |s| s.status = STATUS_PUSHED }
        else
          @iteration = self.iterations.create!(:iteration_number => iteration_number,
                                               :start_on         => iteration.at('start').inner_html,
                                               :end_on           => iteration.at('finish').inner_html)
        end
        (iteration.at('stories')/"story").each do |story|
          pivotal_id = story.at('id').inner_html.to_i
          @story     = @iteration.stories.find_by_pivotal_identifier(pivotal_id)
          if @story
            @story.update_attributes!(:points     => story.at('estimate').try(:inner_html),
                                      :status     => story.at('current_state').inner_html,
                                      :name       => story.at('name').inner_html,
                                      :owner      => story.at('owned_by').try(:inner_html),
                                      :story_type => story.at('story_type').inner_html)

            @story.tasks.each { |t| t.status = STATUS_PUSHED }
          else
            @story = @iteration.stories.create!(:pivotal_identifier => story.at('id').inner_html,
                                                :url                => story.at('url').inner_html,
                                                :points             => story.at('estimate').try(:inner_html),
                                                :status             => story.at('current_state').inner_html,
                                                :name               => story.at('name').inner_html,
                                                :owner              => story.at('owned_by').try(:inner_html),
                                                :story_type         => story.at('story_type').inner_html)
          end

          tasks = story.at('tasks')
          if tasks
            (tasks/"task").each do |task|
              pivotal_id = task.at('id').inner_html.to_i
              @task      = @story.tasks.find_by_pivotal_identifier(pivotal_id)
              completed = task.at('complete').inner_html == "true" || @story.status == "accepted"
              total_hours, remaining_hours, description = parse_hours(task.at('description').inner_html, completed)
              status = calc_status(completed, remaining_hours, total_hours)

              if @task
                @task.update_attributes!(:description     => description,
                                         :total_hours     => total_hours,
                                         :remaining_hours => remaining_hours,
                                         :status          => status)

                @story.tasks.each { |t| t.status = STATUS_PUSHED }
              else
                @task = @story.tasks.create!(:pivotal_identifier => task.at('id').inner_html,
                                             :description        => description,
                                             :total_hours        => total_hours,
                                             :remaining_hours    => remaining_hours,
                                             :status             => status)
              end
              @estimate = @task.task_estimates.find_by_as_of(self.calc_iteration_day)
              if @estimate
                @estimate.update_attributes!(:total_hours     => @task.total_hours,
                                             :remaining_hours => @task.remaining_hours)
              else
                @day = @task.task_estimates.create!(:as_of           => self.calc_iteration_day,
                                                         :iteration       => @iteration,
                                                         :total_hours     => @task.total_hours,
                                                         :remaining_hours => @task.remaining_hours)
              end
            end
          end

          @estimate = @iteration.task_estimates.find_by_as_of(self.calc_iteration_day)
          if @estimate
            @estimate.update_attributes!(:total_hours      => self.latest_iteration.total_hours,
                                         :remaining_hours  => self.latest_iteration.remaining_hours,
                                         :points_delivered => self.latest_iteration.total_points_delivered,
                                         :velocity         => self.latest_iteration.total_points)
          else
            @day = @iteration.task_estimates.create!(:as_of            => self.calc_iteration_day,
                                                     :total_hours      => self.latest_iteration.total_hours,
                                                     :remaining_hours  => self.latest_iteration.remaining_hours,
                                                     :points_delivered => self.latest_iteration.total_points_delivered,
                                                     :velocity         => self.latest_iteration.total_points)
          end
        end
      end
      nil
    else
      "#{pivotal_identifier} not found in pivotal tracker"
    end
  end

  def calc_iteration_day the_date=Date.current
    (the_date.cwday > 5 ? the_date - (the_date.cwday - 5) : the_date)
  end

  protected

  def calc_status(complete, remaining_hours, total_hours)
    status = "Not Started"
    if complete || (total_hours > 0.0 && remaining_hours == 0.0)
      status = "Done"
    elsif total_hours > 0.0 && remaining_hours < total_hours
      status = "In Progress"
    end
    status
  end

  def parse_hours description, completed
    remaining_hours = 0.0
    total_hours     = 0.0

    m1              = /\d*/x.match(description)
    # Did the match end with a slash?
    if /\// =~ m1.post_match
      remaining_hours = m1[0].to_f if !completed

      m2              = /\d*/x.match(m1.post_match[1..255])
      total_hours     = m2[0].to_f
    end

#    puts "TOTAL: #{total_hours} REMAINING: #{remaining_hours}"
    return total_hours, remaining_hours, description
  end

  def validate
    error_msg = self.refresh

    errors.add(:pivotal_identifier, error_msg) unless error_msg.nil?
  end
end
