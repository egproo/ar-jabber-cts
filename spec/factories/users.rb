FactoryGirl.define do
  factory :user do
    role User::ROLE_ADMIN
    jid 'sa@localhost'
    password 'secret'
  end
end
