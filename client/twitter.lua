local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function escape_str(s)
	return s
end

local function GenerateTweetId()
    local tweetId = "TWEET-"..math.random(11111111, 99999999)
    return tweetId
end

-- NUI Callback

RegisterNUICallback('GetTweets', function(data, cb)
    cb(PhoneData.Tweets)
end)

RegisterNUICallback('PostNewTweet', function(data, cb)
    local TweetMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        citizenid = PhoneData.PlayerData.citizenid,
        message = escape_str(data.Message):gsub("[%<>\"()\'$]",""),
        time = data.Date,
        tweetId = GenerateTweetId(),
        url = data.url
    }

    TriggerServerEvent('qb-phone:server:UpdateTweets', TweetMessage)
    cb("ok")
end)

RegisterNUICallback('DeleteTweet',function(data)
    TriggerServerEvent('qb-phone:server:DeleteTweet', data.id)
end)

RegisterNUICallback('FlagTweet',function(data, cb)
    QBCore.Functions.Notify(data.name..' was reported for saying '..data.message, "error")
    cb('ok')
end)

-- Events

RegisterNetEvent('qb-phone:client:UpdateTweets', function(src, Tweets, delete)
    if not PhoneData or not FullyLoaded then return end
    PhoneData.Tweets = Tweets
    local MyPlayerId = PhoneData.PlayerData.source
    local NewTweetData = Tweets[#Tweets]
    local newFirst, newLast = NewTweetData.firstName:gsub("[%<>\"()\'$]",""), NewTweetData.lastName:gsub("[%<>\"()\' $]","")
    if not delete then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "@"..newFirst.." "..newLast,
                text = NewTweetData.message:gsub("[%<>\"()\'$]",""),
                icon = "fab fa-twitter",
                color = "#1DA1F2",
            },
        })
    else
        if src == MyPlayerId then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Twitter",
                    text = "Tweet deleted!",
                    icon = "fab fa-twitter",
                    color = "#1DA1F2",
                    timeout = 1000,
                },
            })
        end
    end

    SendNUIMessage({
        action = "UpdateTweets",
        Tweets = PhoneData.Tweets
    })
end)