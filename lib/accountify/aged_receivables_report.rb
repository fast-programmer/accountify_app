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
        start_date = case period_unit
                     when :month
                       as_at_date + (i - 1) * period_frequency.months
                     when :week
                       as_at_date + (i - 1) * period_frequency.weeks
                     when :day
                       as_at_date + (i - 1) * period_frequency.days
                     end

        end_date = case period_unit
                   when :month
                     as_at_date + i * period_frequency.months - 1.day
                   when :week
                     as_at_date + i * period_frequency.weeks - 1.day
                   when :day
                     as_at_date + i * period_frequency.days - 1.day
                   end
        { start_date: start_date, end_date: end_date }
      end

      period_dates.each do |period|
        sub_total = Models::Invoice
          .where(iam_tenant_id: iam_tenant_id)
          .where(currency_code: currency_code)
          .where("#{ageing_by} >= ? AND #{ageing_by} <= ?", period[:start_date], period[:end_date])
          .sum(:sub_total_amount)

        report.periods.create!(
          start_date: period[:start_date],
          end_date: period[:end_date],
          sub_total: sub_total)
      end

      report
    end
  end
end
