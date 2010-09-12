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
  
  def show_watch_icon release
    if logged_in?
      if release.product.watchers.include? current_user
        theme_image_tag("icons/16x16/16-check.png", :alt=>"watched", :onmouseover => "Tip('You are watching this product')")
      else
        "&nbsp;"
      end
    else
      theme_image_tag("icons/16x16/question.png", :alt=>"not logged in", :onmouseover => "Tip('Log in to determine whether you are already watching this product')")
    end
  end
  
  def show_watch_products_button releases, serial_number
    link_to("Watch Products",
    create_product_watches_watches_path(check_for_updates_params(releases, serial_number)),
    { :class => "button",
      :onmouseover => "Tip('Watch your products to be informed via email of any updates')" })
  end
  
  def show_product_watch_button product, releases, serial_number
    unless product.watchers.include? current_user
      "&nbsp;&nbsp;" + link_to("Watch",
      create_product_watch_from_check_for_update_watch_path(product, :from => check_for_update_url(releases, serial_number, false)),
      { :class => "button",
        :onmouseover => "Tip('Watch this product to be informed of any updates to releases for this product')",
        :method => :post                   })
    end
  end
  
  def send_products_to_sales_link(link_text, releases, serial_number)
    generate_email_link(APP_CONFIG['sales_email'], 
    link_text, "Regarding maintenance for serial number #{serial_number}", releases, serial_number)
  end
  
  def send_products_to_support_link(link_text, releases, serial_number)
    generate_email_link(APP_CONFIG['support_email'], 
    link_text, "Product list for serial number #{serial_number}", releases, serial_number)
  end
  
  private
  
  def generate_email_link email_address, link_text, subject, releases, serial_number
    mail_to(email_address, 
            link_text, 
            :subject => subject,
            :body => "My installed products can be viewed at: #{check_for_update_url(releases, serial_number, true)}")
  end
  
  def check_for_update_url releases, serial_number, absolute=true
    
    if absolute
      check_for_updates_releases_url(check_for_updates_params(releases, serial_number))
    else
      check_for_updates_releases_path(check_for_updates_params(releases, serial_number))
    end
  end
  
  def check_for_updates_params(releases, serial_number)
    product_list = releases.collect { |release| "#{release.id}|#{release.maintenance_expires}" }.join(",")
    { :releases => product_list, :serial_number => serial_number }
  end
end
