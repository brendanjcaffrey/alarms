class LightsController
  def initialize
    @context = LFXClient.sharedClient.localNetworkContext
    @context.allLightsCollection.addLightCollectionObserver(self)

    @state = nil
    @high_color = LFXHSBKColor.whiteColorWithBrightness(1.0, kelvin:6000)
    @normal_color = LFXHSBKColor.whiteColorWithBrightness(0.4, kelvin:4500)
  end

  def lightCollection(collection, didAddLight:light)
    set_light_state(light, @state) if @state != nil
  end

  def turn_high
    control(LFXPowerStateOn, @high_color)
  end

  def turn_normal
    control(LFXPowerStateOn, @normal_color)
  end

  def turn_off
    control(LFXPowerStateOff)
  end

  def clear_control
    @state = @color = nil
  end

  private
  def control(power_state, color = nil)
    @timer.invalidate if @timer
    @timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target:self, selector:'clear_control', userInfo:nil, repeats:false)

    @state = power_state
    @color = color
    @context.allLightsCollection.each { |light| set_light_state(light) }
  end

  def set_light_state(lifx_light)
    lifx_light.setPowerState(@state)
    lifx_light.setColor(@color) if @state == LFXPowerStateOn && @color != nil
  end
end
