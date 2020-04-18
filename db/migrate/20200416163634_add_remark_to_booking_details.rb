class AddRemarkToBookingDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :booking_details, :remark, :string
  end
end
