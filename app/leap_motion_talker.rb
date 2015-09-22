class LeapMotionTalker
  def start_talking(delegate)
    @delegate = WeakRef.new(delegate)

    url = NSURL.URLWithString('ws://127.0.0.1:6437')
    @socket = SRWebSocket.alloc.initWithURLRequest(NSURLRequest.requestWithURL(url))
    @socket.delegate = self
    @socket.open
  end

  def stop_talking
    @socket.close
    @delegate = nil
  end

  def webSocketDidOpen(webSocket)
    data = '{"enableGestures":true}'
    @socket.send(data)
  end

  def webSocket(webSocket, didReceiveMessage:message)
    return unless @delegate

    error_ptr = Pointer.new(:object)
    parsed = BW::JSON.parse(message.description)

    if parsed.nil?
      error = error_ptr[0]
      puts error.userInfo[NSLocalizedDescriptionKey]
    else
      return if parsed['gestures'].nil? or parsed['gestures'].empty?
      @delegate.did_gesture
    end
  end

  def webSocket(webSocket, didFailWithError:error)
  end

  def webSocket(webSocket, didCloseWithCode:code, reason:_)
  end
end
