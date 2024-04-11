require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:item) { create(:item) }

    context 'when all conditions are met' do
      let(:user_valid) { create(:user) }
      let(:valid_item) { create(:item) }

      before do
        allow(User).to receive(:find).and_return(user_valid)
        allow(controller).to receive(:find_item).and_return(valid_item)
        allow(user_valid.orders).to receive(:create).and_return(true)
      end

      it 'creates a new order successfully' do
        post :create, params: { order: { user_id: user_valid.id, item_id: valid_item.id } }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['success']).to eq('Order placed successfully')
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

    context 'when item is already borrowed' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(controller).to receive(:find_item).and_return(item)
        allow(item.orders).to receive(:borrowed).and_return(Order.where(id: create(:order, user: user, item: item, status: 'borrowed').id))
      end

      it 'returns an error for item already borrowed' do
        post :create, params: { order: { user_id: user.id, item_id: item.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Already borrowed')
      end
    end

    context 'when user age is less than 18 and item genre is "crime"' do
      let(:user_underage) { create(:user, age: 16) }
      let(:crime_item) { create(:item, genre: 'crime') }

      it 'returns an error for invalid age' do
        post :create, params: { order: { user_id: user_underage.id, item_id: crime_item.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Age not valid')
      end
    end

    context 'when item is not available for user subscription plan' do
      let(:silver_user) { create(:user, subscription_plan: 'silver') }
      let(:magazine_item) { create(:item, item_type: 'magazine') }

      before do
        allow(User).to receive(:find).and_return(silver_user)
        allow(controller).to receive(:find_item).and_return(magazine_item)
      end

      it 'returns an error for item not available for subscription plan' do
        post :create, params: { order: { user_id: silver_user.id, item_id: magazine_item.id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('The requested item is not available for your subscription plan')
      end
    end

    describe 'item_available_for_subscription?' do
      let(:user) { create(:user, subscription_plan: 'silver') }
      let(:item) { create(:item) }
  
      context 'when user has silver subscription' do
        it 'returns true for non-magazine item and under transaction limit' do
          allow(user.orders).to receive_message_chain(:this_month, :where, :count).and_return(1)
          allow(Item).to receive(:where).and_return([item])
          expect(user.item_available_for_subscription?(item)).to eq(true)
        end
  
        it 'returns false for magazine item' do
          magazine_item = create(:item, item_type: 'magazine')
          expect(user.item_available_for_subscription?(magazine_item)).to eq(false)
        end
  
        it 'returns false for reaching transaction limit' do
          allow(user.orders).to receive_message_chain(:this_month, :where, :count).and_return(2)
          allow(Item).to receive(:where).and_return([item])
          expect(user.item_available_for_subscription?(item)).to eq(false)
        end
      end
  
      context 'when user has gold subscription' do
        let(:gold_user) { create(:user, subscription_plan: 'gold') }
  
        it 'returns true for non-magazine item, under transaction limit, and magazines borrowed limit' do
          allow(gold_user.orders).to receive_message_chain(:this_month, :where, :count).and_return(2)
          allow(Item).to receive(:where).and_return([item])
          expect(user.item_available_for_subscription?(item)).to eq(true)
        end
  
        it 'returns false for magazine item and reaching transaction limit' do
          magazine_item = create(:item, item_type: 'magazine')
          allow(gold_user.orders).to receive_message_chain(:this_month, :where, :count).and_return(2)
          expect(user.item_available_for_subscription?(magazine_item)).to eq(false)
        end
      end
  
      context 'when user has platinum subscription' do
        let(:platinum_user) { create(:user, subscription_plan: 'platinum') }
  
        it 'returns true for non-magazine item, under transaction limit, and magazines borrowed limit' do
          allow(platinum_user.orders).to receive_message_chain(:this_month, :where, :count).and_return(3)
          allow(Item).to receive(:where).and_return([item])
          expect(user.item_available_for_subscription?(item)).to eq(true)
        end
  
        it 'returns false for magazine item and reaching transaction limit' do
          magazine_item = create(:item, item_type: 'magazine')
          allow(platinum_user.orders).to receive_message_chain(:this_month, :where, :count).and_return(3)
          expect(user.item_available_for_subscription?(magazine_item)).to eq(false)
        end
      end
    end
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
      end

      it 'updates the status of borrowed items' do
        patch :update, params: { order: { user_id: user.id }, item_ids: [item1.id, item2.id] }
        expect(response).to have_http_status(:ok)
        expect(borrowed_item1.reload.status).to eq('returned')
        expect(borrowed_item2.reload.status).to eq('returned')
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
  end
end
