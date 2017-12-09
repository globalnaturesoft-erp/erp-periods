module Erp::Periods
  class Period < ApplicationRecord
    belongs_to :creator, class_name: 'Erp::User'
    validates :name, :from_date, :to_date, presence: true

    # class const
    STATUS_ACTIVE = 'active'
    STATUS_DELETED = 'deleted'

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash

      # join with users table for search creator
      query = query.joins(:creator)

      and_conds = []

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end

      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      else
				query = query.order('created_at desc')
      end

      return query
    end

    # data for dataselect ajax
    def self.dataselect(keyword='', params='')

      query = self.where(status: Erp::Periods::Period::STATUS_ACTIVE)

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end

      query = query.order("created_at DESC").limit(20).map{|period| {value: period.id, text: period.name} }
    end

    def set_active
      update_columns(status: Erp::Periods::Period::STATUS_ACTIVE)
    end

    def set_deleted
      update_columns(status: Erp::Periods::Period::STATUS_DELETED)
    end

    def self.set_active_all
      update_all(status: Erp::Periods::Period::STATUS_ACTIVE)
    end

    def self.set_deleted_all
      update_all(status: Erp::Periods::Period::STATUS_DELETED)
    end

    def is_deleted?
      return status == Erp::Periods::Period::STATUS_DELETED
    end

    # Get time array
    def self.get_time_array(params={})
			times = []

			@today = Date.today

			# global filter
      global_filter = params[:global_filter]
      if global_filter.present?
				# filter by from date
				if global_filter[:to_date].present?
					@today = global_filter[:to_date].to_date
				end
      end

			number_of_months = 0..@today.month

			number_of_months.to_a.reverse.each do |month_offset|
				date = @today - month_offset.months
				if month_offset == @today.month
					start_date = date.beginning_of_year
					end_date = date.end_of_year
					times << {name: "#{I18n.t('erp.periods.year')} #{date.year}" , from: start_date, to: end_date}
				else
					start_date = date.beginning_of_month
					end_date = date.end_of_month
					times << {name: "#{I18n.t('erp.periods.month')} #{date.month}/#{date.year}", from: start_date, to: end_date}
				end
			end
			return times
		end

    # auto create an year periods
    def self.create_year_periods(year)
      date = "#{year}-01-01".to_date.beginning_of_year

      return false if !self.where("to_date >= ?", date).empty?

      # 12 months
      (0..11).each do |i|
        month = date + i.months
        self.create(
          name: "Tháng #{i+1}/#{date.year}",
          from_date: month.beginning_of_month,
          to_date: month.end_of_month,
          creator_id: Erp::User.first.id,
          status: self::STATUS_ACTIVE,
        )
      end

      # 4 quaters
      self.create(
        name: "Quý 1/#{date.year}",
        from_date: date.beginning_of_month,
        to_date: (date + 2.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )
      self.create(
        name: "Quý 2/#{date.year}",
        from_date: (date + 3.months).beginning_of_month,
        to_date: (date + 5.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )
      self.create(
        name: "Quý 3/#{date.year}",
        from_date: (date + 6.months).beginning_of_month,
        to_date: (date + 8.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )
      self.create(
        name: "Quý 4/#{date.year}",
        from_date: (date + 9.months).beginning_of_month,
        to_date: (date + 11.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )

      # half year
      self.create(
        name: "Nửa đầu năm #{date.year}",
        from_date: date.beginning_of_month,
        to_date: (date + 5.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )
      self.create(
        name: "Nửa sau năm #{date.year}",
        from_date: (date + 6.months).beginning_of_month,
        to_date: (date + 11.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )

      # whole year
      self.create(
        name: "Năm #{date.year}",
        from_date: date.beginning_of_month,
        to_date: (date + 11.months).end_of_month,
        creator_id: Erp::User.first.id,
        status: self::STATUS_ACTIVE,
      )
    end
  end
end
