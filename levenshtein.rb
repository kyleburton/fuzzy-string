require 'rubygems'
require 'text'

# Text::Levenshtein.distance(left,right)
# Text::Soundex.soundex(left,right)
# Text::Metaphone.double_metaphone(left,right)

def edit_distance(left,right)
  if left.size < right.size
    left, right = right, left
  end
  Text::Levenshtein.distance(left,right)
end

def edit_distance_sim(left,right)
  if left.size < right.size
    left, right = right, left
  end
  edits = Text::Levenshtein.distance(left,right)
  ((left.size - edits) / (1.0 * left.size))
end


target = "De Morgan"
words = ["De Morgan", "D'Morgun", "D'Morgun", "Demorgyn", "De Murgen", "Dy Moregan", "Dy Murgan", "Da Murgan", "Da Morgan", "Da Myrgn"];

words.each {|word|
  puts "#{target} vs #{word} => #{edit_distance(target,word)} => #{edit_distance_sim(target,word)}"
}

