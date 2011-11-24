require 'spec_helper'

describe(CsvNameMap) do
  describe('with a normal CSV') do
    before(:each) do
      headers = %w(last_name full_name number)
      csv = "Hooper,Adam Hooper,1\nHooper,Peter Hooper,2\nElse,Somebody Else,17"
      csv_file = StringIO.new(csv)
      @map = CsvNameMap.new(csv_file, headers)
    end

    describe('find_record') do
      it('should find an existing name with one entry') do
        record = @map.find_record('Else')
        record[:last_name].should == 'Else'
        record[:full_name].should == 'Somebody Else'
        record[:number].should == '17'
      end

      it('should return the first record if there are two entries') do
        record = @map.find_record('Hooper')
        record[:full_name].should == 'Adam Hooper'
      end

      it('should return nil when the name is not found') do
        @map.find_record('Notfound').should == nil
      end

      it('should be case-insensitive') do
        @map.find_record('eLsE').should == @map.find_record('Else')
      end

      it('should ignore accents') do
        @map.find_record('Hǫöpér').should == @map.find_record('Hooper')
      end
    end

    describe('find_records') do
      it('should find an existing name with two entries') do
        records = @map.find_records('Hooper')
        records.length.should == 2
        records[0][:last_name].should == 'Hooper'
        records[0][:full_name].should == 'Adam Hooper'
        records[0][:number].should == '1'
        records[1][:last_name].should == 'Hooper'
        records[1][:full_name].should == 'Peter Hooper'
        records[1][:number].should == '2'
      end

      it('should return nil when the name is not found') do
        @map.find_records('Notfound').should == nil
      end

      it('should be case-insensitive') do
        @map.find_records('eLsE').should == @map.find_records('Else')
      end
    end
  end

  describe('with an out-of-order CSV') do
    before(:each) do
      headers = %w(number last_name full_name number)
      csv = "3,Hooper,Adam Hooper,1\n5,Hooper,Peter Hooper,2\n15,Else,Somebody Else,17"
      csv_file = StringIO.new(csv)
      @map = CsvNameMap.new(csv_file, headers)
    end

    it("should index by last_name even though that's not the first column") do
      @map.find_records('Hooper').should_not(be_nil)
    end
  end

  describe('with an empty last_name value in a CSV') do
    before(:each) do
      headers = %w(number last_name full_name number)
      csv = "3,,Adam,1\n5,Hooper,Peter Hooper,2\n15,Else,Somebody Else,17"
      csv_file = StringIO.new(csv)
      @map = CsvNameMap.new(csv_file, headers)
    end

    it('should find an empty last name') do
      @map.find_records('').length.should == 1
    end
  end
end
