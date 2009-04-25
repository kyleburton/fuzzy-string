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
    compute_edist_grid
  end

  def edist_grid
    set_params
    compute_edist_grid
    render :partial => "edist_grid", :layout => false
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
  def compute_edist_grid
    edist = Edist.new
    @cost, @matrix = edist.distance(@left_string,@right_string)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @max_penalty = len.to_f
    @edist_score = (@max_penalty - @cost.to_f) / @max_penalty
  end

  def compute_brew_grid
    the_brew = Brew.new
    @cost, @matrix, @traceback = the_brew.distance(@left_string,@right_string,
                                                :initial => @initial_cost.to_f,
                                                :match   => @match_cost.to_f,
                                                :insert  => @insert_cost.to_f,
                                                :delete  => @delete_cost.to_f,
                                                :subst   => @subst_cost.to_f)
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    len = @left_string.length
    len = @right_string.length if @right_string.length > len
    @max_penalty = len.to_f


    puts "brew_grid: @extended=#{@extended}"
    if @extended
      # [0] is 'initial', [1] is the first 'edit'
      puts "@traceback[1][:action] == \"#{@traceback[1][:action]}\""
      if @traceback[1][:action] != "MAT"
        @cost = @cost + 10.0
      end
    end

    @edist_score = (@max_penalty - @cost.to_f) / @max_penalty
    @edist_score = 0.0 if @edist_score < 0
  end

  def set_params
    @left_string  = params[:left_string]  || 'BRYN'
    @right_string = params[:right_string] || 'RESTAURANT'
    @initial_cost = params[:initial_cost] || 0.0
    @match_cost   = params[:match_cost]   || 0.0
    @insert_cost  = params[:insert_cost]  || 0.1
    @delete_cost  = params[:delete_cost]  || 15.0
    @subst_cost   = params[:subst_cost]   || 1.0
    puts "set_params: params[:extended]=#{params[:extended]}"
    @extended     = params[:extended]
    @extended     = (@extended.nil? || @extended.empty? || @extended == "false") ? false : true
  end


end
