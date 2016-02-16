class MaxTimeAction < Action
  @@max_time = 60 # seconds

  def started
    @timer = NSTimer.scheduledTimerWithTimeInterval(@@max_time, target: self, selector: 'stop_timer_fired', userInfo: nil, repeats: true)
  end

  def finished
    @timer.invalidate if @timer
  end

  def stop_timer_fired
    @delegate.stop
  end
end
