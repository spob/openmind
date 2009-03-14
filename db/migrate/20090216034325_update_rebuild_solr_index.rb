class UpdateRebuildSolrIndex < ActiveRecord::Migration
  def self.up
    job = RunAtPeriodicJob.find_by_job_and_last_run_at('Topic.rebuild_solr_index; TopicComment.rebuild_solr_index',
      nil)
    unless job.nil?
      job.job = 'SearchUtils.rebuild_indexes'
      job.save!
    end
  end

  def self.down
    job = RunAtPeriodicJob.find_by_job_and_last_run_at('SearchUtils.rebuild_indexes',
      nil)
    unless job.nil?
      job.job = 'Topic.rebuild_solr_index; TopicComment.rebuild_solr_index'
      job.save!
    end
  end
end
