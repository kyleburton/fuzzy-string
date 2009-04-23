module Nysiis
  def self.nysiis(string)
    string = string.upcase
    
    string.gsub! /[^A-Za-z]/, ''
    string.gsub! /[SZ]*$/, ''
    string.sub! /^MAC/, 'MC'
    string.sub! /^PF/, 'F'

    string.sub! /IX$/, 'IC'
    string.sub! /EX$/, 'EC'
    string.sub! /(?:YE|EE|IE)$/, 'Y'
    string.sub! /(?:NT|ND)$/, 'N'

    string.gsub! /(.)EV/, "#{$1}EF"
    first = string[0..0]
    string.gsub! /[AEIOU]+/, 'A'
    string.gsub! /AW/, 'A'
    
    string.gsub! /GHT/, 'GT'
    string.gsub! /DG/, 'G'
    string.gsub! /PH/, 'F'
    string.gsub! /(.)(?:AH|HA)/, "#{$1}A"
    string.gsub! /KN/, 'N'
    string.gsub! /K/, 'C'
    string.gsub! /(.)M/, "#{$1}N"
    string.gsub! /(.)Q/, "#{$1}G"
    string.sub! /(?:SCH|SH)$/, 'S'
    string.gsub! /YW/, 'Y'
    
    string.gsub! /(.)Y(.)/, "#{$1}A#{$2}"
    string.gsub! /WR/, 'R'
    
    string.gsub! /(.)Z/, "#{$1}S"
    
    string.sub! /AY$/, 'Y'
    string.sub! /A+$/, ''

    string.gsub! /(\w)\1+/, "#{$1}"
    
    if first =~ /[AEIOU]/
      string = first + string[1..-1]
    end
    
    string
  end
end
#puts nysiis ARGV[0]
