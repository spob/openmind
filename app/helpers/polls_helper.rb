module PollsHelper
  
  def add_option_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :poll_options, :partial => 'poll_option', 
        :object => PollOption.new(:description => "...")
    end
  end
end
