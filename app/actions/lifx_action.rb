class LifxAction < Action
  @@final_brightness = 26214
  @@kelvins = 0

  def prestarted(seconds_until_started)
    finished if @fd || @tick_timer

    @tick = 0
    @total_ticks = seconds_until_started.floor
    @fd = lifx_lan_open_socket

    # turn lights off, set to super low color, then turn lights on
    lifx_lan_lights_off(@fd, 254)
    lifx_lan_set_color(@fd, 255, 0, 0, 0, @@kelvins, 0)
    lifx_lan_lights_on(@fd, 0)

    @tick_timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
      selector: 'tick_timer_fired:', userInfo: nil, repeats: true)
  end

  def finished
    lifx_lan_close_socket(@fd) if @fd
    @tick_timer.invalidate if @tick_timer
    @fd = @tick_timer = nil
  end

  def tick_timer_fired(sender)
    @tick += 1

    fractional_tick = (@tick * 1.0) / @total_ticks
    brightness = fractional_tick * @@final_brightness

    lifx_lan_set_color(@fd, @tick % 255, 0, 0, brightness, @@kelvins, 0)
    finished if @tick >= @total_ticks
  end
end
