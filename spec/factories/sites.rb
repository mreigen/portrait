FactoryBot.define do
  factory :site do
    user
    status Site.statuses[:succeeded]
    url 'http://google.com'
    callback_url 'http://callmeback.com/later'
  end
end