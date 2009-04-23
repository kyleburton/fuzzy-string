require 'edist'
require 'nysiis'
require 'soundex'
class IndexController < ApplicationController
  include Nysiis
  def index
    @left_string = "Saturday"
    @right_string = "Sunday"
  end

  def edist
    edist = Edist.new
    @left_string  = params[:left_string]  || ''
    @right_string = params[:right_string] || ''
    @edits, @matrix = edist.distance(@left_string,@right_string)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @edist_score = (len.to_f - @edits.to_f) / len.to_f
  end


  def brew
    brew = Brew.new
    @left_string  = params[:left_string]  || 'BRYN'
    @right_string = params[:right_string] || 'RESTAURANT'
    @initial_cost = params[:initial_cost] || 0.0
    @match_cost   = params[:match_cost]   || 0.0
    @insert_cost  = params[:insert_cost]  || 0.1
    @delete_cost  = params[:delete_cost]  || 15.0
    @subst_cost   = params[:subst_cost]   || 1.0
    @score, @matrix, @traceback = brew.distance(@left_string,@right_string,
                                                :initial => @initial_cost,
                                                :match   => @match_cost,
                                                :insert  => @insert_cost,
                                                :delete  => @delete_cost,
                                                :subst   => @subst_cost)
    
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @brew_score = (len.to_f - @score.to_f) / len.to_f
  end
end
