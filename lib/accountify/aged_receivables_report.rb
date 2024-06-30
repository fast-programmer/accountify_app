module Accountify
  module AgedReceivablesReport
    extend self

    def generate(iam_tenant_id:,
                 as_at_date:, num_periods:, period_amount:, period_unit:,
                 ageing_by:, currency_code:)
      validate(
        iam_tenant_id: iam_tenant_id,
        as_at_date: as_at_date,
        num_periods: num_periods,
        period_amount: period_amount,
        period_unit: period_unit,
        ageing_by: ageing_by,
        currency_code: currency_code)

      period_ranges = generate_period_ranges(
        as_at_date: as_at_date,
        num_periods: num_periods,
        period_amount: period_amount,
        period_unit: period_unit)

      id = nil

      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        current_utc_time = Time.current.utc

        report = Models::AgedReceivablesReport.create(
          iam_tenant_id: iam_tenant_id,
          as_at_date: as_at_date,
          currency_code: currency_code,
          num_periods: num_periods,
          period_amount: period_amount,
          period_unit: period_unit,
          ageing_by: ageing_by,
          created_at: current_utc_time,
          updated_at: current_utc_time)

        period_ranges.each do |period_range|
          sub_total_amount = Models::Invoice
            .where(iam_tenant_id: iam_tenant_id)
            .where(sub_total_currency_code: currency_code)
            .where(
              "#{ageing_by} >= ? AND #{ageing_by} <= ?",
              period_range[:start_date], period_range[:end_date])
            .sum(:sub_total_amount)

          report.periods.create!(
            start_date: period_range[:start_date],
            end_date: period_range[:end_date],
            sub_total_amount: sub_total_amount,
            sub_total_currency_code: currency_code)
        end

        id = report.id
      end

      find_by_id(iam_tenant_id: iam_tenant_id, id: id)
    end

    def find_by_id(iam_tenant_id:, id:)
      report = nil

      ActiveRecord::Base.transaction(isolation: :repeatable_read) do
        report = Models::AgedReceivablesReport
          .includes(:periods)
          .where(iam_tenant_id: iam_tenant_id)
          .find_by!(id: id)
      end

      {
        id: report.id,
        as_at_date: report.as_at_date,
        currency_code: report.currency_code,
        num_periods: report.num_periods,
        period_amount: report.period_amount,
        period_unit: report.period_unit.to_sym,
        created_at: report.created_at,
        updated_at: report.updated_at,
        periods: report.periods.map do |period|
          {
            start_date: period.start_date,
            end_date: period.end_date,
            sub_total: {
              amount: period.sub_total_amount,
              currency_code: period.sub_total_currency_code
            }
          }
        end
      }
    end

    def generate_period_ranges(as_at_date:, num_periods:, period_amount:, period_unit:)
      (1..num_periods).map do |i|
        start_date =
          case period_unit
          when :month
            as_at_date + ((i - 1) * period_amount.months)
          when :week
            as_at_date + ((i - 1) * period_amount.weeks)
          when :day
            as_at_date + ((i - 1) * period_amount.days)
          end

        end_date =
          case period_unit
          when :month
            as_at_date + (i * period_amount.months) - 1.day
          when :week
            as_at_date + (i * period_amount.weeks) - 1.day
          when :day
            as_at_date + (i * period_amount.days) - 1.day
          end

        { start_date: start_date, end_date: end_date }
      end
    end

    def validate(iam_tenant_id:,
                 as_at_date:, num_periods:, period_amount:, period_unit:,
                 ageing_by:, currency_code:)
      if !as_at_date.is_a?(Date)
        raise ArgumentError.new('as_at_date must be a valid date')
      end

      if !num_periods.is_a?(Integer)
        raise ArgumentError.new('num_periods must be an integer')
      end

      if !period_amount.is_a?(Integer)
        raise ArgumentError.new('period_amount must be an integer')
      end

      if !period_unit.is_a?(Symbol)
        raise ArgumentError.new('period_unit must be a symbol')
      end

      if !ageing_by.is_a?(Symbol)
        raise ArgumentError.new('ageing_by must be a symbol')
      end

      if !currency_code.is_a?(String)
        raise ArgumentError.new('currency_code must be a string')
      end

      if !(1..24).include?(num_periods)
        raise ArgumentError.new('num_periods must be within range 1..24 inclusive')
      end

      if !(1..24).include?(period_amount)
        raise ArgumentError.new('period_amount must be within range 1..24 inclusive')
      end

      if ![:day, :week, :month].include?(period_unit)
        raise ArgumentError.new('period_unit must be :day, :week, or :month')
      end

      if ![:issue_date, :due_date].include?(ageing_by)
        raise ArgumentError.new('ageing_by must be :issue_date or :due_date')
      end

      if !['AUD'].include?(currency_code)
        raise ArgumentError.new("currency_code must be 'AUD'")
      end
    end
  end
end
