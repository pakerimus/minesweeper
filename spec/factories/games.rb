FactoryBot.define do
  factory :game do
    user
    width { 10 }
    height { 10 }
    bombs { 10 }
    state { "pending" }
    total_time { 0 }
    last_started_at { nil }

    trait :with_cells do
      after(:build) do |game|
        game.height.times do |row|
          game.width.times do |column|
            build(:cell, row: row+1, column: column+1)
          end
        end
      end
    end
  end
end
