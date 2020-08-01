FactoryBot.define do
  factory :user do
    name { Faker::Internet.unique.username }
  end
end
