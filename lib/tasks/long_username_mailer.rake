namespace :long_usernames do
  desc 'send email warnings to all user who have usernames with more than 15 characters'   
  task :warning_emails => :environment do      
    User.all.each do |user| 
      if user.username.length > 15 and user.email == 'doktorj@dreamcatcher.net'
        log "sent long username warning to: #{user.email} #{user.username} (id: #{user.id}) " 
        UserMailer.warn_long_username_email(user) # .deliver  keep .deliver commented out for testing
        sleep 1
      end
    end
  end
end