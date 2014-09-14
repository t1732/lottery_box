# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "lottery_box"
require "pp"

box = [
  {:robj => nil, :rate => 0.1},
  {:robj => nil, :rate => 0.1},
  {:robj => nil, :rate => 0.1},
  {:robj => nil, :rate => 0.3},
  {:robj => nil},
]

LotteryBox::Base.new(box).table.each do |attrs|
  p [attrs[:robj], "%.2f %%" % (attrs[:rate] * 100)]
end

box = [
  {:robj=> :nil, :rate => 0.2},
  {:robj=> :nil},
  {:robj=> :nil},
  {:robj=> :nil},
  {:robj=> :nil},
  {:robj=> :nil},
  {:robj=> :nil},
  {:robj=> :nil},
]
LotteryBox::Base.new(box).table.each do |attrs|
  p [attrs[:robj], "%.2f %%" % (attrs[:rate] * 100)]
end
# >> [nil, "10.00 %"]
# >> [nil, "10.00 %"]
# >> [nil, "10.00 %"]
# >> [nil, "30.00 %"]
# >> [nil, "40.00 %"]
# >> [:nil, "20.00 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
# >> [:nil, "11.43 %"]
