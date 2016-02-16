describe LeapMotionAction do
  it 'should start listening when it receives the appropriate message, send a message when it receives a gesture and close when it receives the stop message' do
    socket_stub = Object.new
    socket_stub.mock!(:delegate=) { |obj| obj.should != nil }
    socket_stub.mock!(:open)
    socket_stub.mock!(:send) { |data| data.should == '{"enableGestures":true}' }
    socket_stub.mock!(:close)

    initial_stub = stub(:initWithURLRequest) { |url| socket_stub }
    SRWebSocket.mock!(:alloc, return: initial_stub)

    timer_stub = mock(:invalidate)
    NSTimer.mock!('scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:') { |_, _, _, _, _| timer_stub}

    delegate = mock(:pause)
    action = LeapMotionAction.new
    action.set_delegate(delegate)
    action.started

    action.webSocketDidOpen(socket_stub)
    json = '{"gestures":"hi"}'
    action.webSocket(socket_stub, didReceiveMessage: json)

    action.finished
  end
end
