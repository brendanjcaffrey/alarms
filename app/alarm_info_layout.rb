class AlarmInfoLayout < MotionKit::WindowLayout
  @@date_width = 229.0
  @@time_width = 191.5
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

  @@font_size = 40.0

  view :time, :date
  view :delete, :cancel, :submit

  def init_with_alarm(alarm)
    @alarm = alarm
    init
  end

  def layout
    frame [[0, 0], [@@width, @@height]]
    styleMask NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
    level NSPopUpMenuWindowLevel
    title @alarm.nil? ? 'Add Alarm' : 'Edit Alarm'

    @date = add NSDatePicker, :date
    @time = add NSDatePicker, :time
    @icon = add NSImageView, :icon

    @delete = add NSButton, :delete
    @cancel = add NSButton, :cancel
    @submit = add NSButton, :submit
  end

  def date_style
    set_date_picker_style
    min_date NSDate.date
    date_picker_elements NSYearMonthDayDatePickerElementFlag

    constraints do
      left.equals(:superview).plus(@@edge_spacing*2.0)
    end
  end

  def time_style
    set_date_picker_style
    date_picker_elements NSHourMinuteDatePickerElementFlag
    delegate self

    constraints do
      left.equals(:date, :right).plus(@@picker_spacing)
    end
  end

  def icon_style
    set_top_row_style
    image image_for_time(Time.new)

    constraints do
      right.equals(:superview).minus(@@edge_spacing*2.0)
      width(@@icon_width)
      height(@@icon_height)
    end
  end

  def submit_style
    title 'Submit'
    key_equivalent "\r" # return
    set_button_style

    constraints do
      right.equals(:superview).minus(@@edge_spacing)
    end
  end

  def cancel_style
    title 'Cancel'
    key_equivalent "\E" # escape
    set_button_style

    constraints do
      center_x.equals(:superview)
    end
  end

  def delete_style
    title 'Delete'
    key_equivalent "\b" # delete
    set_button_style
    enabled @alarm != nil

    constraints do
      left.equals(:superview).plus(@@edge_spacing)
    end
  end

  def datePickerCell(cell, validateProposedDateValue:date, timeInterval:time)
    @icon.image = image_for_time(date[0])
  end

  private

  def image_for_time(time)
    if time.hour < 6 or time.hour >= 18
      NSImage.imageNamed 'moon'
    else
      NSImage.imageNamed 'sun'
    end
  end

  def set_date_picker_style
    date_value @alarm != nil ? @alarm.date : NSDate.date
    bezeled false
    cell.setFont(NSFont.fontWithName('Helvetica Neue Thin', size:@@font_size))
    set_top_row_style
  end

  def set_top_row_style
    constraints do
      top.equals(:superview).plus(@@edge_spacing)
    end
  end

  def set_button_style
    bezel_style NSRegularSquareBezelStyle
    button_type NSMomentaryPushInButton

    constraints do
      width @@button_width
      height @@button_height
      bottom.equals(:superview).minus(@@edge_spacing)
    end
  end
end
