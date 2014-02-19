class DowncaseUsernames < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update_attributes(name: user.name.downcase) unless user.name == user.name.downcase
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
