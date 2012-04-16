require 'set'

require 'statval'

module StatVal
  describe StatVal do

    it 'is instantiated' do
      @it = lambda { StatVal.new }
      @it.should_not raise_error
    end

    it 'collects statistics' do
      @it = StatVal.new
      @it << 0
      @it << 10
      @it << [0, 10]
      @it.<< 0, 10
      @it << @it
      @it << [@it, @it] # :)
      @it.avg.should be == 5.0
      @it.num.should be == 48
      @it.var.should be == 25.0
      @it.std.should be == 5.0
      @it.min.should be == 0
      @it.max.should be == 10
    end

    it 'is additive' do
      @one = StatVal.new
      @one << 10
      @one << 10
      @two = StatVal.new
      @two << 20
      @two << 20
      @it = @one + @two
      @it.avg.should be == 15.0
    end

    it 'resets' do
      @it = StatVal.new
      @it.reset num: 2, min: -2, max: +12, sum: 10, sq_sum: 148
      @it.num.should be == 2
      @it.min.should be == -2
      @it.max.should be == 12
      @it.sum.should be == 10
      @it.avg.should be == 5.0
      @it.sq_sum.should be == 148
      @it.var.should be == 49
      @it.std.should be == 7
    end

    it 'can be accessed like a hash' do
      @it = StatVal.new
      @it[:num] = 2
      @it[:min] = -2
      @it[:max] = 12
      @it[:sum] = 10
      @it[:sq_sum] = 148
      @it[:num].should be == 2
      @it[:min].should be == -2
      @it[:max].should be == 12
      @it[:sum].should be == 10
      @it[:avg].should be == 5.0
      @it[:sq_sum].should be == 148
      @it[:var].should be == 49
      @it[:std].should be == 7      
    end

    it 'renders hashes' do
      @it = StatVal.new
      @it.reset num: 2, min: -2, max: +12, sum: 10, sq_sum: 148
      @it = { a: 7, h: @it } 
      ::StatVal.map_hash(@it).keys.to_set.should be == [ :h, :a ].to_set
      ::StatVal.flatmap_hash(@it).keys.to_set.should be == [ 'a', 'num_h', 'std_h', 'min_h', 'max_h', 'avg_h' ].to_set
    end

    it 'times' do
      @it = StatVal.new
      @it.time {|| sleep(2) }
      @it.avg.should be > 2.0
      @it.avg.should be < 3.0
    end
  end
end