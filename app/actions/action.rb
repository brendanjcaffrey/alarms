class Action
  def set_delegate(delegate)
    @delegate = WeakRef.new(delegate)
  end

  def initialize
  end

  def started
  end

  def paused
  end

  def unpaused
  end

  def finished
  end
end
