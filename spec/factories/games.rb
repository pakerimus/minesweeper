FactoryBot.define do
  factory :game do
    user
    width { 10 }
    height { 10 }
    bombs { 10 }
    state { "pending" }
    total_time { 0 }
    last_started_at { nil }
  end
end
