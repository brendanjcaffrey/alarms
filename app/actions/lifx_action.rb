class LifxAction < Action
  def started
    lifx_lan_set_color(0, 0, 65535, 6000)
  end
end
