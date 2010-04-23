require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brew do
  describe "with the edit distnace score table" do
    before do
      @sample_datafile = RAILS_ROOT + '/spec/fixtures/files/brew-data-set.tab'
      @recs = File.new( @sample_datafile, "r").readlines.map do |line|
        line.chomp!
        rec = line.split /\t/
        rec[-1] = rec[-1].to_f
        rec
      end
      @recs.shift
      # $stderr.puts "Brew Spec: records = #{@recs.inspect}"
      @brew = Brew.new
    end

    it "should score the same as edit distance" do
      @recs.each do |rec|
        left,right,cost = rec
        left,right = left.downcase,right.downcase
        bcost,matrix,traceback = @brew.distance(left,right,TextBrew::Cost::EDIST.to_m)
        $stderr.puts "UNEXPECTED: #{left} vs #{right} is:#{bcost} wanted:#{cost}" unless bcost == cost
        bcost.should == cost
      end
    end
  end
end
