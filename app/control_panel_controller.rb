class ControlPanelController < NSWindowController
  def init_with_delegate(delegate)
    @delegate = WeakRef.new(delegate)
    init
  end

  def init
    @timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:'update_time', userInfo:nil, repeats:true)

    super.tap do
      @layout = ControlPanelLayout.alloc.init
      self.window = @layout.window
      update_time

      snooze = @layout.snooze
      snooze.setTarget(self)
      snooze.setAction('snooze:')

      stop = @layout.stop
      stop.setTarget(self)
      stop.setAction('stop:')
    end
  end

  def snooze(sender)
    close_window
    @delegate.snooze
  end

  def stop(sender)
    close_window
    @delegate.stop
  end

  def update_time
    @formatter ||= NSDateFormatter.alloc.init.tap { |format| format.setDateFormat 'hh:mm:ss a' }
    @layout.time.setStringValue(@formatter.stringFromDate(NSDate.date))
  end

  def close_window
    @layout.window.close
    @timer.invalidate
  end
end
