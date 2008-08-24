module GroupsHelper
  def can_edit? group
    group.can_edit? current_user
  end
end
