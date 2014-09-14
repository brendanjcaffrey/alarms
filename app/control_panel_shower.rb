class ControlPanelShower
  def show_control_panel(delegate)
    hide_control_panel if @panel

    @panel = ControlPanelController.alloc.init_with_delegate(delegate)
    center_panel
    @panel.showWindow(self)
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)
  end

  def hide_control_panel
    return unless @panel

    @panel.close_window
    @panel = nil
  end

  private

  def center_panel
    screen_size = @panel.window.screen.frame.size
    window_size = @panel.window.frame.size
    x = screen_size.width/2.0 - window_size.width/2.0
    y = screen_size.height/2.0 - window_size.height/2.0
    @panel.window.setFrame(NSMakeRect(x, y, window_size.width, window_size.height), display:true)
  end
end
