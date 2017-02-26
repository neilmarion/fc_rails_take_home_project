class ClearanceBatchesController < ApplicationController

  def index
    @clearance_batches  = ClearanceBatch.all
  end

  def show
    @clearance_batch  = ClearanceBatch.find(params[:id])
    @items = Item.where(clearance_batch_id: params[:id])
    generate_report
  end

  def create
    clearancing_status = ClearancingService.new.process_file(params[:csv_batch_file].tempfile)
    clearance_batch    = clearancing_status.clearance_batch
    alert_messages     = []
    if clearance_batch.persisted?
      flash[:notice]  = "#{clearance_batch.items.count} items clearanced in batch #{clearance_batch.id}"
    else
      alert_messages << "No new clearance batch was added"
    end
    if clearancing_status.errors.any?
      alert_messages << "#{clearancing_status.errors.count} item ids raised errors and were not clearanced"
      clearancing_status.errors.each {|error| alert_messages << error }
    end
    flash[:alert] = alert_messages.join("<br/>") if alert_messages.any?
    redirect_to action: :index
  end

  private

  def generate_report
    items_hashes = @items.map do |item|
      {style: item.style.type, size: item.size, color: item.color}
    end

    report = []

    items_hashes.each do |items_hash|
      specific_count = {
        description: "#{items_hash[:size]} #{items_hash[:color]} #{items_hash[:style]}", count: 0
      }

      items_hashes.each do |i|
        if items_hash == i
          specific_count[:count] = specific_count[:count] + 1
        end
      end

      report << specific_count
    end

    @report_texts = []
    report.uniq.each do |row|
      @report_texts << "#{row[:count]} pcs of #{row[:description]}"
    end

    @total_price = compute_total_price
  end

  def compute_total_price
    @items.sum(:price_sold).to_f
  end

end
