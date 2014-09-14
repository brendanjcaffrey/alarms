class ControlPanelLayout < MotionKit::WindowLayout
  @@width = 300.0
  @@text_height = 75.0
  @@button_height = 45.0
  @@edge_spacing = 8.0
  @@font_size = 40.0
  @@height = @@text_height + @@button_height + @@edge_spacing*3.0
  @@button_width = (@@width - @@edge_spacing*3.0) / 2.0

  view :time
  view :snooze, :stop

  def layout
    frame [[0, 0], [@@width, @@height]]
    styleMask NSBorderlessWindowMask 
    level NSPopUpMenuWindowLevel

    @time = add NSTextField, :time
    @snooze = add NSButton, :snooze
    @stop = add NSButton, :stop
  end

  def time_style
    string_value '12:00:00 pm'
    bezeled false
    draws_background false
    editable false
    selectable false
    font NSFont.fontWithName('Helvetica Neue Thin', size:@@font_size)

    constraints do
      center_x.equals(:superview)
      top.equals(:superview).plus(@@edge_spacing)
      height @@text_height
    end
  end

  def snooze_style
    title 'Snooze'
    button_style

    constraints do
      right.equals(:superview).minus(@@edge_spacing)
    end
  end

  def stop_style
    title 'Stop'
    button_style

    constraints do
      left.equals(:superview).plus(@@edge_spacing)
    end
  end

  private

  def button_style
    bezel_style NSRegularSquareBezelStyle
    button_type NSMomentaryPushInButton

    constraints do
      width @@button_width
      height @@button_height
      bottom.equals(:superview).minus(@@edge_spacing)
    end
  end
end
