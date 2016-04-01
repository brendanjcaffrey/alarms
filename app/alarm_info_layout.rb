class AlarmInfoLayout < MotionKit::WindowLayout
  include SharedStyles

  DATE_WIDTH = 210.0
  TIME_WIDTH = 173.0
  ICON_WIDTH = 30.0

  EDGE_SPACING   = 8.0
  PICKER_SPACING = 4.0
  BUTTON_SPACING = 11.0

  WIDTH        = EDGE_SPACING*4.0 + PICKER_SPACING*2.0 + DATE_WIDTH + TIME_WIDTH + ICON_WIDTH
  BUTTON_WIDTH = (WIDTH - EDGE_SPACING*2.0 - BUTTON_SPACING*2.0) / 3.0

  PICKER_HEIGHT = 75.0
  BUTTON_HEIGHT = 45.0
  ICON_HEIGHT   = ICON_WIDTH + (54.0-ICON_WIDTH)/2.0
  HEIGHT        = PICKER_HEIGHT + BUTTON_HEIGHT + EDGE_SPACING*3.0

  view :time_field, :date_field, :icon
  view :delete, :cancel, :submit
  view :visual_effect

  def init_with_alarm(alarm)
    @alarm = alarm
    init
  end

  def datePickerCell(cell, validateProposedDateValue:date, timeInterval:time)

    date[0] = controller.validate_date(date[0]) if @date_field != nil && cell == @date_field.cell
    controller.time_updated(date[0]) if @time_field != nil && cell == @time_field.cell
  end

  def layout
    frame [[0, 0], [WIDTH, HEIGHT]]
    styleMask NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask

    # NOTE: raising this level will make the invalid time alert pop up behind the window
    level NSTornOffMenuWindowLevel

    add NSVisualEffectView, :visual_effect do
      @date_field = add NSDatePicker, :date_field
      @time_field = add NSDatePicker, :time_field
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

  def date_field_style
    date_picker_elements NSYearMonthDayDatePickerElementFlag
    min_date NSDate.date
    date_picker_style

    constraints do
      left.equals(:superview).plus(EDGE_SPACING*2.0)
    end
  end

  def time_field_style
    date_picker_elements NSHourMinuteDatePickerElementFlag
    date_picker_style

    constraints do
      left.equals(:date_field, :right).plus(PICKER_SPACING)
    end
  end

  def icon_style
    constraints do
      top.equals(:superview).plus(EDGE_SPACING + 6.0)
      right.equals(:superview).minus(EDGE_SPACING*2.0 + 2.5)
      width(ICON_WIDTH)
      height(ICON_HEIGHT)
    end
  end

  def submit_style
    title 'Submit'
    key_equivalent "\r" # return
    button_style

    constraints do
      right.equals(:superview).minus(EDGE_SPACING)
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
      left.equals(:superview).plus(EDGE_SPACING)
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
      top.equals(:superview).plus(EDGE_SPACING)
    end
  end

  def button_style
    default_button_style

    constraints do
      width BUTTON_WIDTH
      height BUTTON_HEIGHT
      bottom.equals(:superview).minus(EDGE_SPACING)
    end
  end
end
