# from: http://snippets.dzone.com/posts/show/4530
require 'text'
require 'nysiis'
class String

    SoundexChars = 'BPFVCSKGJQXZDTLMNR'
    SoundexNums  = '111122222222334556'
    SoundexCharsEx = '^' + SoundexChars
    SoundexCharsDel = '^A-Z'

    # desc: http://en.wikipedia.org/wiki/Soundex
    def soundex(census = true)
        str = upcase.delete(SoundexCharsDel).squeeze

        str[0 .. 0] + str[1 .. -1].
            delete(SoundexCharsEx).
            tr(SoundexChars, SoundexNums)[0 .. (census ? 2 : -1)].
            ljust(3, '0') rescue ''
    end

    def sounds_like(other)
        soundex == other.soundex
    end

  def nysiis
    Nysiis.nysiis(self)
  end

  def double_metaphone
     Text::Metaphone.double_metaphone(self)
  end
end
