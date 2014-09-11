# -*- coding: utf-8 -*-
require "test_helper"

class TestLotteryBox < Test::Unit::TestCase
  sub_test_case "補完" do
    test "かならず合計1.0になるように補完する" do
      assert_table [{:range => 0.0...1.0, :rate => 1.0, :robj => nil}], LotteryBox::Base.new([]).table
      assert_table [{:range => 0.0...0.4, :rate => 0.4, :robj => nil}, {:range => 0.4...1.0, :rate => 0.6, :robj => nil}], LotteryBox::Base.new([:robj => nil, :rate => 0.4]).table
    end

    test "はずれ要素を先頭に定義しても余分な補完が発生しない(ここがバグっていた)" do
      assert_table [{:range => 0.0...0.1, :rate => 0.1, :robj => "S"}, {:range => 0.1...1.0, :rate => 0.9, :robj => "A"}], LotteryBox::Base.new([{:robj => "A"}, {:robj => "S", :rate => 0.1}]).table
    end
  end

  test "ハズレが8個で確率が0.7の場合、小数の誤差が発生して合計が1.0を越えてしまう不具合をBigDecimalで回避" do
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

  test "確率の合計が 0..1.0 の範囲外" do
    assert_raises(ArgumentError) { LotteryBox::Base.new([{:rate => 1.1}]) }
    assert_raises(ArgumentError) { LotteryBox::Base.new([{:rate => -0.1}]) }
  end

  sub_test_case LotteryBox::RateStrategy do
    test "指定がなくてもエラーにならない(ミスを放置するため検討中)" do
      assert_equal nil, pick([])
    end
    test "ハズレが指定されてなくてもアタリだけで合計1.0にできればエラーにならない" do
      assert_equal :xxx, pick([{:rate => 1.0, :robj => :xxx}])
    end
    test "ハズレは自動補完されるので明示的に指定しなくてもいい" do
      assert_equal :xxx, pick([{:rate => 0.2, :robj => :xxx}], :strategy => LotteryBox::RateStrategy.new(0))
      assert_equal nil, pick([{:rate => 0.2, :robj => :xxx}], :strategy => LotteryBox::RateStrategy.new(0.2))
    end
    test "オブジェクトが nil のものもあり(ただし指定を間違えた可能性もあるため検討中)" do
      assert_equal nil, pick([{:rate => 1.0, :robj => nil}])
    end
    test "オブジェクトしか指定されてない" do
      assert_equal :xxx, pick([{:robj => :xxx}])
    end
  end

  sub_test_case "CycleStrategy" do
    setup do
      LotteryBox::CycleStrategy.index = 0
    end
    test "3回目は指定してないハズレが引かれる" do
      box = [{:rate => 0.5, :robj => :a}, {:rate => 0.4, :robj => :b}]
      assert_equal :a, pick(box, :strategy => LotteryBox::CycleStrategy.new)
      assert_equal :b, pick(box, :strategy => LotteryBox::CycleStrategy.new)
      assert_equal nil, pick(box, :strategy => LotteryBox::CycleStrategy.new)
      assert_equal :a, pick(box, :strategy => LotteryBox::CycleStrategy.new)
    end
    test "ハズレがないので引かれない" do
      box = [{:rate => 0.5, :robj => :a}, {:rate => 0.5, :robj => :b}]
      assert_equal :a, pick(box, :strategy => LotteryBox::CycleStrategy.new)
      assert_equal :b, pick(box, :strategy => LotteryBox::CycleStrategy.new)
      assert_equal :a, pick(box, :strategy => LotteryBox::CycleStrategy.new)
    end
  end

  test "SampleStrategy" do
    pick([], :strategy => LotteryBox::SampleStrategy.new)
    pick([{:robj => :a}, {:robj => :b}], :strategy => LotteryBox::SampleStrategy.new)
  end

  test "OnlyStrategy" do
    assert_equal :b, pick([{:robj => :a}, {:robj => :b}], :strategy => LotteryBox::OnlyStrategy.new(1))
  end

  private

  def pick(box, options = {})
    LotteryBox.pick(box, options)
  end

  def assert_table(expected, table)
    assert_equal normalize(expected), normalize(table)
  end

  def normalize(table)
    table.collect {|e| e.merge(:rate => e[:rate].to_f, :range => (e[:range].begin.to_f...e[:range].end.to_f)) }
  end
end
