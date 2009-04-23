# text brew, adapted from Perl implementation Text::Brew module :
# http://search.cpan.org/~kcivey/Text-Brew-0.02/lib/Text/Brew.pm

# consts for edit actions
INITIAL = 'INITIAL'
DEL     = 'DEL'
INS     = 'INS'
SUB     = 'SUB'
MAT     = 'MAT'

class Cost

  def initialize(match,insert,delete,subst)
    @match  = match  || 0.0
    @insert = insert || 1.0
    @delete = delete || 1.0
    @subst  = subst  || 2.0
  end

  def match
    @match
  end

  def match=(val)
    @match=val
  end

  def insert
    @insert
  end

  def insert=(val)
    @insert = val
  end
  
  def delete
    @delete
  end

  def delete=(val)
    @delete = val
  end

  def subst
    @subst
  end

  def subst=(val)
    @subst = val
  end

  def to_s
    @match = match
    @insert = insert
    @delete = delete
    @subst = subst

    "Cost{#{self.hash}}(match=#{@match};insert=#{@insert};delete=#{@delete};subst=#{@subst})"
  end

end

class Brew

  # the perl module supports an option '-output' =>
  # ['distance','both','edits'] which determines the return value
  # structure, it defaults to both and the return value is either
  # value, or a tuple of [distance,edits], where edits is a linked
  # list representing the least cost edit path
 
  #
  # for pedagological and visualization purposes, this should also
  # support providing access to the internal matrix
  #
  def distance(left,right,cost_config={})
    @cost = Cost.new(cost_config[:match], cost_config[:insert], cost_config[:delete], cost_config[:subst])
    puts "cost=#{@cost}"
  end
end


brew = Brew.new
brew.distance("baby","bobby")
