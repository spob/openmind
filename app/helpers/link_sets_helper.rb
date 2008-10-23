module LinkSetsHelper
    
  def add_link name
    link_to_function name, :class=> 'insideFormTitle' do |page|
      page.insert_html :bottom, :links, :partial => 'link', 
        :object => Link.new(:name => "...", :url => "")
    end
  end
end
