-- we only do this at the start of the server because its resource intensive and might lagg your database depending on the amount of data that needs to be dropped --
AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
      Wait(100)
      MySQL.query.await('DELETE FROM phone_tweets WHERE `date` < NOW() - INTERVAL ? hour', {Config.TweetDuration})
      MySQL.query.await('DELETE FROM player_mails WHERE `date` < NOW() - INTERVAL ? hour', {Config.MailDuration})
   end
end)