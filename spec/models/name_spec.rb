require 'spec_helper'

describe(Name) do
  it('should find Orders of Canada') do
    orders = Name.new(:last_name => 'Tremblay').orders_of_canada
    orders.length.should >= 13
    orders.first[:full_name].should == 'Adine Tremblay'
    orders.first[:city].should == 'Ottawa, Ontario'
    orders.first[:award].should == 'Order of Canada'
  end

  it('should find Stanley Cup winners') do
    winners = Name.new(:last_name => 'Tremblay').stanley_cup_winners
    winners.length.should >= 3
    winners.first[:full_name].should == 'Gilles Tremblay'
  end

  it('should find Quebec Top 1000 rankings') do
    ranking = Name.new(:last_name => 'Tremblay').quebec_top1000_ranking
    ranking[:rank].should == 1
    ranking[:approximate_population].should == 81000
  end
end
