describe LeapMotionTalker do
  it 'should start listening when it receives the appropriate message, send a message when it receives a gesture and close when it receives the stop message' do
    socket_stub = Object.new
    socket_stub.mock!(:delegate=) { |obj| obj.should != nil }
    socket_stub.mock!(:open)
    socket_stub.mock!(:send) { |data| data.should == '{"enableGestures":true}' }
    socket_stub.mock!(:close)

    initial_stub = stub(:initWithURLRequest) { |url| socket_stub }
    SRWebSocket.mock!(:alloc, return: initial_stub)

    delegate = mock(:did_gesture)
    talker = LeapMotionTalker.new
    talker.set_delegate(delegate)
    talker.start_talking

    talker.webSocketDidOpen(socket_stub)
    json = '{"gestures":"hi"}'
    talker.webSocket(socket_stub, didReceiveMessage:json)

    talker.stop_talking
  end
end
