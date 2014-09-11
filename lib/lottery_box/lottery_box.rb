# -*- coding: utf-8 -*-
#
# 抽選
#
#   ・アタリだけにrateを指定することで設定が楽になる
#   ・rateの合計は 0..1.0 の範囲内でなければならない
#   ・どのように抽選するかはストラテジーだけが知っている
#
# 使い方
#
#   lottery_box = [
#     {:robj => "S", :rate => 0.01},
#     {:robj => "A", :rate => 0.1},
#     {:robj => "B"},
#   ]
#   LotteryBox.pick(lottery_box)    # => "B"
#

require "active_support/core_ext/class/attribute_accessors"
require "active_support/configurable"
require "bigdecimal"

module LotteryBox
  include ActiveSupport::Configurable
  config.default_strategy = -> { RateStrategy.new }

  def self.pick(*args)
    Base.new(*args).pick
  end

  class Base
    attr_accessor :box, :table, :rate_key

    def initialize(box, rate_key: nil, strategy: nil)
      @box = box
      @rate_key = rate_key || :rate
      @strategy = strategy || LotteryBox.config.default_strategy.call
      @table = table_build
    end

    def pick
      return if @table.empty?
      if e = @strategy.pick_element(@table)
        e[:robj]
      end
    end

    def table_build
      @rate_key or raise
      assert_robj_exist
      group = @box.group_by{|e|!!e[@rate_key]}
      group0 = group[false] || [] # はずれ
      group1 = group[true] || []  # あたり
      total = group1.collect{|e|e[@rate_key]}.reduce(0, :+)
      assert_total(total)
      other_rate = 0
      if group0.size > 0
        other_rate = (1.0r - Rational(total)) / Rational(group0.size) # 小数の場合 to_s で渡さないと怒られる
      end
      last_rate = 0.0r
      table = []
      (group1 + group0).each do |e|
        rate = Rational(e[@rate_key] || other_rate)
        range = last_rate ... (last_rate + rate)
        table << {:range => range, :rate => rate, :robj => e[:robj]}
        last_rate += rate
      end
      # BigDecimal で計算して最後に to_f で戻せば 0.9999999999999999999999999999 や 1.000000000000000000000001 が 1.0 になる
      if last_rate >= (1.0 + Float::EPSILON)
        raise "確率の合計値が1.0を越えている"
      end
      if group0.size > 0 && (last_rate - 1.0).abs > Float::EPSILON
        raise "はずれ要素があるのにもかかわらず最後が 1.0 になっていない : #{last_rate}"
      end
      # はずれ要素がない場合のみ 1.0 に届かないため補完する
      if last_rate <= (1.0 - Float::EPSILON)
        table << {:range => last_rate...1.0, :rate => 1.0 - last_rate, :robj => nil}
      end
      table
    end

    def assert_robj_exist
      @box.each do |e|
        unless e.has_key?(:robj)
          raise ArgumentError, "nil を返す場合であったとしても robj は必ず指定してください : #{e.inspect} #{@box.inspect}"
        end
      end
    end

    def assert_total(total)
      unless (0..1.0).include?(total)
        raise ArgumentError, "確率の合計が 0..1.0 の範囲外になっています : #{total} #{@box.inspect}"
      end
    end
  end

  # 確率 (本番用)
  class RateStrategy
    def initialize(r = rand)
      @r = r
    end

    def pick_element(table)
      table.find{|e|e[:range].include?(@r)}
    end
  end

  # 順番に要素を返す (開発用)
  class CycleStrategy
    cattr_accessor :index
    @@index ||= 0

    def pick_element(table)
      table[@@index.modulo(table.size)].tap { @@index += 1 }
    end
  end

  # 一様にサンプルする (開発用)
  class SampleStrategy
    def pick_element(table)
      table.sample
    end
  end

  # 指定インデックスの要素を返す(テスト用)
  class OnlyStrategy
    def initialize(index)
      @index = index
    end

    def pick_element(table)
      table[@index]
    end
  end
end
