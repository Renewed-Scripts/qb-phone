local QBCore = exports['qb-core']:GetCoreObject()

Tweets = {}

-- Events

CreateThread(function()
    MySQL.Async.fetchAll('SELECT * FROM phone_tweets', {}, function(data)
        if data then
            for _, v in pairs(data) do
                Tweets[#Tweets+1] = {
                    id = v.id,
                    citizenid = v.citizenid,
                    firstName = v.firstName,
                    lastName = v.lastName,
                    message = v.message,
                    url = v.url,
                    tweetId = v.tweetId,
                    type = v.type,
                    time = v.time
                }

                if #Tweets >= Config.TsunamiTweets then break end
            end
        end
    end)
end)

RegisterNetEvent('qb-phone:server:DeleteTweet', function(tweetId)
    local src = source
    local CID = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local delete = false
    for i = 1, #Tweets do
        if Tweets[i].tweetId == tweetId and Tweets[i].citizenid == CID then
            table.remove(Tweets, i)
            delete = true
            break
        end
    end
    if not delete then return end
    TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, true)
end)

RegisterNetEvent('qb-phone:server:UpdateTweets', function(TweetData)
    local src = source
    print(json.encode(TweetData.url))
    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        TweetData.tweetId,
        TweetData.type,
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
                tweetId =TweetData.tweetId,
                type = TweetData.type,
                time = time
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, false)
        end
    end)
end)

-- Use this tweet function in different resources I used it in Renewed Fishing script to make the ped tweet close to start of tournaments --
local function AddNewTweet(TweetData)
    local tweetID = TweetData and TweetData.tweetId or "TWEET-"..math.random(11111111, 99999999)

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        tweetID,
        TweetData.type or "tweet",
        time
    }, function(id)
        if id then
            Tweets[#Tweets+1] = {
                id = id,
                citizenid = TweetData.citizenid or "TEMP332",
                firstName = TweetData.firstName:gsub("[%<>\"()\'$]",""),
                lastName = TweetData.lastName:gsub("[%<>\"()\'$]",""),
                message = TweetData.message:gsub("[%<>\"()\'$]",""),
                url = TweetData.url or "",
                tweetId = tweetID,
                type = TweetData.type or "tweet",
                time = time
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, 0, Tweets, false)
        end
    end)
end exports("AddNewTweet", AddNewTweet)