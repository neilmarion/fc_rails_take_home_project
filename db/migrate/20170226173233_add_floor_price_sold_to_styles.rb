class AddFloorPriceSoldToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :floor_price_sold, :decimal, null: true
  end
end
