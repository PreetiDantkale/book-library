class User < ApplicationRecord
	has_many :orders

	def item_available_for_subscription?(item)
		magazines_borrowed = orders.this_month.where(item: Item.where(item_type: "magazine")).count
		books_borrowed = orders.this_month.where(item: Item.where(item_type: "book")).count
		case subscription_plan
		when "silver"
			return !(item.is_magazine? || books_borrowed >= 2)
		when "gold"
			return !(item.is_magazine? && magazines_borrowed >= 1 || books_borrowed >= 3)
		when "platinum"
			return !(item.is_magazine? && magazines_borrowed >= 2 || books_borrowed >= 4)
		else
			return false
		end
	end
end
