class SoundAction < Action
  DEFAULT_OUTPUT   = 'Built-in Output'
  BLUETOOTH_OUTPUT = 'Echo Dot-G9N'
  MAX_VOLUME       = 1.0
  START_VOLUME     = 0.025
  INCREASE_BY      = 0.025
  CHANGE_BUFFER    = 10 # seconds

  BLUETOOTH_TEMPLATE = <<-SCRIPT
    activate application "SystemUIServer"
    tell application "System Events"
      tell process "SystemUIServer"
        set btMenu to (menu bar item 1 of menu bar 1 whose description contains "bluetooth")
        tell btMenu
          click
          tell (menu item "%1$s" of menu 1)
            click
            if exists menu item "%2$s" of menu 1 then
              click menu item "%2$s" of menu 1
              return "Clicked button, %2$sing..."
            else
              return "Already %2$sed..."
              key code 53
            end if
          end tell
        end tell
      end tell
    end tell
  SCRIPT

  CONNECT_BLUETOOTH = BLUETOOTH_TEMPLATE % [BLUETOOTH_OUTPUT, "Connect"]
  DISCONNECT_BLUETOOTH = BLUETOOTH_TEMPLATE % [BLUETOOTH_OUTPUT, "Disconnect"]

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

  def prestarted(seconds_until_started)
    finished if @change_output_timer

    if seconds_until_started <= CHANGE_BUFFER
      change_output
    else
      @change_output_timer = NSTimer.scheduledTimerWithTimeInterval(seconds_until_started - CHANGE_BUFFER, target: self,
                                                                    selector: 'change_output', userInfo: nil, repeats: false)
    end
  end

  def started
    @old_volume = getOutputVolume
    @current_volume = START_VOLUME - INCREASE_BY
    update_volume
    @update_volume_timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: 'update_volume', userInfo: nil, repeats: true)

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

    `osascript -e '#{DISCONNECT_BLUETOOTH}' 2>&1` if @bluetooth_connected
    setOutputVolume(@old_volume) if @old_volume
    setOutputDeviceByName(@old_output) if @old_output
    @old_volume = @old_output = @bluetooth_connected = nil
  end


  def update_volume
    setOutputDeviceByName(BLUETOOTH_OUTPUT)

    @current_volume = @current_volume + INCREASE_BY
    if @current_volume >= MAX_VOLUME
      @current_volume = MAX_VOLUME
      invalidate_timer
    end

    setOutputVolume(@current_volume)
  end

  private

  def change_output
    @old_output = getCurrentOutputDeviceName
    setOutputDeviceByName(DEFAULT_OUTPUT)

    `osascript -e '#{CONNECT_BLUETOOTH}' 2>&1`
    @bluetooth_connected = true
  end

  def invalidate_timer
    @update_volume_timer.invalidate if @update_volume_timer
    @change_output_timer.invalidate if @change_output_timer
    @update_volume_timer = @change_output_timer = nil
  end
end
