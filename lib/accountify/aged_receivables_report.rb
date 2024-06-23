module Accountify
  module AgedReceivablesReport
    extend self

    def generate(iam_tenant_id:,
                 as_at_date: Date.today, currency_code: 'AUD',
                 num_periods: 4, period_frequency: 1, period_unit: :month,
                 ageing_by: :due_date)
      report = Models::AgedReceivablesReport.create(
        iam_tenant_id: iam_tenant_id,
        as_at_date: as_at_date,
        currency_code: currency_code,
        num_periods: num_periods,
        period_frequency: period_frequency,
        period_unit: period_unit,
        ageing_by: ageing_by)

      period_dates = (1..num_periods).map do |i|
        case period_unit
        when :month
          as_at_date + i.months * period_frequency - 1.day
        when :week
          as_at_date + i.weeks * period_frequency - 1.day
        when :day
          as_at_date + i.day * period_frequency - 1.day
        else
          raise ArgumentError, "Unsupported period unit: #{period_unit}"
        end
      end

      ([as_at_date] + period_dates).each_cons(2) do |start_date, end_date|
        sub_total = Models::Invoice
          .where(iam_tenant_id: iam_tenant_id)
          .where(currency_code: currency_code)
          .where("#{ageing_by} >= ? AND #{ageing_by} <= ?", start_date, end_date)
          .sum(:sub_total_amount)

        report.periods.create!(start_date: start_date, end_date: end_date, sub_total: sub_total)
      end

      report
    end
  end
end
