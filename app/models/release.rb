# == Schema Information
# Schema version: 20081021172636
#
# Table name: releases
#
#  id                :integer(4)      not null, primary key
#  version           :string(20)      not null
#  product_id        :integer(4)      not null
#  release_status_id :integer(4)      not null
#  created_at        :datetime        not null
#  lock_version      :integer(4)      default(0)
#  description       :text
#  release_date      :datetime
#  user_release_date :string(255)
#  download_url      :string(300)
#  updated_at        :datetime        not null
#  textiled          :boolean(1)      not null
#

class Release < ActiveRecord::Base
  has_friendly_id :product_release_txt, :use_slug => true
  has_many :ideas,
           :dependent => :destroy,
           :order     => "id ASC"
  has_many :change_logs,
           :class_name => "ReleaseChangeLog",
           :order      => "created_at ASC",
           :dependent  => :destroy
  has_many :unprocessed_change_logs,
           :conditions => ["processed_at is null"],
           :class_name => "ReleaseChangeLog",
           :order      => "id ASC"
  has_many :releases_dependant_on_this_release_dependencies,
           :foreign_key => 'depends_on_id',
           :class_name  => "ReleaseDependency", :dependent => :destroy
  has_many :releases_dependant_on_this_release, :class_name => "Release",
           :finder_sql                                      => 'select r.* from releases r inner join release_dependencies rd on r.id = rd.release_id where rd.depends_on_id = #{id}'
  has_many :release_dependencies, :dependent => :destroy
  has_many :dependent_releases, :source => 'depends_on', :through => :release_dependencies, :order => "releases.product_id ASC"
  belongs_to :product, :counter_cache => true
  belongs_to :release_status, :class_name => "LookupCode",
             :foreign_key                 => "release_status_id"

  named_scope :by_external_release_id,
              lambda { |external_release_id| {:conditions => ['external_release_id like ?', "%#{external_release_id}%"]} }

  validates_presence_of :version
  validates_uniqueness_of :version, :scope => "product_id", :case_sensitive => false
  validates_uniqueness_of :external_release_id, :allow_nil => true
  validates_length_of :version, :maximum => 20

  attr_accessor :maintenance_expires

  xss_terminate :except => [:description]

  before_validation :handle_blank_external_release_id

  named_scope :by_reverse_date, :order => "release_date DESC"


  def self.list(page, product_id, per_page)
    paginate :page       => page,
             :conditions => ['product_id = ?', product_id],
             :order      => 'version',
             :per_page   => per_page
  end

  def self.list_by_status(page, per_page, status_id)
    paginate :page       => page,
             :include    => [:product, :slug, :dependent_releases, :ideas],
             :conditions => ['release_status_id = ?', status_id],
             :order      => "to_days(release_date) * if (release_date < now(),  -1, 1)",
             :per_page   => per_page
  end

  def product_release_txt
    "#{product.name}-#{self.version}"
  end

  def can_delete?
    ideas.empty?
  end

  def self.released_release_statuses
    # strip surrounding ()
    releases = APP_CONFIG['released_release_statuses'].gsub(/^\s*\(|\)\s*$/, "").split(/,/)
    ReleaseStatus.find(:all, :conditions => {:short_name => releases})
  end

  def self.findall_with_product_names
    list = Release.find(:all, :include => :product, :order => 'products.name, release_date')
    for r in list
      r.version = "#{r.product.name}: #{r.version}"
    end
    list
  end

  # Return a release if a release is available
  # Return nil if no update is available
  def update_available(releases)
    unsatisfied_depedendencies = {}
    logger.debug "checking for release #{id} : #{version}"
    latest_release = self.product.latest_release
    return nil, nil if self == latest_release
    logger.debug "not using the latest release"
    # Check if dependencies are satisfied
    unless latest_release.release_dependencies.empty?
      logger.debug "dependencies not empty for latest release #{latest_release.id} #{latest_release.version}"
      # for each product which we are dependent on
      for product in Product.find(:all,
                                  :conditions => ["id in (?)", latest_release.dependent_releases.collect(&:product_id)])
        logger.debug "found one or more dependencies on product #{product.id} #{product.name}"
        # now find all dependent releases for that product
        dependencies = product.releases.find(:all, :conditions => {:id => latest_release.dependent_releases})
        dependencies.each do |d|
          logger.debug "dependent on #{d.id} #{d.version}"
        end
        releases.each do |d|
          logger.debug "releases include #{d.id} #{d.version}"
        end
        logger.debug "intersection empty #{(releases & dependencies)}"
        unsatisfied_depedendencies[product] = dependencies if (releases & dependencies).empty? # dependency not satisfied
      end
    end
    logger.debug "unsatisfied_depedendencies is empty #{unsatisfied_depedendencies.empty?}"
    return latest_release, unsatisfied_depedendencies
  end

  def self.send_change_notifications release_id
    Release.transaction do
      release = Release.find(release_id, :lock => true)
      unless release.unprocessed_change_logs.empty?
        EmailNotifier.deliver_release_change_notifications(release) unless release.product.watchers.empty?
        for change_log in release.unprocessed_change_logs
          change_log.update_attribute(:processed_at, Time.zone.now)
        end
      end
    end
  end

  private

  def handle_blank_external_release_id
    # set blanks to nil
    if self.external_release_id == ""
      self.external_release_id = nil
    end
  end
end
