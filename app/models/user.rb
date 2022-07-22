class User < ApplicationRecord
  USER_ATTR = %i(name email password password_confirmation).freeze

  validates :name, presence: true, length: {maximum: Settings.user.name_max}

  validates :email, presence: true,
            length: {minium: Settings.user.email_min,
                     maximum: Settings.user.email_max},
            format: {with: Settings.user.email_regex},
            uniqueness: {case_sensitive: false}

  validates :password, presence: true,
            length: {minimum: Settings.user.password_min}

  has_secure_password

  before_save :downcase_email

  private
  def downcase_email
    email.downcase!
  end
end
