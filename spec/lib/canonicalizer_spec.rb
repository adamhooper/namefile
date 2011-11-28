require 'spec_helper'

describe(Canonicalizer) do
  describe('canonicalize') do
    it('should downcase') do
      Canonicalizer.canonicalize('Tremblay').should == 'tremblay'
    end

    it('should remove numbers and underscores') do
      Canonicalizer.canonicalize('Adfs_df32a').should == 'adfsdfa'
    end

    it('should leave dashes, spaces and apostrophes') do
      Canonicalizer.canonicalize("O'Brien-Far Lee").should == "o'brien-far lee"
    end

    it('should convert accents into regular characters') do
      Canonicalizer.canonicalize('Hǫöpér').should == 'hooper'
    end

    it('should remove leading and trailing spaces') do
      Canonicalizer.canonicalize(' Hooper ').should == 'hooper'
    end

    it('should remove "de" and "la" and "du"') do
      Canonicalizer.canonicalize('de Hooper').should == 'hooper'
      Canonicalizer.canonicalize('Du Hooper').should == 'hooper'
      Canonicalizer.canonicalize('de la Hooper').should == 'hooper'
      Canonicalizer.canonicalize('la Hooper').should == 'hooper'
      Canonicalizer.canonicalize("d'Ooper").should == 'ooper'
      Canonicalizer.canonicalize("de l' Onyx").should == 'onyx'
    end
  end
end
