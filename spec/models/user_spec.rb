require 'rails_helper'

describe User, 'authentication' do
  let!(:admin) { create(:user, :admin) }

  it 'should authenticate a valid user' do
    expect(User.authenticate('admin', 'password')).to eq admin
  end

  it 'should not authenticate valid user with wrong password' do
    expect(User.authenticate('admin', 'wrong')).to be_nil
  end

  it 'should not authenticate valid user with nil password' do
    expect(User.authenticate('admin', nil)).to be_nil
  end

  it 'should not authenticate with invalid user name' do
    expect(User.authenticate('invalid', 'anything')).to be_nil
  end

  it 'should not authenticate with nil user name' do
    expect(User.authenticate(nil, nil)).to be_nil
  end
end

describe User, 'validations' do
  let!(:admin) { create(:user, :admin) }

  it 'should have a name' do
    user = User.new
    user.valid?
    expect(user.errors[:name]).not_to be_empty
  end

  it 'should have a name with valid characters' do
    user = User.new name: 'INVALID'
    user.valid?
    expect(user.errors[:name]).not_to be_empty
  end

  it 'should have a password' do
    user = User.new
    user.valid?
    expect(user.errors[:password]).not_to be_empty
  end

  it 'should have a unique name' do
    user = User.new name: admin.name
    user.valid?
    expect(user.errors[:name]).not_to be_empty
  end
end
