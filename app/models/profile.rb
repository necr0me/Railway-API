class Profile < ApplicationRecord
  belongs_to :user

  before_save :upcase_passport_code

  VALID_PASSPORT_CODE_REGEX = /[A-Za-zА-Яа-я]{2}\d{7}/i

  auto_strip_attributes :name, :surname, :patronymic, squish: true
  auto_strip_attributes :phone_number, delete_whitespaces: true

  validates_presence_of :name, :surname, :patronymic, :phone_number, :passport_code

  validates :name, length: {minimum: 2, maximum: 50}
  validates :surname, length: {minimum: 2, maximum: 50}
  validates :patronymic, length: {minimum: 5, maximum: 50}

  validates :passport_code, format: VALID_PASSPORT_CODE_REGEX
  validates :phone_number, length: {minimum: 7, maximum: 13}

  private

  def upcase_passport_code
    self.passport_code.upcase!
  end
end
