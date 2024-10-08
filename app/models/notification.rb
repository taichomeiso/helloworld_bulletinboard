# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :direct_message_request, optional: true

  # バリデーション（例: メッセージの必須化）
  validates :message, presence: true
end
