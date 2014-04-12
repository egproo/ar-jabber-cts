# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Audited::Adapters::ActiveRecord::Audit.delete_all

User.delete_all
u_sa = User.create!(
  role: User::ROLE_ADMIN,
  jid: 'sa@localhost',
  password: 'secret',
)

u_client1 = User.create!(
  role: User::ROLE_CLIENT,
  jid: 'client1@localhost',
)
u_client2 = User.create!(
  role: User::ROLE_CLIENT,
  jid: 'client2@localhost',
)

Room.delete_all
r1 = Room.new(
  name: 'test1@' + Ejabberd::DEFAULT_ROOMS_VHOST,
)
r1.seller = u_sa
r1.buyer = u_client1
r1.save!

MoneyTransfer.delete_all
Payment.delete_all
mt = MoneyTransfer.new(
  sender: u_client1,
  receiver: u_sa,
  received_at: 2.months.ago,
  amount: 15,
)
mt.payments.build(
  contract: r1,
  amount: 15,
  effective_months: 3,
)
mt.save!
r1.reload

mt = MoneyTransfer.new(
  sender: u_client1,
  receiver: u_sa,
  received_at: 1.day.ago,
  amount: 5,
)
mt.payments.build(
  contract: r1,
  amount: 5,
  effective_months: 1,
)
mt.save!
r1.reload
