FactoryBot.define do
	factory :item do
		title { "Book Title" }
		genre { "fiction" }
		item_type { "book" }

		trait :magazine do
			item_type { "magazine" }
		end
	end
end
  