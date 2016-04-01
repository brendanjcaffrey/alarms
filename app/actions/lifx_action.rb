class LifxAction < Action
  MAX_BRIGHTNESS    = 65535
  MAX_KELVINS       = 6000
  NORMAL_BRIGHTNESS = 26214
  NORMAL_KELVINS    = 4500

  def prestarted(seconds_until_started)
    finished if @fd || @tick_timer

    @tick = 0
    @total_ticks = seconds_until_started.floor
    @fd = lifx_lan_open_socket

    # turn lights off, set to super low color, then turn lights on
    lifx_lan_lights_off(@fd, 254)
    lifx_lan_set_color(@fd, 255, 0, 0, 0, MAX_KELVINS, 0)
    lifx_lan_lights_on(@fd, 0)

    @tick_timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
      selector: 'tick_timer_fired:', userInfo: nil, repeats: true)
  end

  def finished
    stop_ticking
    return unless @fd

    lifx_lan_set_color(@fd, 127, 0, 0, NORMAL_BRIGHTNESS, NORMAL_KELVINS, 0)
    lifx_lan_close_socket(@fd)
    @fd = nil
  end

  def tick_timer_fired(sender)
    @tick += 1

    fractional_tick = (@tick * 1.0) / @total_ticks
    brightness = fractional_tick * MAX_BRIGHTNESS

    lifx_lan_set_color(@fd, @tick % 255, 0, 0, brightness, MAX_KELVINS, 0)
    stop_ticking if @tick >= @total_ticks
  end

  private

  def stop_ticking
    @tick_timer.invalidate if @tick_timer
    @tick_timer = nil
  end
end
