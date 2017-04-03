class Permission
  extend Forwardable

  attr_reader :user, :controller, :action

  def_delegators :user, :registered_user?,
                        :admin?,
                        :blocked_user?

  def initialize(user)
    @user = user || User.new
  end

  def allow?(controller, action)
    @controller = controller
    @action     = action
    if admin?
      admin_permissions
    elsif registered_user?
      registered_user_permissions
    elsif blocked_user?
      blocked_user_permissions
    else
      guest_permissions
    end
  end

private

  def admin_permissions
    return true if controller == "answers" && action.in?(%w(create destroy))
    return true if controller == "comments" && action.in?(%w(create destroy))
    return true if controller == "user_permissions" && action.in?(%w(update))
    registered_user_permissions
  end

  def registered_user_permissions
    return true if controller == "users" && action.in?(%w(show edit update))
    return true if controller == "questions" && action.in?(%w(index show new create destroy edit update))
    return true if controller == "answers" && action.in?(%w(create destroy))
    return true if controller == "comments" && action.in?(%w(create destroy))
    return true if controller == "passwords" && action.in?(%w(edit update))
    return true if controller == "upvotes" && action.in?(%w(create destroy))
    return true if controller == "downvotes" && action.in?(%w(create destroy))
    basic_permissions
  end

  def blocked_user_permissions
    return true if controller == "users" && action.in?(%w(show edit update))
    return true if controller == "questions" && action.in?(%w(index show))
    return true if controller == "passwords" && action.in?(%w(edit update))
    basic_permissions
  end

  def guest_permissions
    return true if controller == "users" && action.in?(%w(new create show))
    return true if controller == "questions" && action.in?(%w(index show))
    basic_permissions
  end

  def basic_permissions
    return true if controller == "sessions"
    return true if controller == "home"
  end
end
