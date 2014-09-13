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

      @submit = @layout.submit
      @submit.setTarget(self)
      @submit.setAction('submit:')

      @cancel = @layout.cancel
      @cancel.setTarget(self)
      @cancel.setAction('cancel:')

      @delete = @layout.delete
      @delete.setTarget(self)
      @delete.setAction('delete:')
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

  private

  def combine_date_and_time
    date = Time.at @layout.date.dateValue
    time = Time.at @layout.time.dateValue

    Time.local(date.year, date.mon, date.day, time.hour, time.min)
  end
end
