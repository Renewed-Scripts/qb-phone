time = time or 0




-- Updates time every hour just because lol --
CreateThread(function()
    while true do
        time = os.time()
        Wait(60 * 60000)
    end
end)

-- we only do this at the start of the server because its resource intensive and might lagg your database depending on the amount of data that needs to be dropped --
CreateThread(function()
    Wait(15000)

    local Tweets = exports.oxmysql:executeSync('SELECT * FROM phone_tweets', {})
    for _, v in pairs(Tweets) do
        if v.time and (time - v.time) / 86400 >= Config.DatabaseCleanup.tweets then
            MySQL.query('DELETE FROM phone_tweets WHERE id = ?', {v.id})
        elseif not v.time then
            MySQL.Sync.execute('UPDATE phone_tweets SET time = @time WHERE id = @id', {
                ["@id"] = v.id,
                ["@time"] =  time,
            })
        end
    end

    local mails = exports.oxmysql:executeSync('SELECT * FROM player_mails', {})
    for _, v in pairs(mails) do
        if v.time and (time - v.time) / 86400 >= Config.DatabaseCleanup.mails then
            MySQL.query('DELETE FROM player_mails WHERE id = ?', {v.id})
        elseif not v.time then
            MySQL.Sync.execute('UPDATE player_mails SET time = @time WHERE id = @id', {
                ["@id"] = v.id,
                ["@time"] =  time,
            })
        end
    end

end)