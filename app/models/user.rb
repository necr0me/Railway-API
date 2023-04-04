class User < ApplicationRecord
  before_create :set_default_role!

  has_one :refresh_token, dependent: :destroy
  has_one :profile, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9.-]+\z/i

  # TODO: email downcase?
  validates :email, presence: true, uniqueness: true,
                    format: VALID_EMAIL_REGEX, length: { maximum: 64 }
  validates :password, presence: true,
                       length: { minimum: 7, maximum: 64 }

  has_secure_password

  enum role: { user: 0, moderator: 1, admin: 2 }

  private

  def set_default_role!
    self.role ||= :user
  end
end
