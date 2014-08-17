class Device
  attr_reader :idx, :id, :name

  def initialize(idx, id, name)
    @idx = idx
    @id = id
    @name = name
  end

  def emulator?
    @id.start_with?('emulator-')
  end

  def physical_device?
    !emulator?
  end

  def short_name
    "#{@name[0..4]}[#{@idx}]"
  end

  def to_s
    "#{@id} [#{@name}]"
  end
end