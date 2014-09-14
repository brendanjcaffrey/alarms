class AlarmInfoLayout < MotionKit::WindowLayout
  @@edge_spacing = 16
  @@picker_spacing = 4
  @@button_spacing = 11

  view :time, :date
  view :delete, :cancel, :submit

  def init_with_alarm(alarm)
    @alarm = alarm
    init
  end

  def layout
    frame [[0, 0], [232, 115]]
    styleMask NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
    level NSPopUpMenuWindowLevel

    @date = add NSDatePicker, :date
    @icon = add NSImageView, :icon
    @time = add NSDatePicker, :time

    @submit = add NSButton, :submit
    @cancel = add NSButton, :cancel
    @delete = add NSButton, :delete
  end

  def date_style
    set_date_picker_date
    min_date NSDate.date
    date_picker_elements NSYearMonthDayDatePickerElementFlag

    constraints do
      bottom.equals(:submit, :top).minus(@@edge_spacing)
      right.equals(:time, :left).minus(@@picker_spacing)
    end
  end

  def time_style
    set_date_picker_date
    date_picker_elements NSHourMinuteDatePickerElementFlag
    delegate self

    constraints do
      bottom.equals(:date)
      right.equals(:icon, :left).minus(@@picker_spacing)
    end
  end

  def icon_style
    image image_for_time(Time.new)
    size_to_fit

    constraints do
      bottom.equals(:date).minus(2)
      right.equals(:superview).minus(@@edge_spacing)
    end
  end

  def submit_style
    title 'Submit'
    key_equivalent "\r" # return
    set_button_style

    constraints do
      bottom.equals(:superview).minus(@@edge_spacing)
      right.equals(:icon)
    end
  end

  def cancel_style
    title 'Cancel'
    key_equivalent "\E" # escape
    set_button_style

    constraints do
      bottom.equals(:submit)
      right.equals(:submit, :left).minus(@@button_spacing)
    end
  end

  def delete_style
    title 'Delete'
    key_equivalent "\b" # delete
    set_button_style
    enabled @alarm != nil

    constraints do
      bottom.equals(:submit)
      right.equals(:cancel, :left).minus(@@button_spacing)
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

  def set_date_picker_date
    date_value @alarm != nil ? @alarm.date : NSDate.date
  end

  def set_button_style
    size_to_fit
    bezel_style NSRegularSquareBezelStyle
    button_type NSMomentaryPushInButton
  end
end
