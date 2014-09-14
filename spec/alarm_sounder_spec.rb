describe AlarmSounder do
  before do
    @delegate_mock = Object.new
    @player_mock = Object.new
    @talker_mock = Object.new
    @talker_mock.stub!(:set_delegate) { |delegate| nil }
    @sounder = AlarmSounder.new(@delegate_mock, @player_mock, @talker_mock)
  end

  it 'should schedule a timer with the number of seconds to the alarm date' do
    alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    NSTimer.mock!('scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:') do |int, tar, sel, ui, r|
      int.should.be.close 10.0, 0.1
    end
    @sounder.set_next_alarm(alarm)
  end

  it 'should invalidate the old timer' do
    alarm1 = Alarm.new(NSDate.date.dateByAddingTimeInterval(10))
    alarm2 = Alarm.new(NSDate.date.dateByAddingTimeInterval(15))
    timer_mock = mock(:invalidate)

    NSTimer.mock!('scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:') do |int, tar, sel, ui, r|
      timer_mock
    end

    @sounder.set_next_alarm(alarm1)
    @sounder.set_next_alarm(alarm2)
  end

  it 'should start leap motion tracking and start playing audio on timer fire' do
    @player_mock.mock!(:play)
    @talker_mock.mock!(:start_talking)
    @sounder.fired(nil)
  end

  it 'should stop leap motion tracking, stop playing audio and delete the alarm on gesture' do
    @player_mock.mock!(:stop)
    @talker_mock.mock!(:stop_talking)
    @delegate_mock.mock!(:alarm_deleted) { |alarm| alarm.should == @alarm }

    @alarm = Alarm.new(NSDate.date.dateByAddingTimeInterval(5))
    @sounder.instance_variable_set(:@alarm, @alarm)
    @sounder.did_gesture
  end
end
