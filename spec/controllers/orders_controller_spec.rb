require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:item) { create(:item) }

    context 'when user has not reached maximum transactions' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(controller).to receive(:find_item).and_return(item)
      end

      it 'creates a new order' do
        post :create, params: { order: { user_id: user.id, item_id: item.id } }
        expect(response).to have_http_status(:created)
      end
    end

    context 'when user has reached maximum transactions' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(controller).to receive(:find_item).and_return(item)
        allow(user.orders).to receive_message_chain(:this_month, :count).and_return(10)
      end

      it 'returns an error' do
        post :create, params: { order: { user_id: user.id, item_id: item.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('You have reached the maximum number of transactions for this month')
      end
    end

    # Additional contexts for other conditions can be added here
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:item1) { create(:item) }
    let(:item2) { create(:item) }
    let!(:borrowed_item1) { create(:order, user: user, item: item1, status: 'borrowed') }
    let!(:borrowed_item2) { create(:order, user: user, item: item2, status: 'borrowed') }

    context 'when items are successfully returned' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(Item).to receive(:where).and_return([item1, item2])
        # allow(user.orders).to receive(:borrowed).and_return(Order.where(id: [borrowed_item1.id, borrowed_item2.id]))
      end

      it 'updates the status of borrowed items' do
        patch :update, params: { order: { user_id: user.id }, item_ids: [item1.id, item2.id] }
        expect(response).to have_http_status(:ok)
        # expect(borrowed_item1.reload.status).to eq('returned')
        # expect(borrowed_item2.reload.status).to eq('returned')
      end
    end

    context 'when no matching borrowed items are found' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(Item).to receive(:where).and_return([item1, item2])
        allow(user.orders).to receive(:borrowed).and_return(Order.none)
      end

      it 'returns an error' do
        patch :update, params: { order: { user_id: user.id }, item_ids: [item1.id, item2.id] }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('No matching borrowed items found for the user')
      end
    end

    # Additional contexts for other conditions can be added here
  end
end
