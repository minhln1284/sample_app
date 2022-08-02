class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.micropost.maximum}
  validates :image, content_type: {in: Settings.micropost.content_type,
                                   message: :wrong_format},
                    size:         {less_than: Settings.micropost.file_size.megabytes,
                                   message: :too_big}
  delegate :name, to: :user, prefix: true
  scope :newest, ->{order created_at: :desc}
end
