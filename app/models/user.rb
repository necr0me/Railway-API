class User < ApplicationRecord
  before_create :set_default_role
  before_save :downcase_email

  has_one :refresh_token, dependent: :destroy
  has_many :profiles, dependent: :destroy

  validates :email, uniqueness: true,
                    format: URI::MailTo::EMAIL_REGEXP, length: { maximum: 64 }, allow_nil: true

  validates :unconfirmed_email, uniqueness: { message: "Email has already been taken"},
                                format: URI::MailTo::EMAIL_REGEXP, length: { maximum: 64 }, allow_nil: true
  validate :unconfirmed_email_must_be_unique

  validates :password, length: { minimum: 7, maximum: 64 }, allow_nil: true

  has_secure_password

  enum role: { user: 0, moderator: 1, admin: 2 }

  def tickets
    profiles.collect(&:tickets).flatten
  end

  # Override setter to have validation message for blank string password
  # https://github.com/rails/rails/issues/34348#issuecomment-615856794
  def password=(password)
    @password = password if !password.nil? && password.blank?
    super
  end

  private

  def unconfirmed_email_must_be_unique
    return if unconfirmed_email.nil? || User.find_by(email: unconfirmed_email).blank?

    errors.add(:unconfirmed_email, "Email has already been taken")
  end

  def set_default_role
    self.role ||= :user
  end

  def downcase_email
    unconfirmed_email&.downcase!
  end
end
