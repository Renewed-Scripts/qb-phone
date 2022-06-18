local QBCore = exports['qb-core']:GetCoreObject()
local Hashtags = {} -- Located in the Twitter File as well ??
local Calls = {}
local Adverts = {} -- Located in the advertisements File as well ??
local WebHook = "https://discord.com/api/webhooks/881102998498074664/60jhrJkGkIGr6AUSvvFGXskwyr-rq5F5bBGfACqEiaeZerbW2A-w4MSjbFiippSTiGxR"

-- Functions
local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

local function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        retval[#retval+1] = i
    end
    return retval
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-phone:server:GetCallState', function(source, cb, ContactData)
    ContactData.number = tonumber(ContactData.number)
    local Target = QBCore.Functions.GetPlayerByPhone(tonumber(ContactData.number))
    if Target then
        if Calls[Target.PlayerData.citizenid] then
            if Calls[Target.PlayerData.citizenid].inCall then
                cb(false, true)
            else
                cb(true, true)
            end
        else
            cb(true, true)
        end
    else
        cb(false, false)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetPhoneData', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not src then return end


    local PhoneData = {
        PlayerContacts = {},
        Chats = {},
        Hashtags = {},
        Invoices = {},
        Garage = {},
        Mails = {},
        Adverts = {},
        CryptoTransactions = {},
        Tweets = {},
        Images = {},
    }

    PhoneData.Adverts = Adverts

    local result = exports.oxmysql:executeSync('SELECT * FROM player_contacts WHERE citizenid = ? ORDER BY name ASC', {Player.PlayerData.citizenid})
    if result[1] then
        PhoneData.PlayerContacts = result
    end

    local invoices = exports.oxmysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if invoices[1] then
        for _, v in pairs(invoices) do
            local Ply = QBCore.Functions.GetPlayerByCitizenId(v.sender)
            if Ply then
                v.number = Ply.PlayerData.charinfo.phone
            else
                local res = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', {v.sender})
                if res[1] then
                    res[1].charinfo = json.decode(res[1].charinfo)
                    v.number = res[1].charinfo.phone
                else
                    v.number = nil
                end
            end
        end
        PhoneData.Invoices = invoices
    end

    local messages = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ?', {Player.PlayerData.citizenid})
    if messages and next(messages) then
        PhoneData.Chats = messages
    end

    if Hashtags and next(Hashtags) then
        PhoneData.Hashtags = Hashtags
    end

    local Tweets = exports.oxmysql:executeSync('SELECT * FROM phone_tweets WHERE `date` > NOW() - INTERVAL ? hour', {Config.TweetDuration})

    if Tweets and next(Tweets) then
        PhoneData.Tweets = Tweets
    end

    local mails = exports.oxmysql:executeSync('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {Player.PlayerData.citizenid})
    if mails[1] then
        for _, v in pairs(mails) do
            if v.button then
                v.button = json.decode(v.button)
            end
        end
        PhoneData.Mails = mails
    end

    local transactions = exports.oxmysql:executeSync('SELECT * FROM crypto_transactions WHERE citizenid = ? ORDER BY `date` ASC', {Player.PlayerData.citizenid})
    if transactions[1] then
        for _, v in pairs(transactions) do
            PhoneData.CryptoTransactions[#PhoneData.CryptoTransactions+1] = {
                TransactionTitle = v.title,
                TransactionMessage = v.message
            }
        end
    end

    local images = exports.oxmysql:executeSync('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{Player.PlayerData.citizenid})
    if images and next(images) then
        PhoneData.Images = images
    end
    cb(PhoneData)
end)


-- Can't even wrap my head around this lol diffently needs a good old rewrite
QBCore.Functions.CreateCallback('qb-phone:server:FetchResult', function(source, cb, search)
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}
    local query = 'SELECT * FROM `players` WHERE `citizenid` = "' .. search .. '"'
    local searchParameters = SplitStringToArray(search)
    if #searchParameters > 1 then
        query = query .. ' OR `charinfo` LIKE "%' .. searchParameters[1] .. '%"'
        for i = 2, #searchParameters do
            query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] .. '%"'
        end
    else
        query = query .. ' OR `charinfo` LIKE "%' .. search .. '%"'
    end
    local ApartmentData = exports.oxmysql:executeSync('SELECT * FROM apartments', {})
    for k, v in pairs(ApartmentData) do
        ApaData[v.citizenid] = ApartmentData[k]
    end
    local result = exports.oxmysql:executeSync(query)
    if result[1] then
        for k, v in pairs(result) do
            local charinfo = json.decode(v.charinfo)
            local metadata = json.decode(v.metadata)
            local appiepappie = {}
            if ApaData[v.citizenid] and next(ApaData[v.citizenid]) then
                appiepappie = ApaData[v.citizenid]
            end
            searchData[#searchData+1] = {
                citizenid = v.citizenid,
                firstname = charinfo.firstname,
                lastname = charinfo.lastname,
                birthdate = charinfo.birthdate,
                phone = charinfo.phone,
                nationality = charinfo.nationality,
                gender = charinfo.gender,
                warrant = false,
                driverlicense = metadata["licences"]["driver"],
                appartmentdata = appiepappie
            }
        end
        cb(searchData)
    else
        cb(nil)
    end
end)



