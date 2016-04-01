module SharedStyles
  FONT_SIZE = 40.0

  def text_font
    NSFont.fontWithName('Helvetica Neue Thin', size: FONT_SIZE)
  end

  def default_button_style
    bezel_style NSRegularSquareBezelStyle
    button_type NSMomentaryPushInButton
  end
end
