class SoundAction < Action
  DEFAULT_OUTPUT = 'Built-in Output'
  MAX_VOLUME     = 1.0
  START_VOLUME   = 0.30
  INCREASE_BY    = 0.025

  def initialize
    error_ptr = Pointer.new(:object)
    alarm_url = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource('alarm', ofType: 'm4a'))

    @player = AVAudioPlayer.alloc.initWithContentsOfURL(alarm_url, error: error_ptr)
    if !@player
      NSAlert.alertWithError(error[0]).runModal
      exit
    end

    @player.setNumberOfLoops(-1)
    super
  end

  def started
    @timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: 'update_volume', userInfo: nil, repeats: true)
    @old_output = getCurrentOutputDeviceName
    setOutputDeviceByName(DEFAULT_OUTPUT)

    @old_volume = getOutputVolume
    @current_volume = START_VOLUME - INCREASE_BY
    update_volume

    @player.play
  end

  def paused
    @player.stop
  end

  def unpaused
    @player.play
  end

  def finished
    invalidate_timer
    @player.stop

    setOutputVolume(@old_volume) if @old_volume
    setOutputDeviceByName(@old_output) if @old_output
    @old_volume = @old_output = nil
  end


  def update_volume
    @current_volume = @current_volume + INCREASE_BY
    if @current_volume >= MAX_VOLUME
      @current_volume = 1.0
      invalidate_timer
    end

    setOutputVolume(@current_volume)
  end

  private

  def invalidate_timer
    @timer.invalidate if @timer
    @timer = nil
  end
end
