class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  USER_ATTR = %i(name email password password_confirmation).freeze

  before_save :downcase_email

  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: Settings.user.name_max}

  validates :email, presence: true,
            length: {minium: Settings.user.email_min,
                     maximum: Settings.user.email_max},
            format: {with: Settings.user.email_regex},
            uniqueness: {case_sensitive: false}

  validates :password, presence: true,
            length: {minimum: Settings.user.password_min},
            allow_nil: true

  has_secure_password

  scope :latest_users, ->{order created_at: :desc}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.blank?

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.user.time.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
