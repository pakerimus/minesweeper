FactoryBot.define do
  factory :cell do
    game
    row { 1 }
    column { 1 }
    mark { "no_mark" }
    bomb { false }
    cleared { false }
    adjacent_bombs { 1 }
  end
end
