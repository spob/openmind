module ForecastsHelper

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

  def state_options
    [
        ["NO STATE",""],
        ["ALABAMA","AL"],
        ["ALASKA","AK"],
        ["ARIZONA","AZ"],
        ["ARKANSAS","AR"],
        ["CALIFORNIA","CA"],
        ["COLORADO","CO"],
        ["CONNECTICUT","CT"],
        ["DELAWARE","DE"],
        ["FLORIDA","FL"],
        ["GEORGIA","GA"],
        ["HAWAII","HI"],
        ["IDAHO","ID"],
        ["ILLINOIS","IL"],
        ["INDIANA","IN"],
        ["IOWA","IA"],
        ["KANSAS","KS"],
        ["KENTUCKY","KY"],
        ["LOUISIANA","LA"],
        ["MAINE","ME"],
        ["MARYLAND","MD"],
        ["MASSACHUSETTS","MA"],
        ["MICHIGAN","MI"],
        ["MINNESOTA","MN"],
        ["MISSISSIPPI","MS"],
        ["MISSOURI","MO"],
        ["MONTANA","MT"],
        ["NEBRASKA","NE"],
        ["NEVADA","NV"],
        ["NEW HAMPSHIRE","NH"],
        ["NEW JERSEY","NJ"],
        ["NEW MEXICO","NM"],
        ["NEW YORK","NY"],
        ["NORTH CAROLINA","NC"],
        ["NORTH DAKOTA","ND"],
        ["OHIO","OH"],
        ["OKLAHOMA","OK"],
        ["OREGON","OR"],
        ["PENNSYLVANIA","PA"],
        ["RHODE ISLAND","RI"],
        ["SOUTH CAROLINA","SC"],
        ["SOUTH DAKOTA","SD"],
        ["TENNESSEE","TN"],
        ["TEXAS","TX"],
        ["UTAH","UT"],
        ["VERMONT","VT"],
        ["VIRGINIA","VA"],
        ["WASHINGTON","WA"],
        ["WEST VIRGINIA","WV"],
        ["WISCONSIN","WI"],
        ["WYOMING","WY"]
    ]
  end

  def forecasted_products
    Product.find(:all, :conditions => {:id => APP_CONFIG['forecasted_products'].gsub(/^\s*\(|\)\s*$/, "").split(/,/).map{|x| x.to_i}}, :order => :name)
  end
end
