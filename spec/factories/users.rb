FactoryBot.define do
	factory :user do
		name { "John Doe" }
		age { 25 }
		subscription_plan { "silver" }
	end
end
  