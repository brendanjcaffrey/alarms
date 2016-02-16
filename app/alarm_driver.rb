class AlarmDriver
  def initialize(delegate, actions)
    @delegate = WeakRef.new(delegate)
    @actions = actions
    @actions.each { |action| action.set_delegate(self) }
  end

  def set_next_alarm(alarm)
    @alarm_timer.invalidate if @alarm_timer
    @alarm = alarm
    return unless alarm

    seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @alarm_timer = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self,
      selector: 'start_timer_fired:', userInfo: nil, repeats: false)
  end

  def start_timer_fired(timer)
    @alarm_timer = nil
    @actions.each { |action| action.started }
  end

  def pause
    @actions.each { |action| action.paused }
  end

  def unpause
    @actions.each { |action| action.unpaused }
  end

  def snooze
    @actions.each { |action| action.finished }
    @delegate.alarm_snoozed(@alarm)
  end

  def stop
    @actions.each { |action| action.finished }
    @delegate.alarm_deleted(@alarm)
  end
end
