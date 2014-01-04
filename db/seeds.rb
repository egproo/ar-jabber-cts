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
  }]

Contract.delete_all
MoneyTransfer.delete_all
Payment.delete_all
  
require 'csv'

print "Parsing CSV"
CSV.foreach(File.join(Rails.root, 'db/seeds.csv')) do |row|
  break if row.first.nil?
  next if row.first.start_with?('room name') # header

  contract = Contract.new(
    name: row[0],
    duration_months: row[5].to_i,
  )
  contract.buyer = User.find_by_jid(row[1]) ||
                   User.create(
                     name: row[1].split('@', 2).first,
                     jid: row[1],
                     phone: row[3],
                     password: nil,
                     role: User::ROLE_CLIENT,
                   )
  contract.seller = User.find_by_name(row[2]) ||
                    User.create(
                      name: row[2],
                      jid: 'not_parsed@mail.me',
                      phone: nil,
                      password: 'secret',
                      role: User::ROLE_MANAGER,
                    )
  contract.save!

  amount = row[6].sub('$', '').to_i
  transfer = MoneyTransfer.first(
    conditions: { sender_id: contract.buyer.id, receiver_id: contract.seller.id }
  ) || MoneyTransfer.new(amount: 0)
    
  transfer.amount += amount
  transfer.sender = contract.buyer
  transfer.receiver = contract.seller
  transfer.created_at ||= Date.parse(row[7])
  transfer.save!

  payment = Payment.new(amount: amount)
  payment.money_transfer = transfer
  payment.contract = contract
  payment.save!

  print '.'
end
puts "\n
  Clients  : #{User.count(conditions: { role: User::ROLE_CLIENT })}
  Managers : #{User.count(conditions: { role: User::ROLE_MANAGER })}
  Contracts: #{Contract.count}
  Transfers: #{MoneyTransfer.count}
  Payments : #{Payment.count}
"
