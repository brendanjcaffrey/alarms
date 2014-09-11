class LeapMotionTalker
  @start_talking_message = 'LeapMotionTalkerStartTalkingMessage'
  @stop_talking_message = 'LeapMotionTalkerStopTalkingMessage'
  @did_gesture_message = 'LeapMotionTalkerDidRecognizeGestureMessage'

  class << self
    attr_reader :start_talking_message, :stop_talking_message, :did_gesture_message
  end

  def initialize
    center = NSNotificationCenter.defaultCenter
    center.addObserver(self, selector:'start_talking:', name:LeapMotionTalker.start_talking_message, object:nil)
    center.addObserver(self, selector:'stop_talking:', name:LeapMotionTalker.stop_talking_message, object:nil)
  end

  def start_talking(notification)
    url = NSURL.URLWithString('ws://127.0.0.1:6437')
    @socket = SRWebSocket.alloc.initWithURLRequest(NSURLRequest.requestWithURL(url))
    @socket.delegate = self
    @socket.open
  end

  def stop_talking(notification)
    @socket.close
  end

  def webSocketDidOpen(webSocket)
    data = '{"enableGestures":true}'
    @socket.send(data)
  end

  def webSocket(webSocket, didReceiveMessage:message)
    error_ptr = Pointer.new(:object)
    parsed = message.description.objectFromJSONStringWithParseOptions(JKParseOptionValidFlags, error:error_ptr)

    if parsed.nil?
      error = error_ptr[0]
      puts error.userInfo[NSLocalizedDescriptionKey]
    else
      return if parsed['gestures'].nil? or parsed['gestures'].empty?
      NSNotificationCenter.defaultCenter.postNotificationName(LeapMotionTalker.did_gesture_message, object:self)
    end
  end

  def webSocket(webSocket, didFailWithError:error)
  end

  def webSocket(webSocket, didCloseWithCode:code,reason:reason)
  end
end
