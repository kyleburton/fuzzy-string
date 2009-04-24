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
    set_params
    edist = Edist.new
    @edits, @matrix = edist.distance(@left_string,@right_string)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @edist_score = (len.to_f - @edits.to_f) / len.to_f
  end


  def brew
    set_params
    compute_brew_grid
  end

  def brew_grid
    set_params
    compute_brew_grid
    render :partial => "brew_grid", :layout => false
  end

  def phonetic_results
    set_params
    render :partial => "phoentic_results", :layout => false
  end

  def title
    set_params
    compute_brew_grid
    render :partial => "title", :layout => false
  end

private
  def compute_brew_grid
    the_brew = Brew.new
    @score, @matrix, @traceback = the_brew.distance(@left_string,@right_string,
                                                :initial => @initial_cost.to_f,
                                                :match   => @match_cost.to_f,
                                                :insert  => @insert_cost.to_f,
                                                :delete  => @delete_cost.to_f,
                                                :subst   => @subst_cost.to_f)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @max_penalty = [@initial_cost.to_f,
                   @match_cost.to_f,
                   @insert_cost.to_f,
                   @delete_cost.to_f,
                   @subst_cost.to_f].max * len.to_f
    @brew_score = (@max_penalty - @score.to_f) / @max_penalty
  end

  def set_params
    @left_string  = params[:left_string]  || 'BRYN'
    @right_string = params[:right_string] || 'RESTAURANT'
    @initial_cost = params[:initial_cost] || 0.0
    @match_cost   = params[:match_cost]   || 0.0
    @insert_cost  = params[:insert_cost]  || 0.1
    @delete_cost  = params[:delete_cost]  || 15.0
    @subst_cost   = params[:subst_cost]   || 1.0
  end


end
