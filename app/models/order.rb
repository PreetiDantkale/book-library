class Order < ApplicationRecord
  belongs_to :item
  belongs_to :user
  scope :this_month, -> {
    where("orders.created_at >= ? AND orders.created_at <= ?", Date.current.beginning_of_month, Date.current.end_of_month)
  }

  scope :borrowed, -> { where(status: STATUSES[:borrowed]) }

  STATUSES = {borrowed: 'borrowed', returned: 'returned'}
end
