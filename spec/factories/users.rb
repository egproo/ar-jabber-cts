FactoryGirl.define do
  factory :admin, class: User do
    role User::ROLE_ADMIN
    jid 'sa@localhost'
    password 'secret'
  end

  factory :user do
    role User::ROLE_CLIENT
    sequence(:jid) { |n| "client#{n}@localhost" }
    password 'secret'
  end

end
