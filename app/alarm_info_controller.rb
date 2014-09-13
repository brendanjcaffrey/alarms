class AlarmInfoController < NSWindowController
  def init_with_alarm(alarm)
    @alarm = alarm
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
    close
  end

  def cancel(sender)
    close
  end

  def delete(sender)
    close
  end
end
