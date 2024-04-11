class Item < ApplicationRecord
  has_many :orders
  enum item_type: {
    book: 'book',
    magazine: 'magazine'
  }

  validates :title, presence: true
  validates :item_type, presence: true
  validates :genre, presence: true

  def is_magazine?
    item_type == "magazine"
  end

  def is_book?
    item_type == "book"
  end

  def invalid_age_for_genre?(user)
    genre == "crime" && user.age < 18
  end

  def already_borrowed?
    orders.borrowed.present?
  end
end
