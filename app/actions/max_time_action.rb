class MaxTimeAction < Action
  MAX_TIME_SECONDS = 120

  def started
    @timer = NSTimer.scheduledTimerWithTimeInterval(MAX_TIME_SECONDS, target: self,
      selector: 'stop_timer_fired', userInfo: nil, repeats: false)
  end

  def finished
    @timer.invalidate if @timer
    @timer = nil
  end

  def stop_timer_fired
    @delegate.stop
  end
end
