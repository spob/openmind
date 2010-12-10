require 'rubygems'
require 'hpricot'
require 'net/http'
require 'uri'

class Project < ActiveRecord::Base
  after_validation :update_from_pivotal

  validates_presence_of :pivotal_identifier
  validates_numericality_of :pivotal_identifier, :greater_than_or_equal_to => 1, :only_integer => true, :allow_nil => true
  validates_uniqueness_of   :pivotal_identifier, :case_sensitive => false

  def self.list(page, per_page)
    paginate :page     => page, :order => 'name',
             :per_page => per_page
  end

  def refresh
    resource_uri     = URI.parse("http://www.pivotaltracker.com/services/v3/projects/#{pivotal_identifier}")
    response         = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
      http.get(resource_uri.path, {'X-TrackerToken' => APP_CONFIG['pivotal_api_token']})
    end

    doc              = Hpricot(response.body).at('project')

    self.name             = doc.at('name').innerHTML
    self.iteration_length = doc.at('iteration_length').innerHTML
  end

  private

  def update_from_pivotal
    self.refresh
  end
end
