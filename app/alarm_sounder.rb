class AlarmSounder
  def initialize(delegate)
    @delegate = WeakRef.new(delegate)
  end

  def set_next_alarm(alarm)
    @timer.invalidate if @timer

    @alarm = alarm
    seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target:self, selector:'fired:',
                                                    userInfo:nil, repeats:false)
  end

  def fired(timer)
    @delegate.alarm_deleted(@alarm)
    @timer = @alarm = nil
    NSLog('fired')
  end
end
