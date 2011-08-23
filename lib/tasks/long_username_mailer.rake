namespace :long_usernames do
  desc 'send email warnings to all user who have usernames with more than 15 characters'   
  task :warning_emails => :environment do      
    User.all.each do |user| 
      if user.username.length > 15 # and user.email == 'doktorj@dreamcatcher.net' # for testing
        log "sent long username warning to: #{user.email} #{user.username} (id: #{user.id}) " 
        UserMailer.warn_long_username_email(user) #.deliver  # keep .deliver commented out for testing
        sleep 1
      end
    end
  end

  desc 'send email updates to all user who still have usernames with more than 15 characters after the 30 day warning messages have been sent out'   
  task :auto_truncate_all => :environment do      
    User.all.each do |user| 
      if user.username.length > 15 
        old_username = user.username
        user.username = user.username.truncate(15, :omission => '')
        # user.save! 
        log "auto updated long username from #{old_username} to: #{user.username} and emailed: #{user.email}" 
        UserMailer.long_username_auto_updated_email(user,old_username) #.deliver  # keep .deliver commented out to prevent mailing for tests
        sleep 1
      end
    end
  end  
  
end