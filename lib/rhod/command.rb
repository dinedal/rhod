class Rhod::Command
  def initialize(&block)
    @request = block
  end

  def self.execute(&block)
    this = self.new(&block)
    this.execute
  end

  def execute
    @request.call
  end

end
