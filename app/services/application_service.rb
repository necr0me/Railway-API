class ApplicationService
  attr_reader :error, :data

  def self.call(...)
    instance = new(...)
    instance.call
    instance
  rescue StandardError, NotImplementedError => e
    instance.send(:fail!, error: e.message)
    instance
  end

  def initialize(...); end

  def call
    raise NotImplementedError, "You should define ##{__method__} first"
  end

  def success?
    error.nil?
  end

  protected

  def success(data: nil)
    @data = data
  end

  alias success! success

  def fail(error:, data: nil)
    @data = data
    @error = error
  end

  alias fail! fail

  # TODO: try another time to test this class
end
