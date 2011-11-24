module Canonicalizer
  def self.canonicalize(s)
    normalized = s.to_s.mb_chars.normalize(:kd)
    ascii = normalized.gsub(/[^\x00-\x7F]/n, '').to_s
    ascii.gsub(/[^-'a-zA-Z ]/, '').strip
  end
end
