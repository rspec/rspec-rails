FactoryBot.define do
  factory :user do
    email_address { "john@example.com" }
    password_digest { "MyString" }
  end
end