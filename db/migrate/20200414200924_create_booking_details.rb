class CreateBookingDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :booking_details do |t|
      t.integer :booked_by_user_id
      t.string :unit_number
      t.string :price
      t.string :name
      t.string :contact
      t.string :payment_receipt
      t.boolean :SPA_signed
      t.boolean :booking_confirmation
      t.boolean :is_active

      t.timestamps
    end
  end
end
