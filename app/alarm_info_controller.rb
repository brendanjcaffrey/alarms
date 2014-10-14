class AlarmInfoController < NSWindowController
  def init_with_alarm(alarm, delegate:delegate)
    @alarm = alarm
    @delegate = WeakRef.new(delegate)
    init
  end

  def init
    super.tap do
      @layout = AlarmInfoLayout.alloc.init_with_alarm(@alarm)
      self.window = @layout.window
      self.window.makeFirstResponder(@layout.time)

      @title_prefix = @alarm == nil ? 'Add Alarm' : 'Edit Alarm'
      alarm_date = @alarm == nil ? Time.now : @alarm.date
      set_title_for_date(alarm_date)
      update_icon_for_time(alarm_date)

      submit = @layout.submit
      submit.setTarget(self)
      submit.setAction('submit:')

      cancel = @layout.cancel
      cancel.setTarget(self)
      cancel.setAction('cancel:')

      delete = @layout.delete
      delete.setTarget(self)
      delete.setAction('delete:')
    end
  end

  def submit(sender)
    if @alarm == nil
      @delegate.alarm_added(combine_date_and_time)
    else
      @delegate.alarm_edited(@alarm, combine_date_and_time)
    end

    close
  end

  def cancel(sender)
    close
  end

  def delete(sender)
    @delegate.alarm_deleted(@alarm)
    close
  end

  def validate_date(new_date)
    new_date = Time.tomorrow if date_time_in_past?(new_date, @layout.time.dateValue)
    set_title_for_date(new_date)
    new_date
  end

  def time_updated(new_time)
    update_icon_for_time(new_time)
    @layout.date.dateValue = Time.tomorrow if date_time_in_past?(@layout.date.dateValue, new_time)
  end

  private

  def combine_date_and_time
    date = Time.at(@layout.date.dateValue)
    time = Time.at(@layout.time.dateValue)

    Time.local(date.year, date.mon, date.day, time.hour, time.min)
  end

  def set_title_for_date(date)
    title = @title_prefix
    title += ' for Today' if Time.now.same_day?(date)
    title += ' for Tomorrow' if Time.tomorrow.same_day?(date)
    @layout.window.setTitle(title)
  end

  def update_icon_for_time(time)
    name = (time.hour < 6 || time.hour >= 18) ? 'moon' : 'sun'
    @layout.icon.image = NSImage.imageNamed(name)
  end

  def date_time_in_past?(proposed_date, proposed_time)
    now = Time.now
    proposed_time.hour_and_minute_less_than?(now) && proposed_date.same_day?(now)
  end
end
