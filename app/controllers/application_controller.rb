class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user,
                :current_permission,
                :current_admin?,
                :current_users_question?,
                :current_users_comment?,
                :current_users_answer?,
                :display_block_button?,
                :display_unblock_button?

  before_action :authorize!

  def current_user
    @user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_permission
    @current_permission ||= Permission.new(current_user)
  end

  def authorize!
    unless authorized?
      if current_user && current_user.blocked_user?
        flash[:danger] = "Your account priveleges have been limited due to your activity"
      else
        flash[:danger] = "You are not authorized to do that. Please log in or create an account."
      end
      redirect_to root_path
    end
  end

  def authorized?
    current_permission.allow?(params[:controller], params[:action])
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def current_users_question?(question)
    current_user && current_user.id == question.user_id
  end

  def current_users_comment?(comment)
    current_user && current_user.id == comment.user_id
  end

  def current_users_answer?(answer)
    current_user && current_user.id == answer.user_id
  end

  def display_block_button?(question)
    current_admin? && !question.user.blocked_user? &&
     !current_users_question?(@question)
  end

  def display_unblock_button?(question)
    current_admin? && question.user.blocked_user? &&
     !current_users_question?(@question)
  end
end
