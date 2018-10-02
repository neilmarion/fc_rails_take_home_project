class Item < ActiveRecord::Base

  CLEARANCE_PRICE_PERCENTAGE  = BigDecimal.new("0.75")

  belongs_to :style
  belongs_to :clearance_batch

  scope :sellable, -> { where(status: 'sellable') }

  def clearance!
    update_attributes!(status: 'clearanced', 
                       price_sold: get_price_sold)
  end

  private

  def get_price_sold
    [style.wholesale_price * CLEARANCE_PRICE_PERCENTAGE, style.floor_price_sold.to_f].max
  end

end
