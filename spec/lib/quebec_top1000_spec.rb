require 'spec_helper'

describe(QuebecTop1000Directory) do
  # This uses the real database in db/quebec-top1000.csv
  it('should find an existing name') do
    QuebecTop1000Directory.instance.ranking_data_for_last_name('Tremblay').should == {
      :last_name => 'Tremblay',
      :rank => 1,
      :approximate_population => 81000
    }
  end

  it('should not find a missing name') do
    QuebecTop1000Directory.instance.ranking_data_for_last_name('Ssdgnl').should(be_nil)
  end

  it('should be case-insensitive') do
    QuebecTop1000Directory.instance.ranking_data_for_last_name('Tremblay').should == QuebecTop1000Directory.instance.ranking_data_for_last_name('tremblay')
  end
end
