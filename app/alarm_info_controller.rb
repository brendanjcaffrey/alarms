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
      self.window.makeFirstResponder(@layout.time_field)

      @title_prefix = @alarm == nil ? 'Add Alarm' : 'Edit Alarm'
      alarm_date = @alarm == nil ? Time.now : @alarm.date
      @date_updated = @alarm != nil
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
    result = @alarm == nil ? @delegate.alarm_added(combine_date_and_time) :
                             @delegate.alarm_edited(@alarm, combine_date_and_time)
    result ? close : alert_invalid
  end

  def cancel(sender)
    close
  end

  def delete(sender)
    @delegate.alarm_deleted(@alarm)
    close
  end

  def validate_date(new_date)
    new_date = Time.tomorrow if date_time_in_past?(new_date, @layout.time_field.dateValue)
    set_title_for_date(new_date)
    @date_updated = true unless @switching
    new_date
  end

  def time_updated(new_time)
    update_icon_for_time(new_time)
    date = @layout.date_field.dateValue

    if date_time_in_past?(date, new_time)
      change_date_in_background(Time.tomorrow)
    elsif !@date_updated && Time.tomorrow.same_day?(date)
      change_date_in_background(Time.now)
    end
  end

  private

  def combine_date_and_time
    date = Time.at(@layout.date_field.dateValue)
    time = Time.at(@layout.time_field.dateValue)

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

  def change_date_in_background(new_date)
    @switching = true

    Dispatch::Queue.main.async do
      @layout.date_field.dateValue = new_date
      @switching = false
    end
  end

  def alert_invalid
    alert = NSAlert.alloc.init
    alert.alertStyle = NSWarningAlertStyle
    alert.messageText = 'Invalid time'
    alert.informativeText = 'Time is too close to another alarm'
    alert.runModal
  end
end
