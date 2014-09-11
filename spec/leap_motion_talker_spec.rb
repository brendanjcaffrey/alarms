describe LeapMotionTalker do
  it 'should start listening when it receives the appropriate message, send a message when it receives a gesture and close when it receives the stop message' do
    @received = false
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'receiveNotification:', name:LeapMotionTalker.did_gesture_message, object:nil)

    socket_stub = Object.new
    socket_stub.mock!(:delegate=) { |obj| obj.should != nil }
    socket_stub.mock!(:open)
    socket_stub.mock!(:send) { |data| data.should == '{"enableGestures":true}' }
    socket_stub.mock!(:close)

    initial_stub = stub(:initWithURLRequest) { |url| socket_stub }
    SRWebSocket.mock!(:alloc, return: initial_stub)

    talker = LeapMotionTalker.new
    NSNotificationCenter.defaultCenter.postNotificationName(LeapMotionTalker.start_talking_message, object:self)

    talker.webSocketDidOpen(socket_stub)
    json = '{"gestures":"hi"}'
    talker.webSocket(socket_stub, didReceiveMessage:json)

    NSNotificationCenter.defaultCenter.postNotificationName(LeapMotionTalker.stop_talking_message, object:self)
    @received.should == true
  end

  def receiveNotification(notification)
    @received = true
  end
end
