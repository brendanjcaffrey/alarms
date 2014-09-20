class AlarmSounder
  def initialize(delegate, player, talker, shower)
    @delegate = WeakRef.new(delegate)
    @player = player
    @talker = talker
    @shower = shower
  end

  def set_next_alarm(alarm)
    @timer.invalidate if @timer
    @alarm = alarm
    return unless alarm

    seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target:self, selector:'fired:',
                                                    userInfo:nil, repeats:false)
  end

  def fired(timer)
    @timer = nil
    @shower.show_control_panel(self)
    @talker.start_talking(self)
    @player.play
  end

  def did_gesture
    clean_up
    @delegate.alarm_deleted(@alarm)
  end

  def snooze
    clean_up
    @delegate.alarm_snoozed(@alarm)
  end

  def stop
    did_gesture
  end

  private

  def clean_up
    @player.stop
    @talker.stop_talking
    @shower.hide_control_panel
  end
end
