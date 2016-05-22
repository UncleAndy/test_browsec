FactoryGirl.define do
  factory :row do
    sequence(:name) { |n| "Name #{n}" }
  end
end
