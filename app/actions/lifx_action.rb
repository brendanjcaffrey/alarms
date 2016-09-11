class LifxAction < Action
  MAX_BRIGHTNESS    = 65535
  MAX_KELVINS       = 6000
  NORMAL_BRIGHTNESS = 26214
  NORMAL_KELVINS    = 4500
  LIGHT_IDS         = [39977586357200, 135995858449360, 51926218929104]

  def prestarted(seconds_until_started)
    finished if @fd || @tick_timer

    @seqnum = 0
    @tick = 0
    @total_ticks = seconds_until_started.floor
    @fd = lifx_lan_open_socket

    # turn lights off, set to super low color, then turn lights on
    LIGHT_IDS.each do |id|
      lifx_lan_lights_off(@fd, next_seqnum, id)
      lifx_lan_set_color(@fd, next_seqnum, id, 0, 0, 0, MAX_KELVINS, 0)
      lifx_lan_lights_on(@fd, next_seqnum, id)
    end

    @tick_timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
      selector: 'tick_timer_fired:', userInfo: nil, repeats: true)
  end

  def finished
    stop_ticking
    return unless @fd

    LIGHT_IDS.each do |id|
      lifx_lan_set_color(@fd, next_seqnum, id, 0, 0, NORMAL_BRIGHTNESS, NORMAL_KELVINS, 0)
    end

    lifx_lan_close_socket(@fd)
    @fd = nil
  end

  def tick_timer_fired(sender)
    @tick += 1

    fractional_tick = (@tick * 1.0) / @total_ticks
    brightness = fractional_tick * MAX_BRIGHTNESS

    LIGHT_IDS.each do |id|
      lifx_lan_set_color(@fd, next_seqnum, id, 0, 0, brightness, MAX_KELVINS, 0)
    end

    stop_ticking if @tick >= @total_ticks
  end

  private

  def stop_ticking
    @tick_timer.invalidate if @tick_timer
    @tick_timer = nil
  end

  def next_seqnum
    @seqnum += 1
    @seqnum = 0 if @seqnum > 255
    @seqnum
  end
end
