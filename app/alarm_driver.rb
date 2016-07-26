class AlarmDriver
  def initialize(delegate, actions)
    @delegate = WeakRef.new(delegate)
    @actions = actions
    @actions.each { |action| action.set_delegate(self) }
  end

  def set_next_alarm(alarm)
    @alarm_timer.invalidate if @alarm_timer
    @prealarm_timer.invalidate if @prealarm_timer
    @alarm_timer = @prealarm_timer = nil

    # if the alarm changed after the prealarm timer fired, we need to reset everything
    @actions.each { |action| action.finished }
    @alarm = alarm
    return unless alarm

    alarm_seconds = alarm.date.timeIntervalSinceDate(NSDate.date)
    @alarm_timer = NSTimer.scheduledTimerWithTimeInterval(alarm_seconds, target: self,
      selector: 'start_timer_fired:', userInfo: nil, repeats: false)
    prealarm_seconds = [alarm_seconds - 15*60, 0].max # TODO use EXCLUSIVITY_WINDOW
    @prealarm_timer = NSTimer.scheduledTimerWithTimeInterval(prealarm_seconds, target: self,
      selector: 'prestart_timer_fired:', userInfo: nil, repeats: false)
  end

  def prestart_timer_fired(timer)
    @prealarm_timer = nil
    alarm_seconds = @alarm.date.timeIntervalSinceDate(NSDate.date)
    @actions.each { |action| action.prestarted(alarm_seconds) }
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
