# config/puma.rb
environment ENV['RACK_ENV']
threads 0,12

workers 3
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end