# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "lottery_box"
require "pp"

box = [
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "R"},
  {:robj => "S", :rate => 0.2},
  {:robj => "R"},
]

pp LotteryBox::Base.new(box).table
# >> [{:range=>
# >>    #<BigDecimal:7fa671266280,'0.0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa671265fd8,'0.2E0',9(27)>,
# >>   :robj=>"S"},
# >>  {:range=>
# >>    #<BigDecimal:7fa671265ec0,'0.2E0',9(27)>
# >>    ...
# >>    #<BigDecimal:7fa671265cb8,'0.3E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa671265c18,'0.3E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa671265a60,'0.4E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa671265948,'0.4E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa671265858,'0.5E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa6712656f0,'0.5E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa671265560,'0.6E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa671265628,'0.6E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa67125ff98,'0.7E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa67125fd18,'0.7E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa67125fb60,'0.8E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa67125f980,'0.8E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa67125f8b8,'0.9E0',9(18)>,
# >>   :robj=>"R"},
# >>  {:range=>
# >>    #<BigDecimal:7fa67125f750,'0.9E0',9(18)>
# >>    ...
# >>    #<BigDecimal:7fa67125f598,'0.1E1',9(18)>,
# >>   :robj=>"R"}]
