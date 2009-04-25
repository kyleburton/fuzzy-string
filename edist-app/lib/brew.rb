# text brew, adapted from Perl implementation Text::Brew module :
# http://search.cpan.org/~kcivey/Text-Brew-0.02/lib/Text/Brew.pm

# consts for edit actions
INITIAL = 'INITIAL'
DELETE  = 'DEL'
INSERT  = 'INS'
SUBST   = 'SUB'
MATCH   = 'MAT'

class Cost

  def initialize(initial,match,insert,delete,subst)
    @initial = initial || 0.0
    @match   = match  || 0.0
    @insert  = insert || 1.0
    @delete  = delete || 1.0
    @subst   = subst  || 2.0
  end

  def initial
    @initial
  end

  def initial=(val)
    @initial=val
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
    "Cost{#{self.hash}}(initial=#{@initial};match=#{@match};insert=#{@insert};delete=#{@delete};subst=#{@subst})"
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
    @cost = Cost.new(cost_config[:initial],cost_config[:match], cost_config[:insert], 
                     cost_config[:delete], cost_config[:subst])

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
    ctr = @cost.delete
    matrix[0] = Array.new right_chars.size + 1
    matrix[0][0] = { :cost => @cost.initial, :left => nil, :right => nil, 
                     :hit => false, :tb => [-1,-1], :action => INITIAL, :path => false }
    left_chars.each_with_index { |ch,idx|
      matrix[idx+1] = Array.new right_chars.size + 1
      matrix[idx+1][0] = { :cost => ctr, :left => ch, :right => nil, 
                           :tb => [idx,0], :action => DELETE, :path => false }
      ctr += @cost.delete
    }
    
    ctr = @cost.insert
    right_chars.each_with_index { |ch,idx|
      matrix[0][idx+1] = { :cost => ctr, :left => nil, :right => ch, 
                           :tb => [0,idx], :action => INSERT, :path => false }
      ctr += @cost.insert
    }

    left_chars.each_with_index { |left_ch,left_idx|
      row_idx = left_idx + 1
      row = matrix[row_idx]
      right_chars.each_with_index { |right_ch,right_idx|
        col_idx = right_idx + 1

        is_hit    = true
        base_cost = 0
        action = MATCH
        if left_ch == right_ch
          ## use the match cost
          base_cost = base_cost + @cost.match
          is_hit = true
          action = MATCH
        else
          ## use the subst cost
          base_cost = base_cost + @cost.subst
          is_hit = false
          action = SUBST
        end

        ## up means DEL
        up_cost      = @cost.delete + matrix[row_idx - 1][col_idx    ][:cost]
        ## left means INS cost
        left_cost    = @cost.insert + matrix[row_idx    ][col_idx - 1][:cost]
        ## up-left is subst cost
        up_left_cost = base_cost    + matrix[row_idx - 1][col_idx - 1][:cost]

        curr_cost = up_left_cost
        tb = [row_idx-1, col_idx-1]
        if left_cost < curr_cost
          curr_cost = left_cost
          tb = [row_idx, col_idx-1]
          action = INSERT
        end

        if up_cost < curr_cost
          curr_cost = up_cost
          tb = [row_idx-1, col_idx]
          action = DELETE
        end

        
        # total is base + min of [up,left,up-left]
        row[col_idx] = { :cost => curr_cost, :left => left_ch, :right => right_ch, 
                         :hit=>is_hit, :tb => tb, :action => action, :path => false }
        #puts "cell is: #{row[col_idx].inspect}"
      }
    }


    ## comput the traceback...
    traceback = [matrix[-1][-1]]
    traceback[0][:path] = true
    curr = traceback[0][:tb]
    while true
      if curr[0] == -1 && curr[1] == -1
        break
      end
      #puts "curr=#{curr.inspect} => #{traceback[-1].inspect}"
      traceback.unshift matrix[curr[0]][curr[1]]
      traceback[0][:path] = true
      curr = matrix[curr[0]][curr[1]][:tb]
    end

    #print_matrix(matrix)
    #puts "traceback: #{traceback.inspect}"
    [ matrix[-1][-1][:cost], matrix, traceback ]
  end

  def cell_to_s(cell)
    if cell
      c = cell[:cost]  || '0'
      l = cell[:left]  || '~'
      r = cell[:right] || '~'
      "{c:#{c};l:#{l};r:#{r};a:#{cell[:action]};tb:#{cell[:tb].inspect}}"
    else
      "{c:0;l:~;r:~}"
    end
  end

  # TODO: use shoes to print a GUI?
  def print_matrix(matrix)
    matrix.each_with_index {|row,row_idx|
      row.each_with_index { |cell,col_idx|
        print " #{cell_to_s(cell)}"
      }
      print "\n"
    }
  end

end


if true
  brew = Brew.new
  left,right = ARGV
  left = "baby" unless left
  right = "bobby" unless right
  brew.distance(left, right, :initial => 0.0, :insert=>0.1, :delete => 15.0, :match => 0.0, :subst => 1)
end
