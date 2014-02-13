class EncryptUsersPasswords < ActiveRecord::Migration
  def up
    users = User.where('password IS NOT NULL')

    users.each do |u|
      u.update_attribute(:password, User.where(id: u.id).pluck(:password).first)
    end

    remove_column :users, :password
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
