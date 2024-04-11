# spec/models/item_spec.rb
require 'rails_helper'

RSpec.describe Item, type: :model do

  describe '#is_magazine?' do
    it 'returns true for a magazine item' do
      magazine = create(:item, item_type: 'magazine')
      expect(magazine.is_magazine?).to eq(true)
    end

    it 'returns false for a book item' do
      book = create(:item, item_type: 'book')
      expect(book.is_magazine?).to eq(false)
    end
  end

  describe '#is_book?' do
    it 'returns true for a book item' do
      book = create(:item, item_type: 'book')
      expect(book.is_book?).to eq(true)
    end

    it 'returns false for a magazine item' do
      magazine = create(:item, item_type: 'magazine')
      expect(magazine.is_book?).to eq(false)
    end
  end

  describe '#invalid_age_for_genre?' do
    let(:user_underage) { create(:user, age: 16) }
    let(:user_adult) { create(:user, age: 20) }

    it 'returns true if the genre is crime and user is underage' do
      item = create(:item, genre: 'crime')
      expect(item.invalid_age_for_genre?(user_underage)).to eq(true)
    end

    it 'returns false if the genre is not crime' do
      item = create(:item, genre: 'comedy')
      expect(item.invalid_age_for_genre?(user_underage)).to eq(false)
    end

    it 'returns false if the genre is crime and user is adult' do
      item = create(:item, genre: 'crime')
      expect(item.invalid_age_for_genre?(user_adult)).to eq(false)
    end
  end

  describe '#already_borrowed?' do
    let(:item) { create(:item) }

    it 'returns false when no orders are borrowed' do
      expect(item.already_borrowed?).to eq(false)
    end

    it 'returns true when orders are borrowed' do
      create(:order, item: item, status: 'borrowed')
      expect(item.already_borrowed?).to eq(true)
    end
  end
end
