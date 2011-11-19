require 'spec_helper'

describe(OrderOfCanadaDirectory) do
  # This uses the real database in db/order-of-canada.csv
  it('should find an existing name with one entry') do
    OrderOfCanadaDirectory.instance.awards_for_last_name('Abbey').should == [
      { :name => 'Monroe Abbey', :city => 'Montréal, Quebec', :award => 'Order of Canada' }
    ]
  end

  it('should find an existing name with multiple entries') do
    OrderOfCanadaDirectory.instance.awards_for_last_name('Andrews').should == [
      { :name => 'Gerald Smedley Andrews', :city => 'Victoria, British Columbia', :award => 'Order of Canada' },
      { :name => 'Ralph LeMoine Andrews', :city => "St. John's, Newfoundland and Labrador", :award => 'Order of Canada' }
    ]
  end

  it('should return nil when the name is not found') do
    OrderOfCanadaDirectory.instance.awards_for_last_name('Blaksdfashd').should == nil
  end
end
