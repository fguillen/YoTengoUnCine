FactoryGirl.define do
  factory :admin_user do
    sequence(:name) { |n| "AdminUser Name #{n}" }
    sequence(:email) { |n| "email#{n}@email.com" }
    password "pass"
    password_confirmation "pass"
  end

  factory :item do
    sequence(:title) { |n| "Item Title #{n}" }
    text "The text"
  end

  factory :pic do
    association :item
    attach { File.new("#{Rails.root}/test/fixtures/pic.jpg") }
  end

  factory :log_book_event, :class => LogBook::Event  do
    text "Wadus Event"
  end

  factory :donation do
    amount 10
    kind Donation::KINDS[:donation_5]
    description "wadus description"
  end
end