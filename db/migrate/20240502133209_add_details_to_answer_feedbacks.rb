class AddDetailsToAnswerFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :answer_feedbacks, :details, :text unless column_exists?(:answer_feedbacks, :details)
  end
end
