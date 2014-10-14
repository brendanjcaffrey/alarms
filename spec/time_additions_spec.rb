describe Time do
  it 'should return tomorrow\'s date at the same time for tomorrow' do
    now = Time.utc(2014, 10, 1, 11, 05, 10)
    NSDate.mock!(:date, return: now)
    tomorrow = Time.tomorrow

    now.year.should == tomorrow.year
    now.month.should == tomorrow.month
    now.day.should.not == tomorrow.day
  end

  it 'should return true only when two Times have the same year, month and day for same_day?' do
    Time.new(2014, 10, 1).same_day?(Time.now(2014, 10, 1)).should == true
    Time.new(2014, 10, 1).same_day?(Time.now(2013, 10, 1)).should == false
    Time.new(2014, 10, 1).same_day?(Time.now(2014, 11, 1)).should == false
    Time.new(2014, 10, 1).same_day?(Time.now(2014, 10, 2)).should == false
  end

  it 'should return true if the left hour is less than or the hours are the same and the left minute is less than for hour_and_minute_less_than' do
    times = [Time.new(2014, 10, 1, 10, 05),
             Time.new(2014, 10, 1, 11, 05),
             Time.new(2014, 10, 1, 11, 06)]

    times[0].hour_and_minute_less_than?(times[1]).should == true
    times[1].hour_and_minute_less_than?(times[2]).should == true
    times[0].hour_and_minute_less_than?(times[2]).should == true

    times[2].hour_and_minute_less_than?(times[0]).should == false
    times[2].hour_and_minute_less_than?(times[1]).should == false
    times[1].hour_and_minute_less_than?(times[0]).should == false
    times[0].hour_and_minute_less_than?(times[0]).should == false
  end
end
