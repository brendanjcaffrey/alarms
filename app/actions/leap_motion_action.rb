class LeapMotionAction < Action
  SILENCE_SECONDS = 15.0

  def started
    finished if @socket || @unpause_timer

    url = NSURL.URLWithString('ws://127.0.0.1:6437')
    @socket = SRWebSocket.alloc.initWithURLRequest(NSURLRequest.requestWithURL(url))
    @socket.delegate = self
    @socket.open
  end

  def finished
    @socket.close if @socket
    @unpause_timer.invalidate if @unpause_timer
    @unpause_timer = @socket = nil
  end

  def unpause_timer_fired(sender)
    @delegate.unpause
  end


  def webSocketDidOpen(webSocket)
    return unless @socket

    data = '{"enableGestures":true}'
    @socket.send(data)
  end

  def webSocket(webSocket, didReceiveMessage: message)
    return unless @socket

    error_ptr = Pointer.new(:object)
    parsed = BW::JSON.parse(message.description)

    if parsed.nil?
      error = error_ptr[0]
      puts error.userInfo[NSLocalizedDescriptionKey]
    else
      return if parsed['gestures'].nil? or parsed['gestures'].empty?
      @delegate.pause
      return if @unpause_timer
      @unpause_timer = NSTimer.scheduledTimerWithTimeInterval(SILENCE_SECONDS, target: self, selector: 'unpause_timer_fired:',
                                                              userInfo: nil, repeats: false)
    end
  end

  def webSocket(webSocket, didFailWithError: error)
  end

  def webSocket(webSocket, didCloseWithCode: code, reason: _)
  end
end
