require 'rails_helper'

describe Item do
  describe "#perform_clearance!" do
    before do
      item.clearance!
      item.reload
    end

    context "style type of item is not a 'Dress' or 'Pants'" do
      let(:wholesale_price) { 100 }
      let(:item) { FactoryGirl.create(:item, style: FactoryGirl.create(:style, wholesale_price: wholesale_price)) }

      it "should mark the item status as clearanced" do
        expect(item.status).to eq("clearanced")
      end

      it "should set the price_sold as 75% of the wholesale_price" do
        expect(item.price_sold).to eq(BigDecimal.new(wholesale_price) * BigDecimal.new("0.75"))
      end
    end

    context "style type of item has a floor_price_sold" do
      let(:wholesale_price) { 6 }
      let(:style) { FactoryGirl.create(:style, type: "Dress", wholesale_price: wholesale_price, floor_price_sold: 5) }
      let(:item) { FactoryGirl.create(:item, style: style) }

      it "should not sell less than $5.00" do
        expect(item.price_sold).to eq(BigDecimal.new("5"))
      end
    end
  end
end
