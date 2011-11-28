module Canonicalizer
  def self.canonicalize(s)
    normalized = s.to_s.mb_chars.normalize(:kd)
    ascii = normalized.gsub(/[^\x00-\x7F]/n, '').to_s
    ascii_simple = ascii.gsub(/[^-'a-zA-Z ]/, '').strip
    ascii_no_articles = ascii_simple.gsub(/^(de +|la +|du +|l' *|d' *)*/i, '')
    ascii_no_articles.downcase
  end
end
