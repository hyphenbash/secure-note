FactoryBot.define do
  factory :note do
    title 'Test Note Title'
    password 'This is a salt password'
    body_text_key 'body_text_key'
    body_text_iv 'body_text_iv'
  end
end