-- Services
QBCore.Functions.CreateCallback('qb-phone:server:GetServicesWithActivePlayers', function(source, cb)
    local Services = {}

    for i = 1, #Config.ServiceJobs do
        local job = Config.ServiceJobs[i]
        Services[job.Job] = {}
        Services[job.Job].Label = QBCore.Shared.Jobs[job.Job].label
        Services[job.Job].HeaderBackgroundColor = job.HeaderBackgroundColor
        Services[job.Job].Players = {}
    end

    for _, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            local job = Player.PlayerData.job.name
            if Services[job] and Player.PlayerData.job.onduty then
                Services[job].Players[#(Services[job].Players)+1] = {
                    Name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    Phone = Player.PlayerData.charinfo.phone,
                }
            end
        end
    end
    cb(Services)
end)

-- Webhook needs to get fixed, right now anyone can grab this and use it to spam dick pics in Discord servers
QBCore.Functions.CreateCallback("qb-phone:server:GetWebhook",function(source,cb)
	cb(WebHook)
end)

-- Events
RegisterNetEvent('qb-phone:server:SetCallState', function(bool)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)

    if not Ply then return end

    if not Calls[Ply.PlayerData.citizenid] then Calls[Ply.PlayerData.citizenid] = {} end
    Calls[Ply.PlayerData.citizenid].inCall = bool
end)

RegisterNetEvent('qb-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByPhone(tonumber(TargetData.number))
    if not Target or not Ply then return end

    TriggerClientEvent('qb-phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
end)

RegisterNetEvent('qb-phone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:execute(
        'UPDATE player_contacts SET name = ?, number = ?, iban = ? WHERE citizenid = ? AND name = ? AND number = ?',
        {newName, newNumber, newIban, Player.PlayerData.citizenid, oldName, oldNumber})
end)

RegisterNetEvent('qb-phone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:execute('DELETE FROM player_contacts WHERE name = ? AND number = ? AND citizenid = ?',
        {Name, Number, Player.PlayerData.citizenid})
end)

RegisterNetEvent('qb-phone:server:AddNewContact', function(name, number, iban)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number, iban) VALUES (?, ?, ?, ?)', {Player.PlayerData.citizenid, tostring(name), tostring(number), tostring(iban)})
end)

RegisterNetEvent('qb-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour .. ":" .. Minute

    TriggerClientEvent('qb-phone:client:AddRecentCall', src, data, label, type)

    local Target = QBCore.Functions.GetPlayerByPhone(tonumber(data.number))
    if not Target then return end

    TriggerClientEvent('qb-phone:client:AddRecentCall', Target.PlayerData.source, {
        name = Ply.PlayerData.charinfo.firstname .. " " .. Ply.PlayerData.charinfo.lastname,
        number = Ply.PlayerData.charinfo.phone,
        anonymous = data.anonymous
    }, label, "outgoing")
end)

RegisterNetEvent('qb-phone:server:CancelCall', function(ContactData)
    local Ply = QBCore.Functions.GetPlayerByPhone(tonumber(ContactData.TargetData.number))
    if not Ply then return end
    TriggerClientEvent('qb-phone:client:CancelCall', Ply.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:AnswerCall', function(CallData)
    local Ply = QBCore.Functions.GetPlayerByPhone(tonumber(CallData.TargetData.number))
    if not Ply then return end

    TriggerClientEvent('qb-phone:client:AnswerCall', Ply.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.SetMetaData("phone", MData)
end)