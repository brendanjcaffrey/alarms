class AudioPlayer
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
    @player.play
  end

  def stop
    @player.stop
  end
end
