#!/usr/bin/env ruby
$:.push File.dirname(__FILE__) + '/../edist-app/lib'
require 'brew'
require 'edist'
require 'levenshtein'
require 'nysiis'
require 'soundex'
require 'optparse'

module Fuzzy
  class DoubleMetaphoneCmd
    def initialize(*args)
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
    def initialize(*args)
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
    def initialize(*args)
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
    def initialize(*args)
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
    # want to be able to supply the score string via a command line parameter...
  end

  class FindCmd
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

    def words_file
      '/usr/share/dict/words'
    end

    def print_nysiis(word);    puts "NYSIIS: #{word.nysiis}"; end
    def print_soundex(word);   puts word.soundex; end
    def print_metaphone(word); puts word.double_metaphone; end

    def print_edist(left,right)
      raise "implement this: print_edist"
    end

    def print_brew(left,right,scores)
      raise "implement this: print_brew"
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

        opts.on("-q", "--quiet", "Run quietly") do |v|
          options[:quiet] = v
        end
      end.parse!
      options
    end

    def main
      options = parse_cmdline_opts

      if ARGV.size < 1
        puts "Error, you must supply a command, try one of: (#{command_names})"
        exit -1
      end

      command, *args = ARGV
      command = resolve_command(command)

      if ! commands[command]
        puts "Error, invalid command: '#{command}', must be one of (#{command_names})"
        exit -1
      end

      commands[command].new(*args).run
    end
  end
end

if __FILE__ == $0
  Fuzzy::Main.main
end
