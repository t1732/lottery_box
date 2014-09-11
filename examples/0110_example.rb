# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "lottery_box"
require "pp"

box = [
  {:robj => "S", :rate => 0.2},
  {:robj => "N"},
  {:robj => "N"},
  {:robj => "N"},
  {:robj => "N"},
  {:robj => "N"},
  {:robj => "N"},
  {:robj => "N"},
]

LotteryBox::Base.new(box).table.each do |attrs|
  p [attrs[:robj], "%.2f %%" % (attrs[:rate] * 100)]
end
# >> ["S", "20.00 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
# >> ["N", "11.43 %"]
