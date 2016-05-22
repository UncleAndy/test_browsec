FactoryGirl.define do
  factory :phone do
    sequence(:number) { |n| "+7000000000#{n}" }
  end
end
