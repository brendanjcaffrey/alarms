class AudioPlayer
  @@default_output = 'Built-in Output'
  @@max_volume = 1.0
  @@start_volume = 0.05
  @@increase_by = 0.01

  def initialize
    error_ptr = Pointer.new(:object)
    alarm_url = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource('alarm', ofType:'m4a'))

    @player = AVAudioPlayer.alloc.initWithContentsOfURL(alarm_url, error:error_ptr)
    if !@player
      NSAlert.alertWithError(error[0]).runModal
      exit
    end

    @player.setNumberOfLoops(-1)
  end

  def play
    @timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:'update_volume', userInfo:nil, repeats:true)
    @old_output = getCurrentOutputDeviceName
    setOutputDeviceByName(@@default_output)

    @old_volume = getOutputVolume
    @current_volume = @@start_volume - @@increase_by
    update_volume

    @player.play
  end

  def update_volume
    @current_volume = @current_volume + @@increase_by
    if @current_volume >= @@max_volume
      @current_volume = 1.0
      invalidate_timer
    end
    setOutputVolume(@current_volume)
  end

  def stop
    invalidate_timer
    @player.stop
    setOutputVolume(@old_volume)
    setOutputDeviceByName(@old_output)
  end

  private

  def invalidate_timer
    return if @timer.nil? || !@timer.isValid
    @timer.invalidate
    @timer = nil
  end
end
