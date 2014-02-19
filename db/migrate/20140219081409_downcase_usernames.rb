class DowncaseUsernames < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update_attributes(name: user.name.downcase) unless /[[:lower:]]/.match(user.name)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
