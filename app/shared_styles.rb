module SharedStyles
  @@font_size = 40.0

  def text_font
    NSFont.fontWithName('Helvetica Neue Thin', size:@@font_size)
  end

  def default_button_style
    bezel_style NSRegularSquareBezelStyle
    button_type NSMomentaryPushInButton
  end
end
