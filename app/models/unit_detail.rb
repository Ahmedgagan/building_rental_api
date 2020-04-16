class UnitDetail < ApplicationRecord
  validates :unit_block, presence:true
  validates :unit_block_name, presence:true
  validates :unit_number, presence:true
  validates :unit_floor, presence:true
  validates :unit_price, presence:true
  validates :unit_height, presence:true
  validates :unit_width, presence:true
  validates :unit_type, presence:true
  validates :unit_view, presence:true
end
