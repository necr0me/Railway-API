class ProfileSerializer
  include JSONAPI::Serializer

  attributes :name, :surname, :patronymic, :phone_number, :passport_code
end
