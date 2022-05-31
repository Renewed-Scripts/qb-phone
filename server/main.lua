local QBCore = exports['qb-core']:GetCoreObject()
local QBPhone = {}
local Tweets = {} -- Located in the Twitter File as well ??
local AppAlerts = {}
local MentionedTweets = {} -- Located in the Twitter File as well ??
local Hashtags = {} -- Located in the Twitter File as well ??
local Calls = {}
local Adverts = {} -- Located in the advertisements File as well ??
local WebHook = "https://discord.com/api/webhooks/881102998498074664/60jhrJkGkIGr6AUSvvFGXskwyr-rq5F5bBGfACqEiaeZerbW2A-w4MSjbFiippSTiGxR"
local bannedCharacters = {'%','$',';'}

-- Functions

local function GetOnlineStatus(number)
    local Target = QBCore.Functions.GetPlayerByPhone(number)
    local retval = false
    if Target then
        retval = true
    end
    return retval
end

local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end

local function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function QBPhone.SetPhoneAlerts(citizenid, app, alerts)
    if citizenid and app then
        if not AppAlerts[citizenid] then
            AppAlerts[citizenid] = {}
            if not AppAlerts[citizenid][app] then
                if not alerts then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = alerts
                end
            end
        else
            if not AppAlerts[citizenid][app] then
                if not alerts then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = 0
                end
            else
                if not alerts then
                    AppAlerts[citizenid][app]= 1
                else
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 0
                end
            end
        end
    end
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
    local Target = QBCore.Functions.GetPlayerByPhone(ContactData.number)
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
    if Player then
        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
            Invoices = {},
            Garage = {},
            Mails = {},
            Adverts = {},
            CryptoTransactions = {},
            Tweets = {},
            Images = {},
            InstalledApps = Player.PlayerData.metadata["phonedata"].InstalledApps
        }
        PhoneData.Adverts = Adverts

        local result = exports.oxmysql:executeSync('SELECT * FROM player_contacts WHERE citizenid = ? ORDER BY name ASC', {Player.PlayerData.citizenid})
        if result[1] then
            for _, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end

            PhoneData.PlayerContacts = result
        end

        local invoices = exports.oxmysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid = ?', {Player.PlayerData.citizenid})
        if invoices[1] then
            for k, v in pairs(invoices) do
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

        local garageresult = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
        if garageresult[1] then
            for k, v in pairs(garageresult) do
                local vehicleModel = v.vehicle
                if (QBCore.Shared.Vehicles[vehicleModel]) and (Garages[v.garage]) then
                    v.garage = Garages[v.garage].label
                    v.vehicle = QBCore.Shared.Vehicles[vehicleModel].name
                    v.brand = QBCore.Shared.Vehicles[vehicleModel].brand
                end

            end
            PhoneData.Garage = garageresult
        end

        local messages = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ?', {Player.PlayerData.citizenid})
        if messages and next(messages) then
            PhoneData.Chats = messages
        end

        if AppAlerts[Player.PlayerData.citizenid] then
            PhoneData.Applications = AppAlerts[Player.PlayerData.citizenid]
        end

        if MentionedTweets[Player.PlayerData.citizenid] then
            PhoneData.MentionedTweets = MentionedTweets[Player.PlayerData.citizenid]
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
            for k, v in pairs(mails) do
                if mails[k].button then
                    mails[k].button = json.decode(mails[k].button)
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
    end
end)

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


QBCore.Functions.CreateCallback('qb-phone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player then
            if (Player.PlayerData.job.name == "lawyer" or Player.PlayerData.job.name == "realestate" or
                Player.PlayerData.job.name == "mechanic" or Player.PlayerData.job.name == "taxi" or
                Player.PlayerData.job.name == "police" or Player.PlayerData.job.name == "ems" or Player.PlayerData.job.name == "hayes") and
                Player.PlayerData.job.onduty then
                Lawyers[#Lawyers+1] = {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                    typejob = Player.PlayerData.job.name
                }
            end
        end
    end
    cb(Lawyers)
end)

QBCore.Functions.CreateCallback("qb-phone:server:GetWebhook",function(source,cb)
	cb(WebHook)
end)

-- Events

RegisterNetEvent('qb-phone:server:SetCallState', function(bool)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    if not Calls[Ply.PlayerData.citizenid] then Calls[Ply.PlayerData.citizenid] = {} end
    Calls[Ply.PlayerData.citizenid].inCall = bool
end)

RegisterNetEvent('qb-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayerByPhone(TargetData.number)
    if Target then
        TriggerClientEvent('qb-phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
    end
end)

RegisterNetEvent('qb-phone:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local CitizenId = QBCore.Functions.GetPlayer(src).citizenid
    QBPhone.SetPhoneAlerts(CitizenId, app, alerts)
end)

RegisterNetEvent('qb-phone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:execute(
        'UPDATE player_contacts SET name = ?, number = ?, iban = ? WHERE citizenid = ? AND name = ? AND number = ?',
        {newName, newNumber, newIban, Player.PlayerData.citizenid, oldName, oldNumber})
end)

RegisterNetEvent('qb-phone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:execute('DELETE FROM player_contacts WHERE name = ? AND number = ? AND citizenid = ?',
        {Name, Number, Player.PlayerData.citizenid})
