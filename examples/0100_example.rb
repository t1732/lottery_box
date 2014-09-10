# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "lottery_box"
require "pp"

box = [
  {:robj => "S", :rate => 0.01},
  {:robj => "A", :rate => 0.1},
  {:robj => "B", :rate => 0.2},
  {:robj => "C"},
]

10000.times.each_with_object(Hash.new(0)){|*, m| m[LotteryBox.pick(box)] += 1 }.sort_by{|k, v|v} # => [["S", 106], ["A", 1031], ["B", 1969], ["C", 6894]]

pp LotteryBox::Base.new(box).table
# >> [{:range=>
# >>    #<BigDecimal:7fbc5117e458,'0.0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fbc5117e110,'0.1E-1',9(27)>,
# >>   :robj=>"S"},
# >>  {:range=>
# >>    #<BigDecimal:7fbc5117df80,'0.1E-1',9(27)>
# >>    ...
# >>    #<BigDecimal:7fbc5117ddc8,'0.11E0',9(18)>,
# >>   :robj=>"A"},
# >>  {:range=>
# >>    #<BigDecimal:7fbc5117dc60,'0.11E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fbc5117da58,'0.31E0',9(18)>,
# >>   :robj=>"B"},
# >>  {:range=>
# >>    #<BigDecimal:7fbc5117d8f0,'0.31E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fbc5117d710,'0.1E1',9(18)>,
# >>   :robj=>"C"}]
