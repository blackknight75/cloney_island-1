class User < ApplicationRecord
  has_secure_password
  has_many :answers
  has_many :comments
  has_many :password_tokens
  has_many :questions
  has_many :user_roles
  has_many :roles, through: :user_roles

  validates :name, :email, :phone, presence: true

  def comments_to_recent_activity
    Comment.comments_to_user_activity(self.id)[0..4]
  end

  def recent_questions
    questions.last(5).reverse!
  end

  def recent_answers
    answers.last(5).reverse!
  end

  def admin?
    roles.exists?(name: "admin")
  end

  def registered_user?
    roles.exists?(name: "registered_user")
  end

end
