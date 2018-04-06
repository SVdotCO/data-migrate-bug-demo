class SetNameForUsers < ActiveRecord::Migration[5.1]
  def up
    User.all.each do |user|
      user.update!(name: "#{user.first_name} #{user.last_name}")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
