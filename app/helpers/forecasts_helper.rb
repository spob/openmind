module ForecastsHelper

  def stage_options
    Forecast.stages.to_a.sort{|x,y| x[1] <=> y[1]}.collect{|x| x[0]}
  end

  def strip_adapter(str)
    str.sub(/\ Adapter$/, "")
  end

  def product_options
    [
            "60 Day Migration License",
#           "Annual Day Migration License",
            "SB15",
            "SB100",
            "Standard",
            "Professional",
            "Enterprise",
            "Scribe Online RS",
            "Scribe Online SYS",
            "Services / Training / Consulting"
    ]
  end

  def state_options
    [
        ["NO STATE",""],
        ["ALABAMA","AL"],
        ["ALASKA","AK"],
        ["ALBERTA","AB"],
        ["ARIZONA","AZ"],
        ["ARKANSAS","AR"],
        ["BRITISH COLUMBIA","BC"],
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
        ["MANITOBA","MB"],
        ["MICHIGAN","MI"],
        ["MINNESOTA","MN"],
        ["MISSISSIPPI","MS"],
        ["MISSOURI","MO"],
        ["MONTANA","MT"],
        ["NEBRASKA","NE"],
        ["NEVADA","NV"],
        ["NEWFOUNDLAND","NF"],
        ["NEW HAMPSHIRE","NH"],
        ["NEW JERSEY","NJ"],
        ["NEW MEXICO","NM"],
        ["NEW YORK","NY"],
        ["NORTH CAROLINA","NC"],
        ["NORTH DAKOTA","ND"],
        ["NORTHWEST TERRITORIES","NW"],
        ["NOVA SCOTIA","NS"],
        ["NUNAVUT","NU"],
        ["OHIO","OH"],
        ["OKLAHOMA","OK"],
        ["ONTARIO","ON"],
        ["OREGON","OR"],
        ["PENNSYLVANIA","PA"],
        ["PRINCE EDWARD ISLAND","PE"],
        ["QUEBEC","QC"],
        ["RHODE ISLAND","RI"],
        ["SASKATCHAWAN","SK"],
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
        ["WYOMING","WY"],
        ["YUKON TERRITORY","YT"]
    ]
  end

  def forecasted_products
    Product.find(:all, :conditions => {:id => APP_CONFIG['forecasted_products'].gsub(/^\s*\(|\)\s*$/, "").split(/,/).map{|x| x.to_i}}, :order => :name)
  end
end
