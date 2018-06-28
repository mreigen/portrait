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
      pst :users, user: { name: 'name', password: 'password' }
      expect(response).to redirect_to(users_path)
    }.to change(User, :count).by(1)
  end

  it 'encrypts password' do
    # Once when creating the test Admin user (inside login_as)
    # Once when creating the user in the POST request
    expect(AuthenticationService).to receive(:encrypt_password).twice.and_call_original
    pst :users, user: {name: 'name', password: 'password'}
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

end
