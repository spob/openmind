require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'

class Project < ActiveRecord::Base
  validates_presence_of :pivotal_identifier
  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of :pivotal_identifier, :case_sensitive => false

  has_one :latest_iteration, :class_name => "Iteration", :order => "iteration_number DESC"
  has_many :iterations, :dependent => :destroy, :order => "iteration_number DESC"

  STATUS_PUSHED = "pushed"

  named_scope :active, :conditions => {:active => true}

  has_friendly_id :name, :use_slug => true


  def self.list(page, per_page)
    paginate :page => page, :order => 'name',
             :include => [{:latest_iteration => :latest_estimate}],
             :per_page => per_page
  end

  def self.calculate_project_date
    Date.current
#    minutes = Time.now.in_time_zone(APP_CONFIG['default_user_timezone']).hour * 60 +
#        Time.now.in_time_zone(APP_CONFIG['default_user_timezone']).min
#    if minutes < APP_CONFIG['sprint_standup_time'].to_i
#      the_date = Date.current - 1
#    else
#      the_date = Date.current
#    end
#    the_date
  end

  def self.refresh_all
    Project.active.each do |project|
      project.refresh
      project.save
    end
  end

  def refresh
    # fetch project
    logger.info("Refreshing project #{name}")
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}")
    response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      doc = Hpricot(response.body).at('project')

      self.name = doc.at('name').innerHTML
      self.iteration_length = doc.at('iteration_length').innerHTML
      unless self.new_record?
        fetch_current_iteration

        fetch_notes
      end
    else
      "#{pivotal_identifier} not found in pivotal tracker"
    end

  end

  def update_task_estimate task, iteration
    estimate = task.task_estimates.find_by_as_of(self.calc_iteration_day)
    if estimate
      estimate.update_attributes!(:total_hours => task.total_hours,
                                  :remaining_hours => task.remaining_hours,
                                  :status => task.status)
    else
      task.task_estimates.create!(:as_of => self.calc_iteration_day,
                                  :iteration => iteration,
                                  :total_hours => task.total_hours,
                                  :remaining_hours => task.remaining_hours,
                                  :status => task.status)
    end
  end

  def fetch_notes
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}/stories")
    response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      doc = Hpricot(response.body)
      (doc/"story").each do |story|
        story_id = story.at('id').try(:inner_html)
        name = story.at('name').try(:inner_html)
        story_type = story.at('story_type').try(:inner_html)
        if story_type == 'bug'
          if (name =~ /^D\d+/ix)
            story_number = /\d+/x.match(name).to_s.to_i
            notes = story.at('notes')
            if notes
              story = Story.find_by_pivotal_identifier(story_id)
              if story
                puts "#{story_id} Defect # #{story_number}: #{name}"
                (notes/"note").each do |note|
                  note_id = note.at('id').inner_html.to_i
                  author = note.at('author').inner_html
                  comment = note.at('text').inner_html
                  noted_at = Time.parse(note.at('noted_at').inner_html)
                  if note_id > max_note_id
                    unless StoryNote.find_by_pivotal_identifier(note_id)
                      self.update_attribute(:max_note_id, note_id)
                      puts "#{note_id} #{noted_at} #{author} wrote: #{comment}"
                      story.notes.create!(:pivotal_identifier => note_id, :noted_at => noted_at,
                                          :author => author, :comment => comment, :defect_id => story_number)
                    end
                  end
                end
              end
            end
          end
        end
      end
      ""
    else
      "Response Code: #{response.message} #{response.code}"
    end
  end

  def renumber
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}/stories")
    response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      walk_stories_to_renumber Hpricot(response.body), 'feature'
      walk_stories_to_renumber Hpricot(response.body), 'chore'
      ""
    else
      "Response Code: #{response.message} #{response.code}"
    end
  end

  def walk_stories_to_renumber doc, story_type
    numbered_stories = {}
    unnumbered_stories = {}
    (doc/"story").each do |story|
      id = story.at('id').try(:inner_html)
      name = story.at('name').try(:inner_html)
      stype = story.at('story_type').try(:inner_html)
      if stype == story_type
        if (name =~ /^#{story_prefix(story_type)}\d+/ix)
          num = /\d+/x.match(name).to_s.to_i
          numbered_stories[num] = name
        else
          # un-numbered story
          unnumbered_stories[id] = name
        end
      end
    end
    next_story = next_story_number numbered_stories
    unnumbered_stories.each do |e|
      update_story_name e[0], "#{story_prefix(story_type)}#{next_story}: #{e[1]}"
      next_story = next_story_number(numbered_stories, next_story + 1)
    end
  end


  def fetch_current_iteration
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}/iterations/current")
    response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    if response.code == "200"
      doc = Hpricot(response.body)

      (doc/"iteration").each do |iteration|
        iteration_number = iteration.at('id').inner_html.to_i
