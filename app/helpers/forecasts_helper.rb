module ForecastsHelper

  def rbm_options
    ["Libby Bishop", "Juliet Depina", "Brian McMurray"]
  end

  def account_exec_options
    ["Nicole Tilton", "Kevin Gordon"]
  end

  def stage_options
    Forecast.stages.to_a.sort{|x,y| x[1] <=> y[1]}.collect{|x| x[0]}
  end

  def product_options
    [ 
            "60 Day Migration License",
            "Annual Day Migration License",
            "SB15",
            "SB100",
            "Standard",
            "Professional",
            "Enterprise"
    ]
  end

  def forecasted_products
    Product.find(:all, :conditions => {:id => APP_CONFIG['forecasted_products'].gsub(/^\s*\(|\)\s*$/, "").split(/,/).map{|x| x.to_i}}, :order => :name)
  end
end
