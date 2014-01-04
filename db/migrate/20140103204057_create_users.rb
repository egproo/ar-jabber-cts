class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :jid, null: false
      t.string :phone, null: true
      t.string :password, null: true
      t.integer :role, null: false
      t.string :locale, null: false, default: 'en'

      t.timestamps
    end
  end
end
