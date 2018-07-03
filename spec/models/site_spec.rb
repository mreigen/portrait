require 'rails_helper'

describe Site do
  let!(:admin) { create(:user, :admin) }
  let!(:google) { create(:site, user: admin) }

  it 'should belong to a user' do
    expect(google.user).to eq admin
  end

  it 'should require a url' do
    site = Site.new
    site.valid?
    expect(site.errors[:url]).not_to be_empty
  end

  it 'should require a valid url' do
    site = Site.new url: 'invalid'
    site.valid?
    expect(site.errors[:url]).not_to be_empty
  end

  it 'should require a user' do
    site = Site.new
    site.valid?
    expect(site.errors[:user]).not_to be_empty
  end
end
