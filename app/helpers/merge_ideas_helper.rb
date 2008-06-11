module MergeIdeasHelper
  
  def show_merge_button target_id
    confirm = "If you merge, the #{pluralize(@idea.votes.size, 'vote')} currently assigned to idea #{@idea.id} will be reassigned to idea #{target_id.id}. This cannot be undone. Are you sure you wish to proceed?" unless @idea.votes.empty?
    confirm = "Are you sure?" if @idea.votes.empty?
    button_to "Merge", merge_ideas_path(:id => @idea.id, :merged_into_idea_id => target_id.id),
      html_options = { :confirm => confirm, :method => :post,
      :onmouseover => "Tip('Merge idea #{@idea.id} into idea #{target_id.id}')",
      :class=> "button" }
  end
end
