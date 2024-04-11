FactoryBot.define do
	factory :order do
		association :user
		association :item
		status { "borrowed" }
	end
end
  