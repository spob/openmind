#Serving static content with Rails
#http://snafu.diarrhea.ch/blog/article/4-serving-static-content-with-rails

class StaticController < ApplicationController
    NO_CACHE = ['static/license/index',]

  def index
    if template_exists? path = 'static/' + params[:path].to_s
      render_cached path
    elsif template_exists? path += '/index'
      render_cached path
    else
      raise ::ActionController::RoutingError,
            "Recognition failed for #{request.path.inspect}"
    end
  end

private
  def render_cached(path)
    if NO_CACHE.include? path
      render path
    else
      key = path.gsub('/', '-')
      unless content = read_fragment(key)
        content = render_to_string :template => path, :layout => false
        write_fragment(key, content)
      end
      render :text => content, :layout => true
    end
  end
end