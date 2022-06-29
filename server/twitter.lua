local QBCore = exports['qb-core']:GetCoreObject()
QBPhone = {}
Tweets = {}
Hashtags = {}

-- Events

CreateThread(function()
    MySQL.Async.fetchAll('SELECT * FROM phone_tweets', {}, function(data)
        if data then
            for k, v in pairs(data) do
                Tweets[#Tweets+1] = {
                    id = v.id,
                    citizenid = v.citizenid,
                    firstName = v.firstName,
                    lastName = v.lastName,
                    message = v.message,
                    url = v.url,
                    picture = v.picture,
                    tweetId = v.tweetId,
                    time = v.time
                }

                if #Tweets >= Config.TsunamiTweets then break end
            end
        end
    end)
end)

RegisterNetEvent('qb-phone:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            if (Player.PlayerData.charinfo.firstname == firstName and Player.PlayerData.charinfo.lastname == lastName) then
                QBPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('qb-phone:client:GetMentioned', Player.PlayerData.source, TweetMessage)
            else
                local query1 = '%' .. firstName .. '%'
                local query2 = '%' .. lastName .. '%'
                local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE charinfo LIKE ? AND charinfo LIKE ?', {query1, query2})
                if result[1] then
                    local MentionedTarget = result[1].citizenid
                    QBPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                end
            end
        end
    end
end)

RegisterNetEvent('qb-phone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] and next(Hashtags[Handle]) then
        Hashtags[Handle].messages[#Hashtags[Handle].messages+1] = messageData
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        Hashtags[Handle].messages[#Hashtags[Handle].messages+1] = messageData
    end
    TriggerClientEvent('qb-phone:client:UpdateHashtags', -1, Handle, messageData)
end)

RegisterNetEvent('qb-phone:server:DeleteTweet', function(tweetId)
    local src = source
    for i = 1, #Tweets do
        if Tweets[i].tweetId == tweetId then
            Tweets[i] = nil
            break
        end
    end
    TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, TweetData, Tweets, true)
end)

RegisterNetEvent('qb-phone:server:UpdateTweets', function(TweetData)
    local src = source

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, picture, tweetid, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        TweetData.picture:gsub("[%<>\"()\'$]",""),
        TweetData.tweetId,
        time
    }, function(id)
        if id then
            Tweets[#Tweets+1] = {
                id = id,
                citizenid = TweetData.citizenid,
                firstName = TweetData.firstName:gsub("[%<>\"()\'$]",""),
                lastName = TweetData.lastName:gsub("[%<>\"()\'$]",""),
                message = TweetData.message:gsub("[%<>\"()\'$]",""),
                url = TweetData.url,
                picture = TweetData.picture:gsub("[%<>\"()\'$]",""),
                tweetId =TweetData.tweetId,
                time = time
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, false)
        end
    end)
end)



-- Use this tweet function in different resources I used it in Renewed Fishing script to make the ped tweet close to start of tournaments --
local function AddNewTweet(TweetData)

    local tweetID = TweetData and TweetData.tweetId or "TWEET-"..math.random(11111111, 99999999)

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, picture, tweetid, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        TweetData.picture:gsub("[%<>\"()\'$]",""),
        tweetID,
        time
    }, function(id)
        if id then
            Tweets[#Tweets+1] = {
                id = id,
                citizenid = TweetData.citizenid,
                firstName = TweetData.firstName:gsub("[%<>\"()\'$]",""),
                lastName = TweetData.lastName:gsub("[%<>\"()\'$]",""),
                message = TweetData.message:gsub("[%<>\"()\'$]",""),
                url = TweetData.url,
                picture = TweetData.picture:gsub("[%<>\"()\'$]",""),
                tweetId = tweetID,
                time = time
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, false)
        end
    end)
end exports("AddNewTweet", AddNewTweet)