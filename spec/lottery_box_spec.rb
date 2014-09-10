# -*- coding: utf-8 -*-
require "spec_helper"

describe do
  def pick(box, options = {})
    LotteryBox.pick(box, options)
  end

  describe "補完" do
    it "かならず合計1.0になるように補完する" do
      LotteryBox::Base.new([]).table.should == [{:range => 0.0...1.0, :robj => nil}]
      LotteryBox::Base.new([:robj => nil, :rate => 0.4]).table.should == [{:range => 0.0...0.4, :robj => nil}, {:range=>0.4...1.0, :robj => nil}]
    end

    it "はずれ要素を先頭に定義しても余分な補完が発生しない(ここがバグっていた)" do
      LotteryBox::Base.new([{:robj => "A"}, {:robj => "S", :rate => 0.1}]).table.should == [{:range => 0.0...0.1, :robj => "S"}, {:range => 0.1...1.0, :robj => "A"}]
    end
  end

  it "ハズレが8個で確率が0.7の場合、小数の誤差が発生して合計が1.0を越えてしまう不具合をBigDecimalで回避" do
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
    LotteryBox::Base.new(box)
  end

  it "確率の合計が 0..1.0 の範囲外" do
    expect { LotteryBox::Base.new([{:rate => 1.1}]) }.to raise_error(ArgumentError)
    expect { LotteryBox::Base.new([{:rate => -0.1}]) }.to raise_error(ArgumentError)
  end

  describe LotteryBox::RateStrategy do
    it "指定がなくてもエラーにならない(ミスを放置するため検討中)" do
      pick([]).should == nil
    end
    it "ハズレが指定されてなくてもアタリだけで合計1.0にできればエラーにならない" do
      pick([{:rate => 1.0, :robj => :xxx}]).should == :xxx
    end
    it "ハズレは自動補完されるので明示的に指定しなくてもいい" do
      pick([{:rate => 0.2, :robj => :xxx}], :strategy => LotteryBox::RateStrategy.new(0)).should == :xxx
      pick([{:rate => 0.2, :robj => :xxx}], :strategy => LotteryBox::RateStrategy.new(0.2)).should == nil
    end
    it "オブジェクトが nil のものもあり(ただし指定を間違えた可能性もあるため検討中)" do
      pick([{:rate => 1.0, :robj => nil}]).should == nil
    end
    it "オブジェクトしか指定されてない" do
      pick([{:robj => :xxx}]).should == :xxx
    end
  end

  describe "CycleStrategy" do
    before do
      LotteryBox::CycleStrategy.index = 0
    end
    it "3回目は指定してないハズレが引かれる" do
      box = [{:rate => 0.5, :robj => :a}, {:rate => 0.4, :robj => :b}]
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :a
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :b
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == nil
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :a
    end
    it "ハズレがないので引かれない" do
      box = [{:rate => 0.5, :robj => :a}, {:rate => 0.5, :robj => :b}]
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :a
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :b
      pick(box, :strategy => LotteryBox::CycleStrategy.new).should == :a
    end
  end

  it "SampleStrategy" do
    pick([], :strategy => LotteryBox::SampleStrategy.new)
    pick([{:robj => :a}, {:robj => :b}], :strategy => LotteryBox::SampleStrategy.new)
  end

  it "OnlyStrategy" do
    pick([{:robj => :a}, {:robj => :b}], :strategy => LotteryBox::OnlyStrategy.new(1)).should == :b
  end
end
