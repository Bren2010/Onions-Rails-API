require 'bcrypt'

class Account < ActiveRecord::Base
  attr_accessible :User, :Pass

  # Authenticate User/Pass
  def self.pass_is_good(pass,username)
    @accounts = Account.where(:User => username)
    @user = @accounts[0]
    hashed_pass = BCrypt::Password.new @user[:Pass]
    hashed_pass == pass
  end

  # Create new Hashed Password from a plaintext input
  def self.new_hashed_pass(pass)
    hashed_pass = BCrypt::Password.create pass
    return hashed_pass.to_s
  end

  # Determine if an acount exists in the Accounts Table
  def self.account_exists(username)
    user = Account.where(:User => username)
    !user.empty?
  end
end
