class Date
  attr_reader :date
end

describe Date do
  it 'should initialize to the right day' do
    ns_date = Date.new(2016, 1, 31).date
    ns_date.year.should == 2016
    ns_date.month.should == 1
    ns_date.day.should == 31
  end

  it 'should wrap around months' do
    ns_date = Date.new(2016, 1, 32).date
    ns_date.year.should == 2016
    ns_date.month.should == 2
    ns_date.day.should == 1
  end

  it 'should get today correctly' do
    today = NSDate.date
    date = Date.today.date
    today.year.should == date.year
    today.month.should == date.month
    today.day.should == date.day
  end

  it 'should wrap around correctly' do
    Date.new(2016, 1, 32).is_same_day_as(Date.new(2016, 2, 1).date).should == true
  end
end
