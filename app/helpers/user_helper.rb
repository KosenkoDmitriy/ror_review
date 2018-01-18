module UserHelper
  def options_for_user_role(role)
    options_for_select( [["Admin", "Admin"], ["User", "User"],["View", "View"],["Demo", "Demo"]])
  end

  def options_for_super_user_role(role)
    options_for_select( [["Admin", "Admin"],["View", "View"],["Demo", "Demo"]])
  end
end