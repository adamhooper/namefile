require 'spec_helper'

describe(Canonicalizer) do
  describe('canonicalize') do
    it('should leave most strings untouched') do
      Canonicalizer.canonicalize('Tremblay').should == 'Tremblay'
    end

    it('should remove numbers and underscores') do
      Canonicalizer.canonicalize('Adfs_df32a').should == 'Adfsdfa'
    end

    it('should leave dashes, spaces and apostrophes') do
      Canonicalizer.canonicalize("O'Brien-Far Lee").should == "O'Brien-Far Lee"
    end

    it('should convert accents into regular characters') do
      Canonicalizer.canonicalize('Hǫöpér').should == 'Hooper'
    end

    it('should remove leading and trailing spaces') do
      Canonicalizer.canonicalize(' Hooper ').should == 'Hooper'
    end
  end
end
