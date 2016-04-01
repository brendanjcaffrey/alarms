class ControlPanelLayout < MotionKit::WindowLayout
  include SharedStyles

  WIDTH         = 300.0
  TEXT_HEIGHT   = 75.0
  BUTTON_HEIGHT = 45.0
  EDGE_SPACING  = 8.0
  HEIGHT        = TEXT_HEIGHT + BUTTON_HEIGHT + EDGE_SPACING*3.0
  BUTTON_WIDTH  = (WIDTH - EDGE_SPACING*3.0) / 2.0

  view :time_field
  view :snooze, :stop

  def layout
    frame [[0, 0], [WIDTH, HEIGHT]]
    styleMask NSBorderlessWindowMask
    level NSPopUpMenuWindowLevel

    @time_field = add NSTextField, :time_field
    @snooze = add NSButton, :snooze
    @stop = add NSButton, :stop
  end

  def time_field_style
    string_value '12:00:00 pm'
    bezeled false
    draws_background false
    editable false
    selectable false
    font text_font

    constraints do
      center_x.equals(:superview)
      top.equals(:superview).plus(EDGE_SPACING)
      height TEXT_HEIGHT
    end
  end

  def snooze_style
    title 'Snooze'
    button_style

    constraints do
      right.equals(:superview).minus(EDGE_SPACING)
    end
  end

  def stop_style
    title 'Stop'
    button_style

    constraints do
      left.equals(:superview).plus(EDGE_SPACING)
    end
  end

  private

  def button_style
    default_button_style

    constraints do
      width BUTTON_WIDTH
      height BUTTON_HEIGHT
      bottom.equals(:superview).minus(EDGE_SPACING)
    end
  end
end
