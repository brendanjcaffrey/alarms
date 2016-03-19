class SoundAction < Action
  @@default_output = 'Built-in Output'
  @@max_volume = 1.0
  @@start_volume = 0.30
  @@increase_by = 0.025

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
    setOutputDeviceByName(@@default_output)

    @old_volume = getOutputVolume
    @current_volume = @@start_volume - @@increase_by
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
    @current_volume = @current_volume + @@increase_by
    if @current_volume >= @@max_volume
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
