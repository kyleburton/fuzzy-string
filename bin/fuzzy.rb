#!/usr/bin/env ruby
$:.push File.dirname(__FILE__) + '/../edist-app/lib'
require 'brew'
require 'edist'
require 'levenshtein'
require 'nysiis'
require 'soundex'
require 'optparse'

module Fuzzy
  BREW_SCORE_TABLES = {
    :abbrev => {
        :initial   => 0.0,
        :match     => 0.0,
        :insert    => 0.1,
        :delete    => 5.0,
        :subst     => 5.0,
        :transpose => 2.0,
        :extended  => false },
    :edist => {
        :initial   => 0.0,
        :match     => 0.0,
        :insert    => 1.0,
        :delete    => 1.0,
        :subst     => 1.0,
        :transpose => 2.0,
        :extended  => false },
    :typo => {
        :initial   => 0.0,
        :match     => 0.0,
        :insert    => 1.0,
        :delete    => 1.0,
        :subst     => 2.0,
        :transpose => 0.1,
        :extended  => false }
  }

  class DoubleMetaphoneCmd
    def initialize(options,args)
      if args.size < 1
        raise "DoubleMetaphone: Error, at least one string is required."
      end
      @words = args
    end
    def run
      @words.each do |word|
        puts "DoubleMetaphone: #{word.double_metaphone}"
      end
    end
  end

  class SoundexCmd
    def initialize(options,args)
      if args.size < 1
        raise "Soundex: Error, at least one string is required."
      end
      @words = args
    end
    def run
      @words.each do |word|
        puts "SOUNDEX: #{word.soundex}"
      end
    end
  end

  class NysiisCmd
    def initialize(options,args)
      if args.size < 1
        raise "Nysiis: Error, at least one string is required."
      end
      @words = args
    end
    def run
      @words.each do |word|
        puts "NYSIIS: #{word.nysiis}"
      end
    end
  end

  class EdistCmd
    def initialize(options,args)
      if args.size < 2
        raise "Edist: Error, two words are required for comparison: #$0 left-word right-word [threshold]"
      end
      if args.size > 3
        raise "Edist: Error, unsupported arguments: #$0 edist left-word right-word [threshold]"
      end
      @left, @right, @thresh = args
      @thresh = @thresh.to_f
    end

    def run
      edist = Edist.new
      @cost, @matrix = edist.distance(@left.downcase,@right.downcase)
      avg_len = (@left.size + @right.size) / 2.0
      score   = (avg_len - @cost) / avg_len
      if @thresh
        result = score >= @thresh ? 'HIT' : 'MISS'
        puts "edist(#@left,#@right) = cost:#@cost; score=#{score}/#{@thresh} [#{result}]"
      else
        puts "edist(#@left,#@right) = cost:#@cost; score=#{score}"
      end
    end
  end

  class BrewCmd
    def initialize(options,args)
      if args.size < 2
        raise "Brew: Error, two words are required for comparison: #$0 left-word right-word [threshold] [scores]"
      end
      if args.size > 4
        raise "Brew: Error, unsupported arguments: #$0 brew left-word right-word [threshold] [scores]"
      end
      @left, @right = args
      @thresh      = options[:thres] || 0.80
      @brew_scores = options[:score_table] || BREW_SCORE_TABLES[:abbrev]
    end

    def run
      brew = Brew.new
      print "score table: #{@brew_scores.inspect}"
      @cost, @matrix = brew.distance(@left.downcase,@right.downcase,
                                    @brew_scores)
      avg_len = (@left.size + @right.size) / 2.0
      score   = (avg_len - @cost) / avg_len
      @thresh = 0.80 unless @thresh && @thresh > 0.0
      if @thresh
        result = score >= @thresh ? 'HIT' : 'MISS'
        puts "edist(#@left,#@right) = cost:#@cost; score=#{score}/#{@thresh} [#{result}]"
      else
        puts "edist(#@left,#@right) = cost:#@cost; score=#{score}"
      end
    end
  end

  class FindCmd
    def initialize(options,args)
      puts "FindCmd: args=#{args.inspect}"
      @algorithm, @term, @file = args
      @file        = @file || options[:file]  || '/usr/share/dict/words'
      @thresh      = options[:threshold]      || 0.80
      options[:score_table_name] ||= :abbrev
      @score_table = options[:score_table]    || BREW_SCORE_TABLES[:abbrev]
      comparators = {
        :edist   => :edist,
        :nysiis  => :nysiis,
        :meta    => :meta,
        :soundex => :soundex,
        :brew    => :brew,
      }
      @edist = Edist.new
      @brew  = Brew.new
      puts "FindCmd: going to search for '#{@term}' in '#{@file}' using '#{@algorithm}' score-table:#{options[:score_table_name]}"
      @comparator = comparators[@algorithm.to_sym]
      unless @comparator
        raise "Find: algorithm term [file]\nERROR: invalid algorithm '#{@algorithm}', try one of (#{comparators.keys.map {|x| x.to_s}.join(", ")})"
      end
    end

    def run
      puts "FindCmd: #{@term} in #{@file} using #{@algorithm}"
      File.open(@file,'r').each_line do |line|
        words = line.split(/\s+/)
        word = words[0]
        self.send(@comparator,word)
      end
    end

    def brew(word)
      cost, matrix = @brew.distance(@term.downcase,word.downcase,@score_table)
      avg_len = (@term.size + word.size) / 2.0
      score   = (avg_len - cost) / avg_len
      if score >= @thresh
        puts ['HIT',@term,word,cost,score,@thresh].join(", ")
      end
    end

    def edist(word)
      cost, matrix = @edist.distance(@term.downcase,word.downcase)
      avg_len = (@term.size + word.size) / 2.0
      score   = (avg_len - cost) / avg_len
      if score >= @thresh
        puts ['HIT',@term,word,cost,score,@thresh].join(", ")
      end
    end

    def meta(word)
      @term_hash ||= @term.double_metaphone
      puts "HIT\t#{@term}\t#{word}\t#{@term_hash}" if @term_hash == word.double_metaphone
    end

    def nysiis(word)
      @term_hash ||= @term.nysiis
      puts "HIT\t#{@term}\t#{word}\t#{@term_hash}" if @term_hash == word.nysiis
    end

    def meta(word)
      @term_hash ||= @term.double_metaphone
      puts "HIT\t#{@term}\t#{word}\t#{@term_hash}" if @term_hash == word.double_metaphone
    end

    def nysiis(word)
      @term_hash ||= @term.nysiis
      puts "HIT\t#{@term}\t#{word}\t#{@term_hash}" if @term_hash == word.nysiis
    end

    def soundex(word)
      @term_hash ||= @term.soundex
      puts "HIT\t#{@term}\t#{word}\t#{@term_hash}" if @term_hash == word.soundex
    end
  end

  class Main
    def self.main
      self.new.main
    end

    def commands
      {
        :nysiis    => NysiisCmd,
        :soundex   => SoundexCmd,
        :metaphone => DoubleMetaphoneCmd,
        :edist     => EdistCmd,
        :brew      => BrewCmd,
        :find      => FindCmd,
      }
    end

    def command_names
      commands.keys.map(&:to_s).sort.join(", ")
    end

    def resolve_command(command)
      sname = command.to_sym
      candidates = commands.keys.select do |cand|
        cand.to_s.start_with? sname.to_s
      end
      candidates.size == 1 ? candidates[0] : sname
    end

    def parse_cmdline_opts
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: #$0 [options] command [args]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end

        opts.on("-f", "--file=", "File to search for the 'find' command.") do |v|
          options[:file] = v
        end

        opts.on("-q", "--quiet", "Run quietly") do |v|
          options[:quiet] = v
        end

        opts.on("-t", "--threshold=", "Threshold (percentage) for Edist and Brew Algorithms.") do |v|
         options[:threshold] = v.to_f
        end

        opts.on("-s", "--score-table=", "Set the Brew Score table to use (#{BREW_SCORE_TABLES.keys.join(", ")})") do |v|
         options[:score_table_name] = v.to_sym
         options[:score_table]      = BREW_SCORE_TABLES[v.to_sym]
         unless options[:score_table]
           raise "Error: invalid score table: #{v}, try one of: (#{BREW_SCORE_TABLES.keys.join(", ")})"
         end
        end

        opts.on("-b", "--brew-table=", "Set the Brew Score table from an expression.  To be valid it must be a hash with the following form: {:initial=>0,:match=>0,:insert=>0.1,:delete=>5,:subst=>5,:transpose=>2}.  Behavior of this program is undefined in the case the table you provide is invalid.") do |v|
         options[:score_table_name] = 'custom'
         options[:score_table]      = eval v
        end

      end.parse!
      options
    end

    def main
      options = parse_cmdline_opts

      if ARGV.size < 1
        puts "Error, you must supply a command, try one of: (#{command_names})"
        exit(-1)
      end

      command, *args = ARGV
      command = resolve_command(command)

      if ! commands[command]
        puts "Error, invalid command: '#{command}', must be one of (#{command_names})"
        exit(-1)
      end

      commands[command].new(options,args).run
    end
  end
end

if __FILE__ == $0
  Fuzzy::Main.main
end
