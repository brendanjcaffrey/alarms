class LightsController
  def turn_high
    lifx_lan_set_color(0, 0, 65535, 6000)
  end

  def turn_normal
    lifx_lan_set_color(9830, 23592, 55704, 3000)
  end

  def turn_off
    lifx_lan_lights_off
  end
end
