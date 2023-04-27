class User < ApplicationRecord
  before_create :set_default_role
  before_save :downcase_email

  has_one :refresh_token, dependent: :destroy
  has_many :profiles, dependent: :delete_all

  validates :email, presence: true, uniqueness: true,
                    format: URI::MailTo::EMAIL_REGEXP, length: { maximum: 64 }
  validates :password, presence: true,
                       length: { minimum: 7, maximum: 64 }

  has_secure_password

  enum role: { user: 0, moderator: 1, admin: 2 }

  private

  def set_default_role
    self.role ||= :user
  end

  def downcase_email
    email.downcase!
  end
end
