class AlarmSounder
  def initialize(delegate, player, talker)
    @delegate = WeakRef.new(delegate)
    @player = player
    @talker = talker
    @talker.set_delegate(self)
  end

  def set_next_alarm(alarm)
    @timer.invalidate if @timer

    @alarm = alarm
    seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target:self, selector:'fired:',
                                                    userInfo:nil, repeats:false)
  end

  def fired(timer)
    @timer = nil
    @talker.start_talking
    @player.play
  end

  def did_gesture
    @player.stop
    @talker.stop_talking
    @delegate.alarm_deleted(@alarm)
  end
end
