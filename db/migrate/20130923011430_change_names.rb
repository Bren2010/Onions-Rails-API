class ChangeNames < ActiveRecord::Migration
  def change
    rename_column :accounts, :HashedUser, :User
    rename_column :accounts, :HashedPass, :Pass
    # Should also delete column Salt, but it's not reversible so it's ignored.
    
    rename_column :onions, :HashedUser, :User
    rename_column :onions, :HashedTitle, :Title
    rename_column :onions, :HashedInfo, :Info
    
    rename_column :sessions, :HashedUser, :User
  end
end