#        start_on = iteration.at('start').inner_html.to_date
#        iteration_number = iteration_number - 1 if iteration_number > 1 && Project.calculate_project_date < start_on
        @iteration = self.iterations.by_iteration_number(iteration_number).lock.first

#        puts "#{iteration.at('finish').inner_html} -- #{Date.parse(iteration.at('finish').inner_html)}"
        if @iteration
          @iteration.update_attributes!(:start_on => Date.parse(iteration.at('start').inner_html)+1,
                                        :end_on => Date.parse(iteration.at('finish').inner_html))
          @iteration.stories.each { |s| s.update_attributes!(:status => STATUS_PUSHED, :points => 0) }
        else
          @iteration = self.iterations.create!(:iteration_number => iteration_number,
                                               :start_on => Date.parse(iteration.at('start').inner_html)+1,
                                               :end_on => iteration.at('finish').inner_html)
        end
        (iteration.at('stories')/"story").each do |story|
          pivotal_id = story.at('id').inner_html.to_i
          @story = @iteration.stories.find_by_pivotal_identifier(pivotal_id)
          if @story
            @story.update_attributes!(:points => story.at('estimate').try(:inner_html),
                                      :status => story.at('current_state').inner_html,
                                      :name => story.at('name').inner_html,
                                      :owner => story.at('owned_by').try(:inner_html),
                                      :story_type => story.at('story_type').inner_html)

            @story.tasks.each do |t|
              t.update_attributes!(:status => STATUS_PUSHED, :remaining_hours => 0.0)
            end
          else
            @story = @iteration.stories.create!(:pivotal_identifier => story.at('id').inner_html,
                                                :url => story.at('url').inner_html,
                                                :points => story.at('estimate').try(:inner_html),
                                                :status => story.at('current_state').inner_html,
                                                :name => story.at('name').inner_html,
                                                :owner => story.at('owned_by').try(:inner_html),
                                                :story_type => story.at('story_type').inner_html)
          end

          tasks = story.at('tasks')
          if tasks
            (tasks/"task").each do |task|
              pivotal_id = task.at('id').inner_html.to_i
              @task = @story.tasks.find_by_pivotal_identifier(pivotal_id)
              completed = (task.at('complete').inner_html == "true" || @story.status == "accepted" || @story.status == STATUS_PUSHED)
              total_hours, remaining_hours, description, is_qa = self.parse_hours(task.at('description').inner_html, completed)
