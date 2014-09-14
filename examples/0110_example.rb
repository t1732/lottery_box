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

# 普通の使い方
LotteryBox.pick(box)            # => "C"

# 分布数を確認する例
10000.times.each_with_object(Hash.new(0)){|*, m| m[LotteryBox.pick(box)] += 1 }.sort_by{|k, v|v} # => [["S", 102], ["A", 1000], ["B", 2002], ["C", 6896]]

# 各レートをパーセンテージに変換する例
LotteryBox::Base.new(box).table.each do |attrs|
  p [attrs[:robj], "%.2f %%" % (attrs[:rate] * 100)]
end
# >> ["S", "1.00 %"]
# >> ["A", "10.00 %"]
# >> ["B", "20.00 %"]
# >> ["C", "69.00 %"]
