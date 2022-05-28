local QBCore = exports['qb-core']:GetCoreObject()
QBPhone = {}
MentionedTweets = {}
Tweets = {}
Hashtags = {}

-- Functions

function QBPhone.AddMentionedTweet(citizenid, TweetData)
    if MentionedTweets[citizenid] == nil then
        MentionedTweets[citizenid] = {}
    end
    MentionedTweets[citizenid][#MentionedTweets[citizenid]+1] = TweetData
end

-- Events

RegisterNetEvent('qb-phone:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.charinfo.firstname == firstName and Player.PlayerData.charinfo.lastname == lastName) then
                QBPhone.SetPhoneAlerts(Player.PlayerData.citizenid, "twitter")
                QBPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('qb-phone:client:GetMentioned', Player.PlayerData.source, TweetMessage, AppAlerts[Player.PlayerData.citizenid]["twitter"])
            else
                local query1 = '%' .. firstName .. '%'
                local query2 = '%' .. lastName .. '%'
                local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE charinfo LIKE ? AND charinfo LIKE ?', {query1, query2})
                if result[1] ~= nil then
                    local MentionedTarget = result[1].citizenid
                    QBPhone.SetPhoneAlerts(MentionedTarget, "twitter")
                    QBPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                end
            end
        end
    end
end)

RegisterNetEvent('qb-phone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
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
        end
    end
    TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, {}, true)
end)

RegisterNetEvent('qb-phone:server:UpdateTweets', function(NewTweets, TweetData)
    local src = source
    local InsertTweet = exports.oxmysql:insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, date, url, picture, tweetid) VALUES (?, ?, ?, ?, NOW(), ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName,
        TweetData.lastName,
        TweetData.message,
        TweetData.url:gsub("[%<>\"()\' $]",""),
        TweetData.picture,
        TweetData.tweetId
    })
    TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, NewTweets, TweetData, false)
end)