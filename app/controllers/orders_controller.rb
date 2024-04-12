class OrdersController < ApplicationController
  def create
    user = User.find(params['order']['user_id'])
    item = find_item(params['order']['item_id'])
    if max_transactions_reached?(user)
      render_error('You have reached the maximum number of transactions for this month')
    elsif item.already_borrowed?
      render_error('This book has already been borrowed')
    elsif item.invalid_age_for_genre?(user)
      render_error('Age constraint!')
    elsif !user.item_available_for_subscription?(item)
      render_error('The requested item is not available for your subscription plan')
    else
      if user.orders.create(item: item, status: 'borrowed')
        render json: { success: 'Order placed successfully' }, status: :created
      else
        render_error('Failed to place order')
      end
    end
  end

  def update
    user = User.find(params['order']['user_id'])
    item_ids = params[:item_ids]
    items = Item.where(id: item_ids)
    borrowed_items = user.orders.borrowed.where(item: items)
    if borrowed_items.empty?
      render json: { error: 'No matching borrowed items found for the user' }, status: :unprocessable_entity
      return
    end
    borrowed_items.each do |borrowed_item|
      borrowed_item.update(status: Order::STATUSES[:returned])
    end
    render json: { success: 'Items returned successfully' }, status: :ok
  end

  private

  def max_transactions_reached?(user)
    user.orders.this_month.count >= 10
  end
  
  def render_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end

  def find_item(item_id)
    Item.find(item_id)
  end
end
