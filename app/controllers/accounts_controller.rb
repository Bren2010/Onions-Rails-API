require 'bcrypt'

class AccountsController < ApplicationController
	respond_to :json, :html

	def index
		if session[:SessionKey]
			session[:SessionKey] = nil
		end
		if session[:UserKey]
			session[:UserKey] = nil
		end
	end

	def show
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end

	def create
		if params[:account]
			login = params[:account]
			if login[:User] && login[:Pass]
				# Params are GOOD
				if (Account.account_exists(login[:User]))
					# Account exists for that Email
					if (Account.pass_is_good(login[:Pass],login[:User]))
						@users = Account.where(:User => login[:User])
						@user = @users[0]
						sKey = Session.new_session(login[:User])
						session[:SessionKey] = sKey
						respond_with({:SessionKey => sKey}.as_json, :location => "/onions")
					else
						# User&Pass Mismatch
						respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
					end
				else
					# User&Pass Mismatch
					respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
				end
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
		end
	end

	def delete_account
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	# Login 
	def login
		if params[:User] && params[:Pass]
			# Params are GOOD
			if (Account.account_exists(params[:User]))
				# Account exists for that Email
				if (Account.pass_is_good(params[:Pass],params[:User]))
					sKey = Session.new_session(params[:User])
					respond_with({:SessionKey => sKey}.as_json, :location => nil)
				else
					respond_with({:error => "Email/Password Mismatch"}.as_json, :location => nil)
				end
			else
				respond_with({:error => "Email/Password Mismatch"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
		end
	end


	# NEW ACCOUNT API
	def new_account
		if (params[:User] && params[:Pass])
			# No Account exists, make one
			if Account.account_exists(params[:User])
				respond_with({:error => "Account already exists"}.as_json, :location => "/")
			else
				hashedPass = Account.new_hashed_pass(params[:Pass])
				sKey = Session.new_session(params[:User])
				@account = Account.create(:User => encrypted_user, :Pass => hashedPass)
				respond_with({:SessionKey => sKey, :Salt => salt}.as_json, :location => "/")
			end
		else
			# Params are BAD
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
		end
	end


	# NEW ACCOUNT WEB
	def newAccountWeb
		if params[:register]
			register = params[:register]
			if register[:User] && register[:Pass] && register[:BetaCode]
				if BetaKey.beta_key_is_active(register[:BetaCode])
          if Account.account_exists(register[:User])
            respond_with({:error => "Account already exists"}.as_json, :location => "/new?AccountExists=true")
          else
            pass = Account.new_hashed_pass(register[:Pass])
            @account = Account.create(:User => register[:User], :Pass => pass)
            session[:SessionKey] = Session.new_session(register[:User])
            BetaKey.use_beta_key(register[:BetaCode])
            respond_with({:NewAccount => "Success"}.as_json, :location => "/onions")
          end
        else
          respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new?BadBetaCode=true")
        end
			else
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new?BadParams=true")
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new")
		end
	end


	# LOGOUT
	def logout
		session[:SessionKey] = nil
		redirect_to("/")
  end

  def about
     #
  end


  # DELETE ACCOUNT
  def deleteAccountWeb
    #
  end

  def deleteAccountFinal
    if params[:account]
      login = params[:account]
      if login[:User] && login[:Pass]
        # Params are Good
        if (Account.account_exists(login[:User]))
          # Account exists for that Username
          if (Account.pass_is_good(login[:Pass],login[:User]))
            Account.where(:User => login[:User]).destroy_all
            Onion.where(:User => login[:User]).destroy_all
            Session.where(:User => login[:User]).destroy_all
            redirect_to('/?Deleted=true')
          else
            # User&Pass Mismatch
            respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
          end
        else
          # User&Pass Mismatch
          respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
        end
      end
    else
      respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
    end
  end


  def donate
    @total_accounts = Account.count
    @total_onions = Onion.count
  end


end