end)

RegisterNetEvent('qb-phone:server:AddNewContact', function(name, number, iban)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number, iban) VALUES (?, ?, ?, ?)', {Player.PlayerData.citizenid, tostring(name), tostring(number), tostring(iban)})
end)

RegisterNetEvent('qb-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour .. ":" .. Minute
    TriggerClientEvent('qb-phone:client:AddRecentCall', src, data, label, type)
    local Trgt = QBCore.Functions.GetPlayerByPhone(data.number)
    if Trgt then
        TriggerClientEvent('qb-phone:client:AddRecentCall', Trgt.PlayerData.source, {
            name = Ply.PlayerData.charinfo.firstname .. " " .. Ply.PlayerData.charinfo.lastname,
            number = Ply.PlayerData.charinfo.phone,
            anonymous = data.anonymous
        }, label, "outgoing")
    end
end)

RegisterNetEvent('qb-phone:server:CancelCall', function(ContactData)
    local Ply = QBCore.Functions.GetPlayerByPhone(ContactData.TargetData.number)
    if Ply then
        TriggerClientEvent('qb-phone:client:CancelCall', Ply.PlayerData.source)
    end
end)

RegisterNetEvent('qb-phone:server:AnswerCall', function(CallData)
    local Ply = QBCore.Functions.GetPlayerByPhone(CallData.TargetData.number)
    if Ply then
        TriggerClientEvent('qb-phone:client:AnswerCall', Ply.PlayerData.source)
    end
end)

RegisterNetEvent('qb-phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
    local MetaData = json.decode(result[1].metadata)
    MetaData.phone = MData
    exports.oxmysql:execute('UPDATE players SET metadata = ? WHERE citizenid = ?',
        {json.encode(MetaData), Player.PlayerData.citizenid})
    Player.Functions.SetMetaData("phone", MData)
end)

RegisterNetEvent('qb-phone:server:GiveContactDetails', function(PlayerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SuggestionData = {
        name = {
            [1] = Player.PlayerData.charinfo.firstname,
            [2] = Player.PlayerData.charinfo.lastname
        },
        number = Player.PlayerData.charinfo.phone,
        bank = Player.PlayerData.charinfo.account
    }

    TriggerClientEvent('qb-phone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterNetEvent('qb-phone:server:InstallApplication', function(ApplicationData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.PlayerData.metadata["phonedata"].InstalledApps[ApplicationData.app] = ApplicationData
    Player.Functions.SetMetaData("phonedata", Player.PlayerData.metadata["phonedata"])
end)

RegisterNetEvent('qb-phone:server:RemoveInstallation', function(App)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.PlayerData.metadata["phonedata"].InstalledApps[App] = nil
    Player.Functions.SetMetaData("phonedata", Player.PlayerData.metadata["phonedata"])
end)

-- SHIT THAT IS NO LONGER NEEDED

QBCore.Functions.CreateCallback('qb-phone:server:CanTransferMoney', function(source, cb, amount, iban)
    local newAmount = tostring(amount)
    local newiban = tostring(iban)
    for k, v in pairs(bannedCharacters) do
        newAmount = string.gsub(newAmount, '%' .. v, '')
        newiban = string.gsub(newiban, '%' .. v, '')
    end
    iban = newiban
    amount = tonumber(newAmount)

    local Player = QBCore.Functions.GetPlayer(source)
    if (Player.PlayerData.money.bank - amount) >= 0 then
        local query = '%"account":"' .. iban .. '"%'
        local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE charinfo LIKE ?', {query})
        if result[1] then
            local Reciever = QBCore.Functions.GetPlayerByCitizenId(result[1].citizenid)
            Player.Functions.RemoveMoney('bank', amount)
            if Reciever then
                Reciever.Functions.AddMoney('bank', amount)
            else
                local RecieverMoney = json.decode(result[1].money)
                RecieverMoney.bank = (RecieverMoney.bank + amount)
                exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(RecieverMoney), result[1].citizenid})
            end
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterNetEvent('qb-phone:server:TransferMoney', function(iban, amount)
    local src = source
    local sender = QBCore.Functions.GetPlayer(src)

    local query = '%' .. iban .. '%'
    local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE charinfo LIKE ?', {query})
    if result[1] then
        local reciever = QBCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

        if reciever then
            local PhoneItem = reciever.Functions.GetItemByName("phone")
            reciever.Functions.AddMoney('bank', amount, "phone-transfered-from-" .. sender.PlayerData.citizenid)
            sender.Functions.RemoveMoney('bank', amount, "phone-transfered-to-" .. reciever.PlayerData.citizenid)

            if PhoneItem then
                TriggerClientEvent('qb-phone:client:TransferMoney', reciever.PlayerData.source, amount,
                    reciever.PlayerData.money.bank)
            end
        else
            local moneyInfo = json.decode(result[1].money)
            moneyInfo.bank = round((moneyInfo.bank + amount))
            exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?',
                {json.encode(moneyInfo), result[1].citizenid})
            sender.Functions.RemoveMoney('bank', amount, "phone-transfered")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "That account number doesn't exist!", "error")
    end
end)