namespace :yo_tengo_un_cine do
  desc "Test task"
  task :test => :environment do
    Rails.logger.info( "It is a test" )
  end
end
