class ControlPanelController < NSWindowController
  def init_with_delegate(delegate)
    @delegate = WeakRef.new(delegate)
    init
  end

  def init
    @timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: 'update_time', userInfo: nil, repeats: true)

    super.tap do
      @layout = ControlPanelLayout.alloc.init
      self.window = @layout.window
      self.window.instance_eval { def canBecomeKeyWindow; true; end }

      update_time

      snooze = @layout.snooze
      snooze.setTarget(self)
      snooze.setAction('snooze:')

      stop = @layout.stop
      stop.setTarget(self)
      stop.setAction('stop:')
    end
  end

  def keyDown(event)
    stop(event) if event.characters == "\r"
    snooze(event) if event.characters == " "
  end

  def cancel(event)
    stop(event)
  end

  def snooze(sender)
    @delegate.snooze
  end

  def stop(sender)
    @delegate.stop
  end

  def update_time
    @formatter ||= NSDateFormatter.alloc.init.tap { |format| format.setDateFormat 'hh:mm:ss a' }
    @layout.time_field.setStringValue(@formatter.stringFromDate(NSDate.date))

    self.window.makeKeyAndOrderFront(self)
    NSApp.activateIgnoringOtherApps(true)
  end

  def close_window
    @layout.window.close
    @timer.invalidate
  end
end
