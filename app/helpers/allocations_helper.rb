module AllocationsHelper

  def user_allocation_area(allocation, &block)
    yield if allocation.class == UserAllocation
  end

  def enterprise_allocation_area(allocation, &block)
    yield if allocation.class == EnterpriseAllocation
  end
  
  def allocated_to allocation
    if allocation.class == UserAllocation
      user_display_name allocation.user
    elsif allocation.class == EnterpriseAllocation
      allocation.enterprise.name
    else
      "Unknown type '#{self.class}'"
    end
  end
  
  def pix_button_text
    return "Show Images" if session[:allocation_load_toggle_pix] == "HIDE"
    "Hide Images"
  end
  
  def pix_button_display_style action
    return "display:none;" if session[:allocation_load_toggle_pix] == action
    "display:block;"
  end
  
  def pix_display_style
    return "display:none;" if session[:allocation_load_toggle_pix] == "HIDE"
    "display:block;"
  end
end