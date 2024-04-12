class User < ApplicationRecord
	has_many :orders

	def item_available_for_subscription?(item)
		orders_this_month = orders.this_month.joins(:item)
		magazines_borrowed = orders_this_month.where('items.item_type = ?', Item::MAGAZINE).count
		books_borrowed = orders_this_month.where('items.item_type = ?', Item::BOOK).count

		case subscription_plan
		when 'silver'
			return !(item.is_magazine? || books_borrowed >= 2)
		when 'gold'
			return !(item.is_magazine? && magazines_borrowed >= 1 || books_borrowed >= 3)
		when 'platinum'
			return !(item.is_magazine? && magazines_borrowed >= 2 || books_borrowed >= 4)
		else
			return false
		end
	end
end
