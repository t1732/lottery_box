# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "pp"

require "lottery_box"

box = [
  {:robj => "S", :rate => 0.1},
  {:robj => "R", :rate => 0.2},
  {:robj => "N"},
]
LotteryBox.pick(box)            # => "N"
