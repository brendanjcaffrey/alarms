class AlarmSounder
  @@silence_seconds = 15.0

  def initialize(delegate, player, talker, shower)
    @delegate = WeakRef.new(delegate)
    @player = player
    @talker = talker
    @shower = shower
  end

  def set_next_alarm(alarm)
    @alarm_timer.invalidate if @alarm_timer
    @alarm = alarm
    return unless alarm

    seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @alarm_timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target:self, selector:'fired:',
                                                    userInfo:nil, repeats:false)
  end

  def fired(timer)
    @alarm_timer = nil
    @shower.show_control_panel(self)
    @talker.start_talking(self)
    @player.play
  end

  def did_gesture
    @player.silence
    @silence_timer = NSTimer.scheduledTimerWithTimeInterval(@@silence_seconds, target:self, selector:'unsilence:',
                                                            userInfo:nil, repeats:false)
  end

  def unsilence(timer)
    @silence_timer = nil
    @player.unsilence
  end

  def snooze
    clean_up
    @delegate.alarm_snoozed(@alarm)
  end

  def stop
    clean_up
    @delegate.alarm_deleted(@alarm)
  end

  private

  def clean_up
    @alarm_timer.invalidate if @alarm_timer
    @silence_timer.invalidate if @silence_timer
    @alarm_timer = @silence_timer = nil

    @player.stop
    @talker.stop_talking
    @shower.hide_control_panel
  end
end
