
FactoryGirl.define do
  factory :image do
    section "Test"
    title "A Test"
    artist "Someone"
    created_at Time.now
    updated_at Time.now
  end
end