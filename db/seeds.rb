# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.delete_all
budget = User.create(
  name: 'budget',
  phone: nil,
  jid: 'admin@dget.cc',
  password: nil,
  role: User::ROLE_STUB,
)
employee = User.create(
  name: 'alxers',
  phone: nil,
  jid: 'alex4rom@gmail.com',
  password: 'secret',
  role: User::ROLE_ADMIN,
)

stub = User.create(
  name: User::STUB,
  phone: nil,
  jid: 'stub@dget.cc',
  password: nil,
  role: User::ROLE_ADMIN,
) if Rails.env.development?

User.create [{
    name: 'dot',
    phone: nil,
    jid: 'dot.doom@gmail.com',
    password: 'secret',
    role: User::ROLE_ADMIN,
  }, {
    name: 'Mody',
    phone: nil,
    jid: 'modymatrix2@gmail.com',
    password: 'secret',
    role: User::ROLE_SUPER_MANAGER,
    locale: 'sy',
  }]

Contract.delete_all
MoneyTransfer.delete_all
Payment.delete_all

salary1 = Contract.new(
  name: 'programmer',
  duration_months: 1,
  type: Contract::TYPE_SALARY,
).tap { |c|
  c.buyer = budget
  c.seller = employee
  c.next_amount_estimate = 400
}

require 'csv'

puts "Parsing CSV"
CSV.foreach(File.join(Rails.root, 'db/seeds.csv')) do |row|
  break if row.first.nil?
  next if row.first.start_with?('room name') # header

  p row

  contract = Contract.new(
    name: row[0],
    duration_months: row[4].to_i,
    type: Contract::TYPE_ROOM,
  )
  contract.buyer = User.find_by_jid(row[1]) ||
                   User.create(
                     name: row[1].split('@', 2).first,
                     jid: row[1],
                     phone: row[3],
                     password: nil,
                     role: User::ROLE_CLIENT,
                     locale: 'sy',
                   )
  contract.seller = User.find_by_name(row[2]) ||
                    User.create(
                      name: row[2] || 'unnamed',
                      jid: 'not_parsed@mail.me',
                      phone: nil,
                      password: 'secret',
                      role: User::ROLE_MANAGER,
                      locale: 'sy',
                    )

  contract.created_at = Time.parse("#{row[6]} 0:00:00 UTC")
  contract.save!

  amount = row[5].sub('$', '').to_i
  transfer = MoneyTransfer.first(
    conditions: { sender_id: contract.buyer.id, receiver_id: contract.seller.id }
  ) || MoneyTransfer.new(amount: 0, received: true)
    
  transfer.amount += amount
  transfer.sender = contract.buyer
  transfer.receiver = contract.seller
  transfer.created_at = contract.created_at if transfer.new_record?
  transfer.save!

  payment = Payment.new(amount: amount)
  payment.money_transfer = transfer
  payment.contract = contract
  payment.created_at = transfer.created_at
  payment.save!
end
puts "\n
  Clients  : #{User.count(conditions: { role: User::ROLE_CLIENT })}
  Managers : #{User.count(conditions: { role: User::ROLE_MANAGER })}
  Contracts: #{Contract.count}
  Transfers: #{MoneyTransfer.count}
  Payments : #{Payment.count}
"
