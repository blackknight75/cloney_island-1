class Question < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :answers, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  validates :title, :body, presence: true


  def self.order_by_update
    order(:updated_at)
  end

  def find_user
    user.name
  end

  def find_category
    category.name
  end

  def answer_count
    answers.count
  end
end