#              puts "#{description}, QA: #{is_qa}" if is_qa
              status = calc_status(completed, remaining_hours, total_hours, description)

              if @task
                @task.update_attributes!(:description => description,
                                         :total_hours => total_hours,
                                         :remaining_hours => remaining_hours,
                                         :status => status,
                                         :qa => is_qa)
              else
                @task = @story.tasks.create!(:pivotal_identifier => task.at('id').inner_html,
                                             :description => description,
                                             :total_hours => total_hours,
                                             :remaining_hours => remaining_hours,
                                             :status => status,
                                             :qa => is_qa)
              end
              update_task_estimate(@task, @iteration)
            end
          end

          @story.tasks.pushed.each do |t|
            update_task_estimate(t, @iteration)
          end

          @estimate = @iteration.task_estimates.find_by_as_of(self.calc_iteration_day)
          if @estimate
            @estimate.update_attributes!(:total_hours => self.latest_iteration.total_hours,
                                         :remaining_hours => self.latest_iteration.remaining_hours,
                                         :remaining_qa_hours => self.latest_iteration.remaining_qa_hours,
                                         :points_delivered => self.latest_iteration.total_points_delivered,
                                         :velocity => self.latest_iteration.total_points)
          else
            @day = @iteration.task_estimates.create!(:as_of => self.calc_iteration_day,
                                                     :total_hours => self.latest_iteration.try(:total_hours),
                                                     :remaining_hours => self.latest_iteration.try(:remaining_hours),
                                                     :remaining_qa_hours => self.latest_iteration.try(:remaining_qa_hours),
                                                     :points_delivered => self.latest_iteration.try(:total_points_delivered),
                                                     :velocity => self.latest_iteration.try(:total_points))
          end
        end
        @iteration.stories.pushed.each do |s|
          s.tasks.each do |t|
            t.update_attributes!(:status => STATUS_PUSHED, :remaining_hours => 0.0)
            update_task_estimate(t, @iteration)
          end
        end
        @iteration.update_attributes!(:last_synced_at => Time.now)
      end
      nil
    else
      "#{pivotal_identifier} not found in pivotal tracker"
    end
  end

  def calc_iteration_day the_date=Project.calculate_project_date
    (the_date.cwday > 5 ? the_date - (the_date.cwday - 5) : the_date)
  end

  protected

  def story_prefix story_type
    case story_type
      when 'feature' then
        'S'
      when 'chore' then
        'C'
      else
        'X'
    end
  end

  def update_story_name story_id, name
    body = "<story><name>#{name}</name></story>"
    resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}/stories/#{story_id}")
    http = Net::HTTP.new(resource_uri.host, resource_uri.port)
    req = Net::HTTP::Put.new(resource_uri.path, {'Content-type' => 'application/xml', 'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    http.use_ssl = false
    req.body = body
    response = http.request(req)
    logger.info "RESPONSE: #{response.code} #{response.body} #{response.message}" unless response.code == "200"
    response.code == "200"
  end

  def next_story_number stories, start_at=1
    for x in start_at..3000 do
      return x unless stories.has_key? x
    end
    0
  end

  def calc_status(complete, remaining_hours, total_hours, description)
    status = "Not Started"
    if description =~ /^x/ix
      status = STATUS_PUSHED
    elsif description =~ /^b/ix
      status = "Blocked"
    elsif complete || (total_hours > 0.0 && remaining_hours == 0.0)
      status = "Done"
    elsif total_hours > 0.0 && remaining_hours < total_hours
      status = "In Progress"
    end
    status
  end

  def parse_hours description, completed
    remaining_hours = 0.0
    total_hours = 0.0

    unless /^X\d/ix =~ description
      # does description start with a B (as in blocked)
      desc = description
      if /^B\d/ix =~ description
        desc = description[1..500]
      end
      m1 = /[\d.]*/x.match(desc)
      # Did the match end with a slash?
      if /\// =~ m1.post_match
        remaining_hours = m1[0].to_f if !completed

        m2 = /[\d.]*/x.match(m1.post_match[1..255])
        total_hours = m2[0].to_f
      end
    end

#    puts "TOTAL: #{total_hours} REMAINING: #{remaining_hours} #{description}"
    is_qa = /\[qa\]/xi =~ description
    return total_hours, remaining_hours, description, is_qa.present?
  end

  def validate
    error_msg = self.refresh

    errors.add(:pivotal_identifier, error_msg) unless error_msg.nil?
  end

end
