class OnionsController < ApplicationController
	require 'base64'
	respond_to :json, :html

	def index
		@onions = nil
		if session[:SessionKey]
			username = Session.username_for_session(session[:SessionKey])
			if username
				@onions = Onion.where(:User => username).order("id")
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
			else
				redirect_to("/")
			end
		else
			redirect_to("/")
		end
  end


	def show
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	def create
		if params[:onion] && session[:SessionKey]
			onion = params[:onion]
			@username = Session.username_for_session(session[:SessionKey])
			if @username
				if params[:Id]
					# Edit Onion
					@edit_onion = Onion.find(params[:Id])
          if @edit_onion.User == @username
            @edit_onion.Title = onion[:Title]
            @edit_onion.Info = onion[:Info]
            @edit_onion.save
          end
        else
          # New Onion
					@new_onion = Onion.create(:User => @username, :Title => onion[:Title], :Info => onion[:Info])
				end
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/onions")
				session[:SessionKey] = Session.new_session(@username)
			else
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
		end
	end


	def delete
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	def getAllOnions
		if params[:SessionKey]
			@username = Session.username_for_session(params[:SessionKey])
			if @username
				@onions = Onion.where(:User => @username)
				respond_with({:Onions => @onions, :SessionKey => Session.new_session(@username)}.as_json, :location => nil)
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def addOnion
		if params[:SessionKey]
			@username = Session.username_for_session(params[:SessionKey])
			if @username
				@onion = Onion.create(:User => @username, :Title => params[:Title], :Info => params[:Info])
				respond_with({:NewOnion => @onion, :SessionKey => Session.new_session(@username)}.as_json, :location => nil)
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def editOnion
		if params[:SessionKey]
			@username = Session.username_for_session(params[:SessionKey])
			if @username
				@onion = Onion.find(params[:Id])
        if @onion.User == @username
          @onion.Title = params[:Title]
          @onion.Info = params[:Info]
          if @onion.save
            respond_with({:Status => "Success", :SessionKey => Session.new_session(@username)}.as_json, :location => nil)
          else
            respond_with({:error => "Onion failed to Save."}.as_json, :location => nil)
          end
        else
          respond_with({:error => "No User for Session"}.as_json, :location => nil)
        end
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def delete_onion
		if params[:SessionKey]
			@username = Session.username_for_session(params[:SessionKey])
			if @username
				@onion = Onion.find(params[:Id])
        if @onion.User == @username
          @onion.destroy
          respond_with({:Status => "Success", :SessionKey => Session.new_session(@username)}.as_json, :location => nil)
        else
          respond_with({:error => "No User for Session"}.as_json, :location => nil)
        end
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def deleteOnionWeb
		if session[:SessionKey]
			username = Session.username_for_session(session[:SessionKey])
			if username && params[:OnionId]
				@onion = Onion.find(params[:OnionId])
				if @onion.User == username
					@onion.destroy
					session[:SessionKey] = Session.new_session(username)
					redirect_to("/onions")
				else
					# No Permission
				end
			else
        # No Permission
			end
		else
      # No Permission
		end
	end

end
