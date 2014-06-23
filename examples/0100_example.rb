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

10000.times.each_with_object(Hash.new(0)){|*, m| m[LotteryBox.pick(box)] += 1 }.sort_by{|k, v|v} # => [["S", 113], ["A", 986], ["B", 1991], ["C", 6910]]

pp LotteryBox::Base.new(box).table
# >> [{:range=>0.0...0.01, :robj=>"S"},
# >>  {:range=>0.01...0.11, :robj=>"A"},
# >>  {:range=>0.11...0.31, :robj=>"B"},
# >>  {:range=>0.31...1.0, :robj=>"C"}]
