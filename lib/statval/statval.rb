module StatVal

  class StatVal

    attr_reader :num
    attr_reader :min
    attr_reader :max
    attr_reader :sum
    attr_reader :sq_sum

    def initialize(options = {}) ; reset(options) end

    def reset(options = {})
      options[:num] = 0 unless options[:num]
      options[:min] = nil unless options[:min]
      options[:max] = nil unless options[:max]
      options[:sum] = 0 unless options[:sum]
      options[:sq_sum] = 0 unless options[:sq_sum]
      options.each_pair { |k, v| self[k] = v}
      options
    end

    def keys ; ::StatVal.keys(:default) end

    def [](key)
      case key
        when :num then num
        when :min then min
        when :max then max
        when :sum then sum
        when :sq_sum then sq_sum
        when :avg then avg
        when :std then std
        when :avg_sq then avg_sq
        when :var then var
        else
          raise ArgumentError
      end
    end

    def []=(key, new_val)
      case key
        when :num then self.num = new_val
        when :min then self.min = new_val
        when :max then self.max = new_val
        when :sum then self.sum = new_val
        when :sq_sum then self.sq_sum = new_val
        else
          raise ArgumentError
      end
    end

    def each_pair
      this = self
      keys.each { | key| yield key, this[key] }
    end

    alias_method :each, :each_pair

    def values
      this = self
      keys.map { |key| this[key] }
    end

    def +(value) ; self.class.new << self << value end

    def <<(value, *rest)
      this = self
      if value.kind_of? StatVal
        if empty?
          reset(value.to_hash(:writable))
        else
          begin
            @num    += value.num
            @sum    += value.sum
            @sq_sum += value.sq_sum
            val_min  = value.min
            val_max  = value.max
            @min     = val_min if val_min < @min
            @max     = val_max if val_max > @max
          end unless value.empty?
        end
      else
        if value.kind_of? Numeric
          @sum       += value
          @sq_sum    += value * value
          @num       += 1
          @min        = value if value < @min
          @max        = value if value > @max
        else
          if value.respond_to?(:each_pair)
            value.each_pair { |k, v| this << v } 
          else 
            if value.respond_to?(:each)
              value.each { |v| this << v } 
            else
              raise ArgumentError
            end
          end
        end
      end
      rest.each { |v| this << v } if rest
      this
    end

    def time
      start = Time.now
      begin
        yield
      ensure
        stop = Time.now
        self << (stop-start)
      end
    end
    
    def to_hash(which_keys = nil, convert_to_s = false)
      ::StatVal.key_hash(which_keys).inject({}) { |h, (attr, name)| h[(if convert_to_s then name.to_s else name end)] = self[attr]; h }
    end

    def to_s ; to_hash.to_s end

    def empty? ; @num == 0 end

    def bounded? ; ! (abs_is_infinite(@min) || abs_is_infinite(@max)) end

    def avg ; if empty? then zero_if_unbounded(abs_div(@max - @min, 2)) else abs_div(@sum, @num) end end

    def avg_sq
      if empty? then zero_if_unbounded(abs_div((@max*@max) - (@min*@min), 2)) else abs_div(@sq_sum, @num) end
    end

    def var ; avg_sq - (avg * avg) end

    def std ; Math.sqrt(var) end

    def num=(new_val)
      raise ArgumentError if new_val < 0
      @num = new_val
    end

    def sum=(new_val)
      raise ArgumentError if new_val < 0
      @sum= new_val
    end

    def sq_sum=(new_val)
      raise ArgumentError if new_val < 0
      @sq_sum= new_val
    end

    def min=(new_val)
      @min = if new_val then new_val else (if empty? then POS_INFINITY else avg-std end) end
    end

    def max=(new_val)
      @max = if new_val then new_val else (if empty? then NEG_INFINITY else avg+std end) end
    end

    def std_ratio ; std / avg end

    private

    POS_INFINITY =   1.0/0.0
    NEG_INFINITY = - 1.0/0.0

    def abs_is_infinite(val) ; val.abs.to_f === POS_INFINITY end
    def zero_if_unbounded(val) ; if bounded? then val else 0.0 end end
    def abs_div(nom, denom) ; nom.abs.to_f / denom end
  end

  def self.new(options = {}) ; StatVal.new(options) end

  def self.all_keys ; [ :avg, :std, :std_ratio, :min, :max, :num, :sum, :sq_sum, :avg_sq, :var ] end
  def self.default_keys ; [ :avg, :std, :min, :max, :num ] end
  def self.writable_keys ; [ :num, :min, :max, :sum, :sq_sum ] end

  def self.keys(ident = :default)
    case ident
    when :all then all_keys
    when :writable then writable_keys
    when :default then default_keys
    when nil then default_keys
    else
      return ident if ident.respond_to?(:each)
      return [ident]
    end
  end

  def self.key_hash(which_keys = nil)
    return which_keys if which_keys.is_a?(Hash)
    keys(which_keys).inject({}) { |h, k| h[k] = k; h }
  end

  # Take hash that contains StatVal values and create new hash that is identical to it but has
  # the StatVal values v replaced by v.to_hash(which_keys)
  #
  # Just copies non-StatVal entries
  #
  def self.map_hash(h, which_keys = nil)
    r = {}
    h.each_pair { |k,v| r[k] = if v.kind_of?(StatVal) then v.to_hash(which_keys) else v end }
    r
  end

  # Like map_hash, but flattens converted StatVal values such there attributes get pre- or appended
  # with their key in the outer hash
  #
  # All symbols
  # raises on key conflict
  #
  def self.flatmap_hash(h, which_keys = nil, prefix=true, use_symbols=false)
    return h.to_hash(which_keys, ! use_symbols) if h.kind_of?(StatVal)

    flat = {}
    h.each_pair do |k,r|
      if r.kind_of? StatVal
        results = r.to_hash(which_keys)
        results.each_pair do |tag,val|
          new_tag = if prefix then "#{tag}_#{k}" else "#{k}_#{tag}" end
          new_tag = new_tag.to_sym if use_symbols

          raise ArgumentError if flat[new_tag]
          flat[new_tag] = val
        end
      else
        raise ArgumentError if flat[k]
        if k.is_a?(Symbol) && !use_symbols
          flat[k.to_s] = r
        else
          flat[k] = r
        end
      end
    end
    flat
  end

end
