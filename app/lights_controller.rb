class LightsController
  def initialize
    @context = LFXClient.sharedClient.localNetworkContext
    @context.allLightsCollection.addLightCollectionObserver(self)

    @control = nil
    @color = LFXHSBKColor.whiteColorWithBrightness(1.0, kelvin:6000)
  end

  def lightCollection(collection, didAddLight:light)
    set_light_state(light, @control) if @control != nil
  end

  def turn_on
    control(LFXPowerStateOn)
  end

  def turn_off
    control(LFXPowerStateOff)
  end

  def clear_control
    @control = nil
  end

  private
  def control(power_state)
    @timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target:self, selector:'clear_control', userInfo:nil, repeats:false)

    @control = power_state
    @context.allLightsCollection.each { |light| set_light_state(light, power_state) }
  end

  def set_light_state(lifx_light, state)
    lifx_light.setPowerState(state)
    lifx_light.setColor(@color) if state == LFXPowerStateOn
  end
end
