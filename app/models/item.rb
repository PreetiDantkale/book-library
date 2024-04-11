class Item < ApplicationRecord
  has_many :orders

  # Enum for item_type (book or magazine)
  enum item_type: {
    book: 'book',
    magazine: 'magazine'
  }

  # Validation
  validates :title, presence: true
  validates :item_type, presence: true
  validates :genre, presence: true

  def is_magazine?
    item_type == "magazine"
  end
end
