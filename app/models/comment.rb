class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  validates :body, presence: true
  has_many :upvotes, as: :upvoted, dependent: :destroy
  has_many :downvotes, as: :downvoted, dependent: :destroy

  def source_question
    if commentable_type == "Question"
      commentable
    else
      commentable.question
    end
  end

  def self.comments_to_user_activity(user_id)
    joins("LEFT OUTER JOIN questions ON comments.commentable_id = questions.id AND comments.commentable_type = 'Question'")
    .joins("LEFT OUTER JOIN answers ON comments.commentable_id = answers.id AND comments.commentable_type = 'Answer'")
    .where("questions.user_id = #{user_id} OR answers.user_id = #{user_id}")
    .order(:updated_at)
  end

  def update_date
    return updated_at.strftime("%D at %r") unless created_at.nil?
  end

  def self.populate_comment(comment_params, question, answer)
    if comment_params[:answer]
      answer.comments.build(body: comment_params[:body])
    else
      question.comments.build(body: comment_params[:body])
    end
  end

  def self.check_comments
    if count >= 1 && first.body != nil
      true
    else
      false
    end
  end

  def current_user_upvote_correction(creator_id)
    if upvotes.where(creator: creator_id).exists?
      upvotes.where(creator:creator_id).destroy_all
    end
  end

  def current_user_downvote_correction(creator_id)
    if downvotes.where(creator: creator_id).exists?
      downvotes.where(creator:creator_id).destroy_all
    end
  end

  def comment_reputation
    upvotes.count - downvotes.count
  end
end
