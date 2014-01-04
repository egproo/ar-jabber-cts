# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
User.create [{
    name: 'dot',
    phone: nil,
    jid: 'dot.doom@gmail.com',
    password: 'secret',
    role: User::ROLE_ADMIN,
  }, {
    name: 'alxers',
    phone: nil,
    jid: 'alex4rom@gmail.com',
    password: 'secret',
    role: User::ROLE_ADMIN,
  }, {
    name: 'Mody',
    phone: nil,
    jid: 'modymatrix2@gmail.com',
    password: 'secret',
    role: User::ROLE_SUPER_MANAGER,
  }, {
    name: 'damascus',
    phone: nil,
    jid: 'owner@syriatalk.biz',
    password: 'secret',
    role: User::ROLE_MANAGER,
  }, {
    name: 'alastoraa',
    phone: '+123457890',
    jid: 'a.l.a.s.t.o.r.a.a@syriatalk.biz',
    password: nil, # no login
    role: User::ROLE_CLIENT,
  }]

customer = User.find_by_name('alastoraa')
manager = User.find_by_name('damascus')

Contract.delete_all
contract_3m_1 = Contract.new(
  name: 'بانياس@conference.syriatalk.biz',
  duration_months: 3,
  next_amount_estimate: 15,
).tap { |c|
  c.buyer = customer
  c.seller = manager
  c.save!
}
contract_3m_2 = Contract.new(
  name: 'حريصون@conference.syriatalk.biz',
  duration_months: 3,
  next_amount_estimate: 15,
).tap { |c|
  c.buyer = customer
  c.seller = manager
  c.save!
}
contract_1m = Contract.new(
  name: 'شلة.الساحل@conference.syriatalk.biz',
  duration_months: 1,
  next_amount_estimate: 15,
).tap { |c|
  c.buyer = customer
  c.seller = manager
  c.created_at = 2.months.ago # outdated
  c.save!
}

MoneyTransfer.delete_all
MoneyTransfer.new(
  amount: 30,
).tap { |mt|
  mt.sender = customer
  mt.receiver = manager
  mt.save!
}

Payment.delete_all
Payment.new(
  amount: 15,
).tap { |p|
  p.money_transfer = MoneyTransfer.first
  p.contract = contract_3m_1
  p.save!
}
Payment.new(
  amount: 15,
).tap { |p|
  p.money_transfer = MoneyTransfer.first
  p.contract = contract_3m_2
  p.save!
}
