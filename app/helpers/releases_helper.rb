module ReleasesHelper
  def dependent_releases dependencies
    buffer = ""
    dependencies.keys.each do |product|
      buffer += "Before upgrading to the latest version of this product, you must first upgrade to one of the following versions of #{link_to product.name, product_path(product)}:"
      buffer += "<ul>"
      dependencies[product].each do |release|
        download_url = "xxx"
        buffer += "<li>#{link_to release.version, release_path(release)} #{download_icon release}</li>"
      end
      buffer += "</ul>"
    end
    return buffer
  end 
  
  def download_icon(release)
    unless release.download_url.nil? or release.download_url.strip.empty? 
      link_to theme_image_tag("icons/16x16/download.png", :alt=>"download release", :title=> "download release"),
      release.download_url,
      { :onmouseover => "Tip('Download release #{release.version}')"}
    end    
  end
  
  def show_product_watch_button product
    if logged_in?
      unless product.watchers.include? current_user
      "&nbsp;&nbsp;" + link_to("Watch",
        create_product_watch_watch_path(product),
        { :class => "button",
          :onmouseover => "Tip('Watch this product to be informed of any updates to releases for this product')",
          :method => :post                   })
      end
    end
  end
  
  def send_products_to_support_link(link_text, releases, serial_number)
    product_list = releases.collect { |release| "#{release.id}|#{release.maintenance_expires}" }.join(",")
    mail_to(APP_CONFIG['support_email'], 
    link_text, 
    :subject => "Product list for serial number #{serial_number}",
    :body => check_for_updates_releases_url(:releases => product_list, :serial_number => serial_number))
  end
end
