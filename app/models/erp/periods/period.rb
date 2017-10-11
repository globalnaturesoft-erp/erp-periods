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
  end
end
