namespace :project do
  desc "Refresh projects from pivotal"
  task :refresh => :environment do
    GC.start
    GC.disable
    Project.refresh_all
    GC.enable
  end
end

