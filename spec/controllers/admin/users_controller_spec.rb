# frozen_string_literal: true

describe Admin::UsersController, :type => :controller do
  before do
    @user = FactoryGirl.create :user
    Role.add_admin(@user.person)

    sign_in @user, scope: :user
  end

  describe '#close_account' do
    it 'queues a job to disable the given account' do
      other_user = FactoryGirl.create :user
      expect(other_user).to receive(:close_account!)
      allow(User).to receive(:find).and_return(other_user)

      post :close_account, params: {id: other_user.id}
    end
  end

  describe '#lock_account' do
    it 'it locks the given account' do
      other_user = FactoryGirl.create :user
      other_user.lock_access!
      expect(other_user.reload.access_locked?).to be_truthy
    end
  end

  describe '#unlock_account' do
    it 'it unlocks the given account' do
      other_user = FactoryGirl.create :user
      other_user.lock_access!
      other_user.unlock_access!
      expect(other_user.reload.access_locked?).to be_falsey
    end
  end

  describe '#update' do
    let(:user_to_update) { FactoryGirl.create :user }

    context 'success' do
      it 'updates the user email' do
        new_email = 'bob_new_email@pivotallabs.com'

        put :update, params: {id: user_to_update.id, email: new_email}

        expect(user_to_update.reload.email).to eq new_email
      end

      it 'redirects to the user search' do
        new_email = 'bob_new_email@pivotallabs.com'

        put :update, params: {id: user_to_update.id, email: new_email}

        expect(response).to redirect_to user_search_path
      end

      it 'confirms email update' do
        new_email = 'bob_new_email@pivotallabs.com'

        put :update, params: {id: user_to_update.id, email: new_email}

        expect(flash.notice).to include("email updated")
      end
    end

    context 'failure' do
      it 'does not nullify the email' do
        empty_email = ''

        put :update, params: {id: user_to_update.id, email: empty_email}

        expect(user_to_update.reload.email).to_not eq empty_email
      end

      it 'redirects to the user search' do
        new_email = ''

        put :update, params: {id: user_to_update.id, email: new_email}

        expect(response).to redirect_to user_search_path
      end

      it 'communicate the error' do
        empty_email = ''

        put :update, params: {id: user_to_update.id, email: empty_email}

        expect(flash.notice).to include("cannot update user email")
      end
    end
  end
end
