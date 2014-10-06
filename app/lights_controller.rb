class LightsController
  def turn_on
    control(true)
  end

  def turn_off
    control(false)
  end

  private
  def control(on)
    Thread.new do
      command = 'sshpass -praspberry ssh pi@raspberrypi.local "bash --login -c \\"./lights_' + (on ? 'on' : 'off') + '\\""'
      system(command)
    end
  end
end
