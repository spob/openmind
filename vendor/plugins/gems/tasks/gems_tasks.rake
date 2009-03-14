namespace :gems do
  task :freeze do
    raise "No gem specified, specify one with GEM=gem_name" unless gem_name = ENV['GEM']

    require 'rubygems'
    require 'rubygems/command_manager'
    
    Gem.manage_gems
    gem = (version = ENV['VERSION']) ?
      Gem.cache.search(gem_name, "= #{version}").first :
      Gem.cache.search(gem_name).sort_by { |g| g.version }.last
    
    version ||= gem.version.version rescue nil
    
    unless gem && path = Gem::CommandManager.instance['unpack'].get_path(gem_name, version)
      raise "No gem #{gem_name} #{version} is installed.  Do 'gem list #{gem_name}' to see what you have available."
    end

    if ENV['ARCH']
      arch = ENV['ARCH'] == 'detect' ? Config::CONFIG['host'] : ENV['ARCH']
    else
      arch = gem.extensions.size > 0 ? Config::CONFIG['host'] : 'ruby'
    end

    target_dir = ENV['TO'] || File.basename(path).sub(/\.gem$/, '')
    rm_rf "vendor/gems/#{arch}/#{target_dir}"
    
    target_dir = File.expand_path(target_dir, File.join(RAILS_ROOT, 'vendor', 'gems', arch))
    mkdir_p target_dir
    Gem::Installer.new(path).unpack(target_dir)
    puts "Unpacked #{gem_name} #{version} (#{arch}) to '#{target_dir}'"
  end

  task :unfreeze do
    raise "No gem specified, specify one with GEM=gem_name" unless gem_name = ENV['GEM']
    Dir["vendor/gems/*/#{gem_name}-*"].each { |d| rm_rf d }
  end
end
