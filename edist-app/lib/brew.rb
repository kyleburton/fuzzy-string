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

    if left.size < right.size
      left, right = right, left
    end
    
    left_chars  = left.split //
    right_chars = right.split //
    matrix = Array.new left_chars.size + 1
    #puts "matrix.size=#{matrix.size} matrix=#{matrix.inspect}"
    
    # initialize the top row of the grid...brew extends the
    # information stored in the grid to be the base edit distance info
    # (left-ch, right-ch, cost) and augments it with a tracekback,
    # linking it back to the cheapest cell path it took to get to the
    # current cell.  The Perl implementatiothis is based off of does
    # this via an array ref, this will use an (x,y) coordinate
    ctr = 1
    matrix[0] = Array.new right_chars.size + 1
    matrix[0][0] = { :cost => 0, :left => nil, :right => nil, :hit => true, :tb => [nil,nil] }
    left_chars.each_with_index { |ch,idx|
      matrix[idx+1] = Array.new right_chars.size + 1
      ## TODO: cost should be DEL, not 1
      matrix[idx+1][0] = { :cost => ctr, :left => ch, :right => nil, :tb => [] }
      ctr += 1
    }
    
    ctr = 1
    right_chars.each_with_index { |ch,idx|
      ## TODO: cost should be INS, not 1
      matrix[0][idx+1] = { :cost => ctr, :left => nil, :right => ch, :tb => [nil, nil] }
      ctr += 1
    }

    left_chars.each_with_index { |left_ch,left_idx|
      row_idx = left_idx + 1
      row = matrix[row_idx]
      right_chars.each_with_index { |right_ch,right_idx|
        col_idx = right_idx + 1

        ## TODO: use the variable costs...
        if left_ch == right_ch
          ## use the match cost
        else
          ## use the subst cost
        end

        base_cost = left_ch == right_ch ? 0 : 1
        up_cost      = 1         + matrix[row_idx - 1][col_idx    ][:cost]
        left_cost    = 1         + matrix[row_idx    ][col_idx - 1][:cost]
        up_left_cost = base_cost + matrix[row_idx - 1][col_idx - 1][:cost]
        curr_cost = up_left_cost
        curr_cost = left_cost if left_cost < curr_cost
        curr_cost = up_cost   if up_cost < curr_cost

        is_hit = true
        if left_ch != right_ch
          curr_cost + 1
          is_hit = false
        end
        
        # total is base + min of [up,left,up-left]
        row[col_idx] = { :cost => curr_cost, :left => left_ch, :right => right_ch, :hit=>is_hit }
      }
    }

    print_matrix(matrix)

    [ matrix[-1][-1][:cost], matrix ]
  end

  def cell_to_s(cell)
    if cell
      c = cell[:cost]  || '0'
      l = cell[:left]  || '~'
      r = cell[:right] || '~'
      "{c:#{c};l:#{l};r:#{r}}"
    else
      "{c:0;l:~;r:~}"
    end
  end

  # TODO: use shoes to print a GUI?
  def print_matrix(matrix)
    puts "...Header line here..."
    matrix.each_with_index {|row,row_idx|
      row.each_with_index { |cell,col_idx|
        print " #{cell_to_s(cell)}"
      }
      print "\n"
    }
  end

end


brew = Brew.new
brew.distance("baby","bobby")
