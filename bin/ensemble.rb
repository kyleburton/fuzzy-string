#!/usr/bin/env ruby
$:.push File.dirname(__FILE__) + '/../edist-app/lib'
require 'brew'
require 'edist'
require 'levenshtein'
require 'nysiis'
require 'soundex'
require 'optparse'
require 'base_app'

class Ensemble < BaseApp
  def initialize
    super
  end

  def command_line_arguments
    super.concat [
                  ['t','training-file',"Specify the training file."]
                 ]
  end

  def run
    # genome is a vector
    # each slot is an int,
  end
end

Ensemble.main
