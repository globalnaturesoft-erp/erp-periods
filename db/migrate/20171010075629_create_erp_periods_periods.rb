class CreateErpPeriodsPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_periods_periods do |t|
      t.string :name
      t.datetime :from_date
      t.datetime :to_date
      t.string :status
      t.references :creator, index: true, references: :erp_users

      t.timestamps
    end
  end
end
