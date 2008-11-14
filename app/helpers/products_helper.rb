module ProductsHelper
  def show_product_watch_icon product
    puts "===========>#{product.id}"
    if current_user == :false
      link_to theme_image_tag("icons/24x24/watchAdd.png",
        :alt=>"Watch this product to be informed of any updates to releases for this product",
        :title=> "Watch this product to be informed of any updates to releases for this product",
        :onmouseover => "Tip('Watch this product to be informed of any updates to releases for this product')"),
        create_product_watch_watch_path(:id => product),
        :html => {  },
        :method => :post
    elsif product.watchers.include? current_user
      link_to_remote theme_image_tag("icons/24x24/watchRemove.png",
        :alt=>"Do not notify me of updates to releases for this product",
        :title=> "Do not notify me of updates to releases for this product",
        :onmouseover => "Tip('Do not notify me of updates to releases for this product')"),
        :url =>  destroy_product_watch_watch_path(:id => product),
        :html => {  },
        :method => :delete
    else
      link_to_remote theme_image_tag("icons/24x24/watchAdd.png",
        :alt=>"Watch this product to be informed of any updates to releases for this product",
        :title=> "Watch this product to be informed of any updates to releases for this product",
        :onmouseover => "Tip('Watch this product to be informed of any updates to releases for this product')"),
        :url =>  create_product_watch_watch_path(:id => product),
        :html => {  },
        :method => :post
    end
  end

  def show_product_watch_button product
    unless current_user == :false
      if product.watchers.include? current_user
        link_to "Remove product Watch",
          destroy_product_watch_watch_path(:id => product),
          { :class => "button",
          :onmouseover => "Tip('Do not notify me of updates to releases for this product')",
          :method => :delete                }
      else
        link_to "Add product Watch",
          create_product_watch_watch_path(product),
          { :class => "button",
          :onmouseover => "Tip('Watch this product to be informed of any updates to releases for this product')",
          :method => :post                   }
      end
    end
  end
end
