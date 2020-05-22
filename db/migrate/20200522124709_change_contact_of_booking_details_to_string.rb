class ChangeContactOfBookingDetailsToString < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :contact, :text
    change_column :booking_details, :contact, :text
  end
end
