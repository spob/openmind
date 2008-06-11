module VotesHelper

  def display_allocated_to(vote)
    if vote.allocation.user_id.nil? 
      vote.allocation.enterprise.name
    else
      user_display_name(vote.allocation.user)
    end
  end
  
end
