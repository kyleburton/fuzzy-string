require 'edist'
class IndexController < ApplicationController
  def index
    @left_string = "Saturday"
    @right_string = "Sunday"
  end

  def compare
    edist = Edist.new
    @left_string  = params[:left_string]
    @right_string = params[:right_string]
    @matrix = edist.distance(@left_string,@right_string)
  end
end
