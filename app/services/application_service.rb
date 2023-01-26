class ApplicationService
  attr_reader :error, :data

  def self.call(...)
    instance = new(...)
    instance.call
    instance
  end

  def success(data: nil)
    @data = data
  end

  alias success! success

  def success?
    error.nil?
  end

  def fail(data: nil, error: )
    @data = data
    @error = error
  end

  alias fail! fail

  # TODO: try another time to test this class
end
