class OrdersController < ApplicationController
  def create
    user = User.find(params["order"]["user_id"])
    item = find_item(params["order"]["item_id"])
    # Check if the user has reached the maximum transactions
    if user.orders.this_month.count >= 10
      render json: { error: "You have reached the maximum number of transactions for this month" }, status: :unprocessable_entity
      return
    end

    if item.orders.borrowed.present?
      render json: { error: "Already borrowed" }, status: :unprocessable_entity
      return
    end
  
    if user.age < 18 && item.genre == "crime"
      render json: { error: "Age not valid" }, status: :unprocessable_entity
      return
    end
  
    if !item_available_for_subscription?(user, item)
      render json: { error: "The requested item is not available for your subscription plan" }, status: :unprocessable_entity
      return
    end

    if user.orders.create(item: item, status: 'borrowed')
      render json: { success: "Order placed successfully" }, status: :created
    else
      render json: { error: "Failed to place order" }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params["order"]["user_id"])
    titles = params[:item_ids]
    items = Item.where(id: titles)
    borrowed_items = user.orders.borrowed.where(item: items)
    if borrowed_items.empty?
      render json: { error: "No matching borrowed items found for the user" }, status: :unprocessable_entity
      return
    end
    borrowed_items.each do |borrowed_item|
      borrowed_item.update(status: 'returned')
    end
    render json: { success: "Items returned successfully" }, status: :ok
  end

  private

  def find_item(item_id)
    Item.find(item_id)
  end

  def item_available_for_subscription?(user, item)
    magazines_borrowed = user.orders.this_month.where(item: Item.where(item_type: "magazine")).count
    case user.subscription_plan
    when "silver"
      return false if item.is_magazine?
      return false if user.orders.this_month.where(item: Item.where(item_type: "book")).count >= 2
      return true
    when "gold"
      return false if item.is_magazine? && magazines_borrowed >= 1
      return false if user.orders.this_month.where(item: Item.where(item_type: "book")).count >= 3
      return true
    when "platinum"
      return false if item.is_magazine? && magazines_borrowed >= 2
      return false if user.orders.this_month.where(item: Item.where(item_type: "book")).count >= 4
      return true
    else
      return false
    end
  end
end
