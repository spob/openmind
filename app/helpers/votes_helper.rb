module VotesHelper

  def display_allocated_to(vote)
    if vote.allocation.class.to_s == "EnterpriseAllocation"
      vote.allocation.enterprise.name
    else
      user_display_name(vote.allocation.user)
    end
  end
  
end
