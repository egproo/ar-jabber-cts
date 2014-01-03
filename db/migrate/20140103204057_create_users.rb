class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :jid
      t.string :phone
      t.string :password
      t.integer :role

      t.timestamps
    end
  end
end
