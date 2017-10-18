class SoundAction < Action
  OUTPUT_DEVICE = 'Bedroom'
  MAX_VOLUME    = 100
  START_VOLUME  = 10
  INCREASE_BY   = 1
  CHANGE_BUFFER = 20

  GET_OUTPUT = <<-SCRIPT
    tell application "System Preferences"
      activate
      set current pane to pane "com.apple.preference.sound"
    end tell

    tell application "System Events"
      tell application process "System Preferences"
        repeat until exists tab group 1 of window "Sound"
        end repeat

        tell tab group 1 of window "Sound"
          click radio button "Output"

          tell table 1 of scroll area 1
            set selectedRow to (first UI element whose selected is true)
            set currentOutput to value of text field 1 of selectedRow as text
            log currentOutput
          end tell
        end tell
      end tell
    end tell

    if application "System Preferences" is running then
      tell application "System Preferences" to quit
    end if
  SCRIPT

  # this script changes to the built in output first (row 1), then to whatever's selected in case something goes wrong
  CHANGE_OUTPUT = <<-SCRIPT
    tell application "System Preferences"
      activate
      set current pane to pane "com.apple.preference.sound"
    end tell

    tell application "System Events"
      tell application process "System Preferences"
        repeat until exists tab group 1 of window "Sound"
        end repeat
        delay 0.75

        tell tab group 1 of window "Sound"
          click radio button "Output"
          select row 1 of table 1 of scroll area 1
          delay 0.75
          select (row 1 of table 1 of scroll area 1 whose value of text field 1 is "%s")
        end tell
      end tell
    end tell

    if application "System Preferences" is running then
      tell application "System Preferences" to quit
    end if
  SCRIPT

  GET_VOLUME = 'output volume of (get volume settings)'
  CHANGE_VOLUME = 'set volume output volume %d'

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

    if seconds_until_started < CHANGE_BUFFER
      change_output
    else
      @change_output_timer = NSTimer.scheduledTimerWithTimeInterval(seconds_until_started - CHANGE_BUFFER, target: self,
                                                                    selector: 'change_output', userInfo: nil, repeats: false)
    end
  end

  def started
    @old_volume = `osascript -e '#{GET_VOLUME}'`.to_i
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

    `osascript -e '#{CHANGE_VOLUME % @old_volume}'` if @old_volume
    `osascript -e '#{CHANGE_OUTPUT % @old_output}'` if @old_output
    @old_volume = @old_output = nil
  end


  def update_volume
    @current_volume = @current_volume + INCREASE_BY
    if @current_volume >= MAX_VOLUME
      @current_volume = MAX_VOLUME
      invalidate_timer
    end

    `osascript -e '#{CHANGE_VOLUME % @current_volume}'`
  end

  private

  def change_output
    @old_output = `osascript -e '#{GET_OUTPUT}' 2>&1`.chomp
    `osascript -e '#{CHANGE_OUTPUT % OUTPUT_DEVICE}'`

    @change_output_timer = nil
  end

  def invalidate_timer
    @update_volume_timer.invalidate if @update_volume_timer
    @change_output_timer.invalidate if @change_output_timer
    @update_volume_timer = @change_output_timer = nil
  end
end
