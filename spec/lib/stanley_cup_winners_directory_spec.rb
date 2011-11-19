require 'spec_helper'

describe(StanleyCupWinnersDirectory) do
  # This uses the real database in db/stanley-cup-winners.csv
  it('should find an existing name with one stanley cup') do
    StanleyCupWinnersDirectory.instance.stanley_cup_winners_with_last_name('Torrey').should == [ 'Bill Torrey' ]
  end

  it('should find an existing name with many stanley cups') do
    StanleyCupWinnersDirectory.instance.stanley_cup_winners_with_last_name('Tremblay').should == [
      'Gilles Tremblay', 'J. C. Tremblay', 'Mario Tremblay'
    ]
  end

  it('should return nil when there are no winners') do
    StanleyCupWinnersDirectory.instance.stanley_cup_winners_with_last_name('SDgasdhf').should(be_nil)
  end

  it('should be case-insensitive') do
    StanleyCupWinnersDirectory.instance.stanley_cup_winners_with_last_name('Torrey').should == StanleyCupWinnersDirectory.instance.stanley_cup_winners_with_last_name('torrey')
  end
end
