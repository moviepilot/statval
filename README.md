statval
=======

Very simple incremental statisctics collector

    require 'statval'
    s = StatVal.new
    => {:avg=>0.0, :std=>0.0, :min=>Infinity, :max=>-Infinity, :num=>0, :sum=>0, :sq_sum=>0, :avg_sq=>0.0, :var=>0.0}

    s << 10
    s << 20
    s << 30
    s.to_hash
    => {:avg=>20.0, :std=>8.16496580927726, :min=>10, :max=>30}

    s.to_hash(:all)
    => {:avg=>20.0, :std=>8.16496580927726, :min=>10, :max=>30, :num=>3, :sum=>60, :sq_sum=>1400, :avg_sq=>466.6666666666667, :var=>66.66666666666669}

    s[:max]=40
    h = { :a => 5, :s => s }
    => {:a=>5, :s=>{:avg=>20.0, :std=>8.16496580927726, :min=>10, :max=>40, :num=>3, :sum=>60, :sq_sum=>1400, :avg_sq=>466.6666666666667, :var=>66.66666666666669}}

    StatVal.map_hash(h)
    => {:a=>5, :s=>{:avg=>20.0, :std=>8.16496580927726, :min=>10, :max=>40}}

    StatVal.flatmap_hash(h, :all)
    => {:a=>5, "s_avg"=>20.0, "s_std"=>8.16496580927726, "s_min"=>10, "s_max"=>40, "s_num"=>3, "s_sum"=>60, "s_sq_sum"=>1400, "s_avg_sq"=>466.6666666666667, "s_var"=>66.66666666666669}

