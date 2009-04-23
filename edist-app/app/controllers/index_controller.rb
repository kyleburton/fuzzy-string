require 'edist'
require 'nysiis'
require 'soundex'
class IndexController < ApplicationController
  include Nysiis
  def index
    @left_string = "Saturday"
    @right_string = "Sunday"
  end

  def compare
    edist = Edist.new
    @left_string  = params[:left_string]
    @right_string = params[:right_string]
    @edits, @matrix = edist.distance(@left_string,@right_string)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @edist_score = (len.to_f - @edits.to_f) / len.to_f
    
  end
end
