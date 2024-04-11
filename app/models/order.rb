class Order < ApplicationRecord
  belongs_to :item
  belongs_to :user
  scope :this_month, -> { where("created_at >= ?", Date.current.beginning_of_month) }
  scope :borrowed, -> { where(status: 'borrowed') }
end
