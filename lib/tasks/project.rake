namespace :project do
  desc "Refresh projects from pivotal"
  task :refresh => :environment do
    Project.refresh_all
  end
end

