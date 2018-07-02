require 'rails_helper'

describe UsersController do
  before{ login_as :admin }

  it 'handles /users with GET' do
    gt :users
    expect(response).to be_successful
  end

  it 'handles /users/:id with GET' do
    gt @user
    expect(response).to be_successful
  end

  it 'handles /users with valid params and POST' do
    expect {
      pst :users, user: { name: 'name', password: 'password', email: 'my-email@gmail.com'}
      expect(response).to redirect_to(users_path)
    }.to change(User, :count).by(1)
  end

  it 'encrypts password' do
    # Once when creating the test Admin user (inside login_as)
    # Once when creating the user in the POST request
    expect(AuthenticationService).to receive(:encrypt_password).twice.and_call_original
    pst :users, user: {name: 'name', password: 'password', email: 'my-email@gmail.com'}
    expect(response).to redirect_to(users_path)
  end

  it 'handles /users/:id with valid params and PUT' do
    ptch @user, user: { name: 'new' }
    expect(@user.reload.name).to eq('new')
    expect(response).to redirect_to(user_path(@user))
  end

  it 'handles /users/:id with invalid params and PUT' do
    ptch @user, user: { password: '' }
    expect(@user.reload.name).not_to be_blank
    expect(response).to be_successful
    expect(response).to render_template(:show)
  end

  it 'handles /users/:id with DELETE' do
    expect {
      del @user
      expect(response).to redirect_to(users_path)
    }.to change(User, :count).by(-1)
  end

  describe 'Reset password' do
    it 'handles /users/reset_password with GET' do
      gt '/users/reset_password'
      expect(response).to be_successful
    end

    describe '#change_password' do

      context 'found the user' do
        it 'handles /users/change_password with GET' do
          gt "/users/#{@user.name}/change_password", {token: 'abc'}
          expect(response).to be_successful
        end
      end

      context 'user not found' do
        it 'handles /users/change_password with GET' do
          gt "/users/#{@user.name}/change_password", {token: 'not-found'}
          expect(response).not_to be_successful
        end
      end

    end

    describe '#send_reset_password_email' do
      context 'when there is an email' do
        it 'sends request password email' do
          expect(EmailService).to receive(:send_password_reset_email)
          pst '/users/send_reset_password_email', {email: @user.email}
          expect(response).to render_template 'users/reset_password_email_sent'
        end

        context 'when user is NOT found' do
          it 'fails' do
            expect(User).to receive(:find_by_email) { nil }
            pst '/users/send_reset_password_email', {email: @user.email}
            expect(response).to render_template 'users/user_not_found'
          end
        end
      end

      context 'when there is NOT an email' do
        it 'fails' do
          expect(EmailService).not_to receive(:send_password_reset_email)
          pst '/users/send_reset_password_email'
          expect(response).not_to be_successful
        end
      end
    end

    describe '#update_password' do
      context 'when missing reset password params' do
        it 'fails' do
          ptch '/users/update_password', {some_key: 'some_value'}
          expect(response).not_to be_successful
        end
      end

      context 'when params are provided enough' do
        context 'when a user with such token was not found' do
          it 'returns not_found' do
            ptch '/users/update_password', {reset_password_token: 'BAD TOKEN', password: 'new_password'}
            expect(response).to render_template 'users/user_not_found'
          end
        end

        context 'when a user is found' do
          it 'updates the password' do
            expect(User).to receive(:find_by).with(reset_password_token: 'abc') { @user }
            ptch '/users/update_password', {reset_password_token: 'abc', password: 'new_password'}
            expect(@user.encrypted_password).to eq AuthenticationService.encrypt_password(@user, 'new_password')[1]
            expect(response).to redirect_to :root
          end

          it 'invalidates the reset token' do
            expect(User).to receive(:find_by).with(reset_password_token: 'abc') { @user }
            expect(@user).to receive(:invalidate_reset_token).and_call_original
            ptch '/users/update_password', {reset_password_token: 'abc', password: 'new_password'}
            expect(@user.reset_password_token).to eq nil
          end
        end
      end
    end

  end
end
