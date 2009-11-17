# text brew, adapted from Perl implementation Text::Brew module :
# http://search.cpan.org/~kcivey/Text-Brew-0.02/lib/Text/Brew.pm

class Cost

  def initialize(initial,match,insert,delete,subst,transpose,extended)
    @initial   = initial || 0.0
    @match     = match  || 0.0
    @insert    = insert || 1.0
    @delete    = delete || 1.0
    @subst     = subst  || 2.0
    @transpose = transpose || 2.0
    @extended = extended || false
  end

  def max
    [@initial,
     @match,
     @insert,
     @delete,
     @subst].max
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

  def extended
    @extended
  end

  def extended=(val)
    @extended = val
  end

  def transpose
    @transpose
  end

  def transpose=(val)
    @transpose = val
  end

  def to_s
    "Cost{#{self.hash}}(initial=#{@initial};match=#{@match};insert=#{@insert};delete=#{@delete};subst=#{@subst};transpose=#{@transpose})"
  end

end

class Brew

  # consts for edit actions
  INITIAL   = 'INITIAL'
  DELETE    = 'DEL'
  INSERT    = 'INS'
  SUBST     = 'SUB'
  MATCH     = 'MAT'
  TRANSPOSE = 'TRN'

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
                     cost_config[:delete], cost_config[:subst], cost_config[:transpose],
                     cost_config[:extended])
    @left = left
    @right = right
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
      if @cost.extended && idx == 0
        ctr = @cost.max
      end
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
          is_hit = false
          ## use the subst cost
          base_cost = base_cost + @cost.subst
          action = SUBST
        end

        can_transpose = false
        transpose_cost = nil
        if left_idx >= 1 && right_idx >= 1 &&
            left_chars[left_idx-1] == right_chars[right_idx] &&
            left_chars[left_idx]   == right_chars[right_idx-1]
          can_transpose = true
          transpose_cost = matrix[row_idx-2][col_idx-2][:cost] + @cost.transpose
          #puts "TRANSPOSE: #{left_idx}:#{left_ch} vs #{right_idx}:#{right_ch} cost(#{@cost.transpose})=#{transpose_cost}"
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

        if can_transpose && transpose_cost < curr_cost
          curr_cost = transpose_cost
          tb = [row_idx-1, col_idx-1]
          action = TRANSPOSE
        end

        row[col_idx] = evaluate_cell :cost => curr_cost, :left => left_ch, :right => right_ch,
                                     :hit=>is_hit, :tb => tb, :action => action, :path => false
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

  def evaluate_cell(cell_info={})
    cell_info
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

# TODO: this doesn't belong here
class Array
  def each_slice_with_index(size)
    i, offset = 0, 0
    while offset < self.size
      yield self.slice(offset, size), i
      i += 1
      offset += size
    end
  end
end

# This keyboard distance computes costs after Brew determines the
# paths, this is less than optimial, since the decision of what to
# match and where should have been influenced at each cell in the grid
# -- not just after the fact!  This may be easier to implement if Brew
# is extended to allow the final 'score' to be determined by a method
# call, not just by the monolithic implementation...
class KeyboardDistance
  US_KEYBOARD = <<-EOS
`~ 1! 2@ 3# 4$ 5% 6^ 7& 8* 9( 0) -_ =+
   qQ wW eE rR tT yY uU iI oO pP [{ ]} \\|
   aA sS dD fF gG hH jJ kK lL ;: '"
   zZ xX cC vV bB nN mM ,< .> /?
EOS

  # to implement alternate keyboards, either use the same format (if
  # it even works), or derive a non-us keyboard dist class, overriding
  # the grid function...or email me and I'll work with you to extend it
  def initialize(keyboard=US_KEYBOARD)
    @coords_by_key = {}
    lines = keyboard.split("\n")
    @max_height = lines.size
    @max_width = 0
    lines.each_with_index do |line,row|
      row_chars = line.split('')
      num_keys_in_row = line.gsub(/\s+/,'').size / 2
      @max_width = num_keys_in_row if @max_width < num_keys_in_row
      row_chars.each_slice_with_index(3) do |a,col|
        keys = a.join('').strip.split ''
        next if keys.empty?
        keys.each do |key|
          @coords_by_key[key] =[row,col]
          @coords_by_key[key[0]] =[row,col]
        end
      end
    end
    @max_dist = Math.sqrt( @max_width**2 + @max_height**2 )
  end

  def dist_between_chars(leftch,rightch)
    x1,y1 = @coords_by_key[leftch]
    x2,y2 = @coords_by_key[rightch]
    unless x1 && y1 && x2 && y2
      @max_dist
    else
      a = (y1 - y2).abs.to_f
      b = (x1 - x2).abs.to_f
      c = Math.sqrt(a**2 + b**2)
      c
    end
  end

  def distance(left,right,cost_config={})
    cost, matrix, traceback = Brew.new.distance(left,right,cost_config)
    # TODO: compute the max cost so we can compute a similarity
    # give'm the benefit of the doubt
    total_cost = 0.0
    traceback.each do |entry|
      next if entry[:action] == "INITIAL"
      #puts "trace: #{entry.inspect}"
      if entry[:action] == "MAT"
        total_cost += 0
      else
        leftch  = entry[:left]
        rightch = entry[:right]
        total_cost += dist_between_chars(leftch,rightch)
      end
    end
    total_cost
  end

  def max_cost(left,right)
    @max_dist * ( (left.size + right.size) / 2.0)
  end

  def similarity(left,right)
    max = max_cost(left,right)
    cost = distance(left.downcase,right.downcase)
    (max - cost) / max
  end
end

# sorry, the way Brew is currently implemented, there's no easy way to override...needs a bit more refactoring..
# class KeyboardDistanceAlt < Brew
#   def initialize
#     @kbd = KeyboardDistance.new
#   end

#   def distance(left,right)
#     super(left,right,:initial => 0.0, :insert=>0.0, :delete => 0.0, :match => 0.0, :subst => 0, :transpose => 0)
#   end

#   def evaluate_cell(cell_info={})
#     # :cost => curr_cost, :left => left_ch, :right => right_ch,
#     # :hit=>is_hit, :tb => tb, :action => action, :path => false
#     return cell_info if entry[:action] == "INITIAL"
#     #puts "trace: #{entry.inspect}"
#     if entry[:action] == "MAT"
#       return cell_info
#     end

#     leftch  = entry[:left]
#     rightch = entry[:right]
#     cell_info[:cost] = dist_between_chars(leftch,rightch)
#     cell_info
#   end
# end


if false
  brew = Brew.new
  left,right = ARGV
  left = "baby" unless left
  right = "bobby" unless right
  brew.distance(left, right, :initial => 0.0, :insert=>0.1, :delete => 15.0, :match => 0.0, :subst => 1)
end

if true
  kbd = KeyboardDistance.new
  [ [ "Kyle Burton", "Khle Vurtin" ], # a few chars offset by 1
    [ "apple", "sookr" ],             # all chars offset by 1
    [ "apple", "elephant" ],          # wildly different
  ].each do |pair|
    left, right = pair
    puts "#{left} vs #{right} ==> #{kbd.similarity(left,right)}"
  end
end
