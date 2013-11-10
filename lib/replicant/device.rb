class Device
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end

  def emulator?
    @id.start_with?('emulator-')
  end

  def physical_device?
    !emulator?
  end

  def to_s
    "#{@id} [#{@name}]"
  end
end