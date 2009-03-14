require 'fileutils'

blank_gif       = File.dirname(__FILE__) + '/../../../public/images/blank.gif'
close_gif       = File.dirname(__FILE__) + '/../../../public/images/close.gif'
closelabel_gif  = File.dirname(__FILE__) + '/../../../public/images/closelabel.gif'
loading_gif     = File.dirname(__FILE__) + '/../../../public/images/loading.gif'
next_gif        = File.dirname(__FILE__) + '/../../../public/images/next.gif'
nextlabel_gif   = File.dirname(__FILE__) + '/../../../public/images/nextlabel.gif'
prev_gif        = File.dirname(__FILE__) + '/../../../public/images/prev.gif'
prevlabel_gif   = File.dirname(__FILE__) + '/../../../public/images/prevlabel.gif'
lightbox_js     = File.dirname(__FILE__) + '/../../../public/javascripts/lightbox.js'
lightbox_css    = File.dirname(__FILE__) + '/../../../public/stylesheets/lightbox.css'

FileUtils.cp File.dirname(__FILE__) + '/public/images/blank.gif',         blank_gif unless File.exist?(blank_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/close.gif',         close_gif unless File.exist?(close_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/closelabel.gif',    closelabel_gif unless File.exist?(closelabel_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/loading.gif',       loading_gif unless File.exist?(loading_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/next.gif',          next_gif unless File.exist?(next_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/nextlabel.gif',     nextlabel_gif unless File.exist?(nextlabel_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/prev.gif',          prev_gif unless File.exist?(prev_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/images/prevlabel.gif',     prevlabel_gif unless File.exist?(prevlabel_gif)
FileUtils.cp File.dirname(__FILE__) + '/public/javascripts/lightbox.js',  lightbox_js unless File.exist?(lightbox_js)
FileUtils.cp File.dirname(__FILE__) + '/public/stylesheets/lightbox.css', lightbox_css unless File.exist?(lightbox_css)

puts IO.read(File.join(File.dirname(__FILE__), 'README'))