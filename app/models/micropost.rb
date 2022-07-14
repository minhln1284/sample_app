class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.micropost.maximum}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png),
                                   message: "must be a valid image format"},
                    size:         {less_than: 5.megabytes,
                                   message: "should be less than 5MB"}
  delegate :name, to: :user, prefix: true
  scope :newest, ->{order created_at: :desc}
end
