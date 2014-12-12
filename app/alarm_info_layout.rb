class AlarmInfoLayout < MotionKit::WindowLayout
  include SharedStyles

  @@date_width = 210.0
  @@time_width = 173.0
  @@icon_width = 30.0

  @@edge_spacing = 8.0
  @@picker_spacing = 4.0
  @@button_spacing = 11.0

  @@width = @@edge_spacing*4.0 + @@picker_spacing*2.0 + @@date_width + @@time_width + @@icon_width
  @@button_width = (@@width - @@edge_spacing*2.0 - @@button_spacing*2.0) / 3.0

  @@picker_height = 75.0
  @@button_height = 45.0
  @@icon_height = @@icon_width + (54.0-@@icon_width)/2.0
  @@height = @@picker_height + @@button_height + @@edge_spacing*3.0

  view :time, :date, :icon
  view :delete, :cancel, :submit
  view :visual_effect

  def init_with_alarm(alarm)
    @alarm = alarm
    init
  end

  def datePickerCell(cell, validateProposedDateValue:date, timeInterval:time)
    date[0] = controller.validate_date(date[0]) if @date != nil && cell == @date.cell
    controller.time_updated(date[0]) if @time != nil && cell == @time.cell
  end

  def layout
    frame [[0, 0], [@@width, @@height]]
    styleMask NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
    level NSPopUpMenuWindowLevel

    add NSVisualEffectView, :visual_effect do
      @date = add NSDatePicker, :date
      @time = add NSDatePicker, :time
      @icon = add NSImageView, :icon

      @delete = add NSButton, :delete
      @cancel = add NSButton, :cancel
      @submit = add NSButton, :submit
    end
  end

  def visual_effect_style
    material NSVisualEffectMaterialLight
    blending_mode NSVisualEffectBlendingModeBehindWindow
    state NSVisualEffectStateActive

    constraints do
      width.equals(:superview)
      height.equals(:superview)
    end
  end

  def date_style
    date_picker_elements NSYearMonthDayDatePickerElementFlag
    min_date NSDate.date
    date_picker_style

    constraints do
      left.equals(:superview).plus(@@edge_spacing*2.0)
    end
  end

  def time_style
    date_picker_elements NSHourMinuteDatePickerElementFlag
    date_picker_style

    constraints do
      left.equals(:date, :right).plus(@@picker_spacing)
    end
  end

  def icon_style
    constraints do
      top.equals(:superview).plus(@@edge_spacing + 6.0)
      right.equals(:superview).minus(@@edge_spacing*2.0 + 2.5)
      width(@@icon_width)
      height(@@icon_height)
    end
  end

  def submit_style
    title 'Submit'
    key_equivalent "\r" # return
    button_style

    constraints do
      right.equals(:superview).minus(@@edge_spacing)
    end
  end

  def cancel_style
    title 'Cancel'
    key_equivalent "\E" # escape
    button_style

    constraints do
      center_x.equals(:superview)
    end
  end

  def delete_style
    title 'Delete'
    key_equivalent "\b" # delete
    enabled @alarm != nil
    button_style

    constraints do
      left.equals(:superview).plus(@@edge_spacing)
    end
  end

  private

  def controller
    window.windowController
  end

  def date_picker_style
    top_row_style
    delegate self
    bezeled false
    setDatePickerStyle NSTextFieldDatePickerStyle

    date_value (@alarm != nil ? @alarm : NSDate).date
    cell.setFont(text_font)
  end

  def top_row_style
    constraints do
      top.equals(:superview).plus(@@edge_spacing)
    end
  end

  def button_style
    default_button_style

    constraints do
      width @@button_width
      height @@button_height
      bottom.equals(:superview).minus(@@edge_spacing)
    end
  end
end
