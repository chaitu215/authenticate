require 'spec_helper'
require 'support/controllers/controller_helpers'

describe Authenticate::PasswordsController, type: :controller do
  it { is_expected.to be_a Authenticate::Controller }

  describe 'get to #new' do
    it 'renders the new form' do
      do_get :new

      expect(response).to be_success
      expect(response).to render_template(:new)
    end
  end

  describe 'post to #create' do
    context 'with email for an existing user' do
      it 'generates a password_reset_token' do
        user = create(:user)

        do_post :create, params: { password: { email: user.email.upcase } }

        expect(user.reload.password_reset_token).not_to be_nil
      end

      it 'sends a password reset email' do
        ActionMailer::Base.deliveries.clear
        user = create(:user)

        do_post :create, params: { password: { email: user.email } }

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to match(/change your password/i)
      end
    end
    context 'with email that does not belong to an existing user' do
      bad_email = 'bunk_email_address@non_existent_domain.com'
      it 'does not send an email' do
        ActionMailer::Base.deliveries.clear

        do_post :create, params: { password: { email: bad_email } }

        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it 'always responds with redirect to avoid leaking user information' do
        do_post :create, params: { password: { email: bad_email } }

        expect(response).to be_redirect
      end
    end
  end

  describe 'get to #edit' do
    context 'with a valid password reset token in url' do
      it 'redirects to the edit page with the token removed from the url' do
        user = create(:user, :with_password_reset_token_and_timestamp)

        do_get :edit, params: { id: user.id, token: user.password_reset_token }

        expect(response).to be_redirect
        expect(response).to redirect_to edit_users_password_url(user)
        expect(session[:password_reset_token]).to eq user.password_reset_token
      end
    end

    context 'with a valid password_reset_token in session' do
      it 'renders password update form' do
        user = create(:user, :with_password_reset_token_and_timestamp)
        request.session[:password_reset_token] = user.password_reset_token

        do_get :edit, params: { id: user.id }

        expect(response).to be_success
        expect(response).to render_template(:edit)
      end
    end

    context 'with a valid timestamp but invalid password_reset_token in url' do
      it 'renders #new password form with notice' do
        user = create(:user, :with_password_reset_token_and_timestamp)

        do_get :edit, params: { id: user.id, token: 'bad token' }

        expect(response).to be_success
        expect(response).to render_template(:new)
        expect(flash[:notice]).to match(/double check the URL/)
      end
    end

    context 'with a valid timestamp but invalid password_reset_token in session' do
      it 'renders #new password form with notice' do
        user = create(:user, :with_password_reset_token_and_timestamp)
        request.session[:password_reset_token] = 'bad token'

        do_get :edit, params: { id: user.id }

        expect(response).to be_success
        expect(response).to render_template(:new)
        expect(flash[:notice]).to match(/double check the URL/)
      end
    end

    context 'with a valid password_reset_token in sexxion but expired timestamp' do
      it 'renders #new password form with notice' do
        user = create(:user, :with_password_reset_token_and_timestamp, password_reset_sent_at: 2.years.ago)
        request.session[:password_reset_token] = user.password_reset_token

        do_get :edit, params: { id: user.id }

        expect(response).to be_redirect
        expect(flash[:notice]).to match(/password change request has expired/)
      end
    end

    context 'with a blank password_reset_token' do
      it 'renders #new password form with notice' do
        user = create(:user)

        do_get :edit, params: { id: user.id, token: nil }

        expect(response).to be_success
        expect(response).to render_template(:new)
        expect(flash[:notice]).to match(/double check the URL/)
      end
    end
  end

  describe 'put to #update' do
    context 'with valid password_reset_token and new password' do
      it 'updates the user password' do
        user = create(:user, :with_password_reset_token_and_timestamp)
        old_encrypted_password = user.encrypted_password

        do_put :update, params: update_params(user, new_password: 'new_password')

        expect(user.reload.encrypted_password).not_to eq old_encrypted_password
      end

      it 'signs in the user' do
        user = create(:user, :with_password_reset_token_and_timestamp)

        do_put :update, params: update_params(user, new_password: 'new_password')

        expect(cookies[:authenticate_session_token]).to be_present
        expect(cookies[:authenticate_session_token]).to eq user.reload.session_token
      end

      it 'redirects user' do
        user = create(:user, :with_password_reset_token_and_timestamp)

        do_put :update, params: update_params(user, new_password: 'new_password')

        expect(response).to redirect_to(Authenticate.configuration.redirect_url)
      end
    end

    context 'with invalid new password' do
      it 're-renders password edit form' do
        user = create(:user, :with_password_reset_token_and_timestamp)

        do_put :update, params: update_params(user, new_password: 'short')

        expect(response).to render_template(:edit)
      end
    end
  end

  def update_params(user, options = {})
    new_password = options.fetch(:new_password)
    {
      id: user,
      token: user.password_reset_token,
      password_reset: { password: new_password }
    }
  end
end
