class LifxAction < Action
  MAX_BRIGHTNESS = 65535
  MAX_KELVINS    = 6000
  LIGHT_IDS      = [130107726722000]

  def started
    @seqnum = 0
    fd = lifx_lan_open_socket

    # turn lights off, set to super low color, then turn lights on
    LIGHT_IDS.each do |id|
      lifx_lan_lights_off(fd, next_seqnum, id)
      lifx_lan_set_color(fd, next_seqnum, id, 0, 0, MAX_BRIGHTNESS, MAX_KELVINS, 0)
      lifx_lan_lights_on(fd, next_seqnum, id)
    end

    lifx_lan_close_socket(fd)
  end

  private

  def next_seqnum
    @seqnum += 1
    @seqnum = 0 if @seqnum > 255
    @seqnum
  end
end
