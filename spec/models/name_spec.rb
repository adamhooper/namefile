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

  describe('data_set_results') do
    it('should find all data set results for a popular name') do
      results = Name.new(:last_name => 'Tremblay').data_set_results

      results.length.should == 3

      results[0][:key].should === :quebec_top1000_ranking
      results[0][:data][:rank].should_not(be_nil) # it's not a Hash, but it behaves like one
      results[0][:points].should > 0

      results[1][:key].should == :orders_of_canada
      Array.should === results[1][:data]
      results[1][:points].should > 0

      results[2][:key].should == :stanley_cup_winners
      Array.should === results[2][:data]
      results[2][:points].should > 0
    end

    it('should return an empty list when there is no data') do
      Name.new(:last_name => 'asdgSDfsdfASDfsd sDSF').data_set_results.should == []
    end
  end

  describe('total_points') do
    it('should return 0 if the name is not found') do
      Name.new(:last_name => 'SDfnskdjfadfSDfsdf Sf').points.should == 0
    end

    it('should return >0 if the name is found') do
      Name.new(:last_name => 'Tremblay').points.should > 0
    end
  end
end
