class AudioPlayer
  @@default_output = 'Built-in Output'
  @@max_volume = 0.2

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
    @old_output = getCurrentOutputDeviceName
    setOutputDeviceByName(@@default_output)

    @old_volume = getOutputVolume
    setOutputVolume(@@max_volume)

    @player.play
  end

  def stop
    setOutputVolume(@old_volume)
    setOutputDeviceByName(@old_output)
    @player.stop
  end
end
