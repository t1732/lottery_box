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
        other_rate = (BigDecimal(1) - BigDecimal(total.to_s)) / BigDecimal(group0.size) # 小数の場合 to_s で渡さないと怒られる
      end
      last_rate = BigDecimal("0.0")
      table = (group1 + group0).collect do |e|
        rate = BigDecimal((e[@rate_key] || other_rate).to_s)
        {:range => last_rate ... (last_rate + rate), :robj => e[:robj]}.tap { last_rate += rate }
      end
      # BigDecimal で計算して最後に to_f で戻せば 0.9999999999999999999999999999 や 1.000000000000000000000001 が 1.0 になる
      last_rate = last_rate.to_f
      if last_rate > 1.0
        raise "確率の合計値が1.0を越えている"
      end
      if group0.size > 0 && last_rate < 1.0
        raise "はずれ要素があるのにもかかわらず最後が 1.0 になっていない"
      end
      # はずれ要素がない場合のみ 1.0 に届かないため補完する
      if last_rate < 1.0
        table << {:range => last_rate...1.0, :robj => nil}
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
