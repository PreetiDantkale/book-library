class Item < ApplicationRecord
  has_many :orders
  CRIME_GENRE = 'crime'.freeze
  BOOK = 'book'.freeze
  MAGAZINE = 'magazine'.freeze

  enum item_type: {
    book: 'book',
    magazine: 'magazine'
  }

  validates :title, presence: true
  validates :item_type, presence: true
  validates :genre, presence: true

  def is_magazine?
    item_type == MAGAZINE
  end

  def is_book?
    item_type == BOOK
  end

  def invalid_age_for_genre?(user)
    genre == CRIME_GENRE && user.age < 18
  end

  def already_borrowed?
    orders.borrowed.present?
  end
end
