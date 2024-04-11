class OrdersController < ApplicationController
  def create
    user = User.first # Assuming you have a method to get the current user
    item = find_item(params[:item_id]) # Define a method to find the book/magazine by ID or title

    # Check if the user has reached the maximum transactions
    if user.orders.this_month.count >= 10
      render json: { error: "You have reached the maximum number of transactions for this month" }, status: :unprocessable_entity
      return
    end

    # Check if the item is available based on the user's subscription plan
    if !item_available_for_subscription?(user, item)
      render json: { error: "The requested item is not available for your subscription plan" }, status: :unprocessable_entity
      return
    end

    # Process the order
    if user.orders.create(item: item)
      render json: { success: "Order placed successfully" }, status: :created
    else
      render json: { error: "Failed to place order" }, status: :unprocessable_entity
    end
  end

  private

  def find_item(item_id)
    # Implement this method to find the book/magazine by ID or title
    # Example: Book.find(item_id) or Magazine.find_by(title: item_id)
    Item.last
  end

  def item_available_for_subscription?(user, item)
    # Implement logic to check if the item is available for the user's subscription plan
    # Example: Check the item type (book/magazine) and the user's plan
    case user.subscription_plan
    when "silver"
      return false if item.is_magazine?
      return false if item.genre == "Crime" && user.age < 18
      return true
    when "gold"
      return false if user.orders.this_month.where(item_type: "Magazine").count >= 1
      return false if item.genre == "Crime" && user.age < 18
      return true
    when "platinum"
      return false if user.orders.this_month.where(item_type: "Magazine").count >= 2
      return false if item.genre == "Crime" && user.age < 18
      return true
    else
      return false
    end
  end
end
