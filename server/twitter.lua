Tweets = {}

-- Events

CreateThread(function()
    local tweetsSelected = MySQL.query.await('SELECT * FROM phone_tweets WHERE `date` > NOW() - INTERVAL ? hour', {Config.TweetDuration})
    Tweets = tweetsSelected
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
    local Player = QBCore.Functions.GetPlayer(src)
    local HasVPN = Player.Functions.GetItemByName(Config.VPNItem)

    if (TweetData.showAnonymous and HasVPN) then
        TweetData.firstName = "Anonymous"
        TweetData.lastName = ""
    end
    
    print(json.encode(TweetData.url))
    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        TweetData.tweetId,
        TweetData.type,
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
                date = os.date('%Y-%m-%d %H:%M:%S')
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, src, Tweets, false)
        end
    end)
end)

-- Use this tweet function in different resources I used it in Renewed Fishing script to make the ped tweet close to start of tournaments --
local function AddNewTweet(TweetData)
    local tweetID = TweetData and TweetData.tweetId or "TWEET-"..math.random(11111111, 99999999)

    MySQL.insert('INSERT INTO phone_tweets (citizenid, firstName, lastName, message, url, tweetid, type) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        TweetData.citizenid,
        TweetData.firstName:gsub("[%<>\"()\'$]",""),
        TweetData.lastName:gsub("[%<>\"()\'$]",""),
        TweetData.message:gsub("[%<>\"()\'$]",""),
        TweetData.url,
        tweetID,
        TweetData.type or "tweet",
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
                date = os.date('%Y-%m-%d %H:%M:%S')
            }

            TriggerClientEvent('qb-phone:client:UpdateTweets', -1, 0, Tweets, false)
        end
    end)
end exports("AddNewTweet", AddNewTweet)