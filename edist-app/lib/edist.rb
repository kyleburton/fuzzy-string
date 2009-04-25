
class Edist

  def distance(left,right)
    if !left || !right
      return [-1,[]]
    end

    if left.size < right.size
      left, right = right, left
    end
    
    left_chars  = left.split //
    right_chars = right.split //
    matrix = Array.new left_chars.size + 1
    #puts "matrix.size=#{matrix.size} matrix=#{matrix.inspect}"
    
    # initialize the top row of the grid
    ctr = 1
    matrix[0] = Array.new right_chars.size + 1
    matrix[0][0] = { :cost => 0, :left => nil, :right => nil, :hit => true }
    left_chars.each_with_index { |ch,idx|
      matrix[idx+1] = Array.new right_chars.size + 1
      matrix[idx+1][0] = { :cost => ctr, :left => ch, :right => nil }
      ctr += 1
    }
    
    ctr = 1
    right_chars.each_with_index { |ch,idx|
      matrix[0][idx+1] = { :cost => ctr, :left => nil, :right => ch }
      ctr += 1
    }

    left_chars.each_with_index { |left_ch,left_idx|
      row_idx = left_idx + 1
      row = matrix[row_idx]
      right_chars.each_with_index { |right_ch,right_idx|
        col_idx = right_idx + 1

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

    #print_matrix(matrix)

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


edist = Edist.new
args = ARGV
args = ["kitten","sitting"] unless args.size > 0
edist.distance(args[0],args[1])
