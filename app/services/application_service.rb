class ApplicationService
  def self.call(...)
    self.new(...).call
  end

  # TODO: return self as result of service work. Add methods like 'success?', 'errors', 'fail!' etc...
end
