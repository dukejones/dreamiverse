namespace :long_usernames do
  desc 'send email warnings to all user who have usernames with more than 15 characters'   
  task :warning_emails => :environment do      
    users = []
    User.all.each do |user| 
      if user.username.length > 15 and  user.email == 'doktorj@dreamcatcher.net'
        log "sending warning email for user: #{user.username} to #{user.email}" 
        UserMailer.warn_long_username_email(user) #.deliver 
        sleep 1
      end
    end
  end
end