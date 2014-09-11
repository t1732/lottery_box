# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "lottery_box"
require "pp"

100000.times do |i|
  box = []
  n = 50
  rand(1..n).times {
    hash = {:robj => nil}
    if rand(5).zero?
      hash[:rate] = rand(0.0 .. (1.0 / n))
    end
    box << hash
  }
  LotteryBox::Base.new(box)
end
