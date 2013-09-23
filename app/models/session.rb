require 'securerandom'

class Session < ActiveRecord::Base
  attr_accessible :User, :Key

  def self.new_session(username)
  	session_key = SecureRandom.uuid
  	Session.where(:User => username).destroy_all
  	s = Session.create(:User => username, :Key => session_key.to_s)
    if s.id > 2000000000
      Session.reset_sessions
    end
  	return session_key.to_s
  end

  def self.username_for_session(session_key)
  	@sessions = Session.where(:Key => session_key)
  	@session = @sessions[0]
    if @session
      if @session.created_at + 1.hours > Time.now
         return @session.User
      else
         @sessions.destroy_all
         return nil
      end
    end

    return nil
  end

  def self.reset_sessions
    # Reset Sessions table if Primary Key goes over 2 billion
    s = Session.find_by_sql('ALTER SEQUENCE sessions_id_seq RESTART WITH 1')
  end

end
