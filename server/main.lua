local Hashtags = {} -- Located in the Twitter File as well ??
local Calls = {}
local WebHook = Config.Webhook

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

lib.callback.register('qb-phone:server:GetCallState', function(source, ContactData)
    local number = tostring(ContactData.number)
    local Target = QBCore.Functions.GetPlayerByPhone(number)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Target then return false, false end

    if Target.PlayerData.citizenid == Player.PlayerData.citizenid then return false, false end

    if Calls[Target.PlayerData.citizenid] then
        if Calls[Target.PlayerData.citizenid].inCall then
            return false, true
        else
            return true, true
        end
    else
        return true, true
    end
end)

lib.callback.register('qb-phone:server:GetPhoneData', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not src then return end
    local CID = Player.PlayerData.citizenid


    local PhoneData = {
        PlayerContacts = {},
        Chats = {},
        Hashtags = {},
        Invoices = {},
        Garage = {},
        Mails = {},
        Documents = {},
        Adverts = Adverts,
        Tweets = Tweets,
        Images = {},
        ChatRooms = {},
    }

    local result = exports.oxmysql:executeSync('SELECT * FROM player_contacts WHERE citizenid = ? ORDER BY name ASC', {CID})
    if result[1] then
        PhoneData.PlayerContacts = result
    end

    local Invoices = exports.oxmysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid = ?', {CID})
    if Invoices[1] then
        PhoneData.Invoices = Invoices
    end

    local Note = exports.oxmysql:executeSync('SELECT * FROM phone_note WHERE citizenid = ?', {CID})
    if Note[1] then
        PhoneData.Documents = Note
    end

    local messages = exports.oxmysql:executeSync('SELECT * FROM phone_messages WHERE citizenid = ?', {CID})
    if messages and next(messages) then
        PhoneData.Chats = messages
    end

    if Hashtags and next(Hashtags) then
        PhoneData.Hashtags = Hashtags
    end

    local mails = exports.oxmysql:executeSync('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {CID})
    if mails[1] then
        PhoneData.Mails = mails
    end

    local images = exports.oxmysql:executeSync('SELECT * FROM phone_gallery WHERE citizenid = ? ORDER BY `date` DESC',{CID})
    if images and next(images) then
        PhoneData.Images = images
    end

    local chat_rooms = MySQL.query.await("SELECT id, room_code, room_name, room_owner_id, room_owner_name, room_members, is_pinned, IF(room_pin = '' or room_pin IS NULL, false, true) AS protected FROM phone_chatrooms")
    if chat_rooms[1] then
        PhoneData.ChatRooms = chat_rooms
        ChatRooms = chat_rooms
    end
    return PhoneData
end)


-- Can't even wrap my head around this lol diffently needs a good old rewrite
lib.callback.register('qb-phone:server:FetchResult', function(_, input)
    local search = escape_sqli(input)
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
        for _, v in pairs(result) do
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
        return searchData
    else
        return nil
    end
end)

-- Webhook needs to get fixed, right now anyone can grab this and use it to spam dick pics in Discord servers
lib.callback.register("qb-phone:server:GetWebhook",function(_)
	return WebHook
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
    local Target = QBCore.Functions.GetPlayerByPhone(tostring(TargetData.number))
    if not Target or not Ply then return end

    TriggerClientEvent('qb-phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall)
end)

RegisterNetEvent('qb-phone:server:EditContact', function(newName, newNumber, oldName, oldNumber)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:execute(
        'UPDATE player_contacts SET name = ?, number = ? WHERE citizenid = ? AND name = ? AND number = ?',
        {newName, newNumber, Player.PlayerData.citizenid, oldName, oldNumber})
end)

RegisterNetEvent('qb-phone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:execute('DELETE FROM player_contacts WHERE name = ? AND number = ? AND citizenid = ?',
        {Name, Number, Player.PlayerData.citizenid})
end)

RegisterNetEvent('qb-phone:server:AddNewContact', function(name, number)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number) VALUES (?, ?, ?)', {Player.PlayerData.citizenid, tostring(name), number})
end)

RegisterNetEvent('qb-phone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour .. ":" .. Minute

    TriggerClientEvent('qb-phone:client:AddRecentCall', src, data, label, type)

    local Target = QBCore.Functions.GetPlayerByPhone(data.number)
    if not Target then return end

    TriggerClientEvent('qb-phone:client:AddRecentCall', Target.PlayerData.source, {
        name = Ply.PlayerData.charinfo.firstname .. " " .. Ply.PlayerData.charinfo.lastname,
        number = Ply.PlayerData.charinfo.phone,
        anonymous = data.anonymous
    }, label, "outgoing")
end)

RegisterNetEvent('qb-phone:server:GiveContactDetails', function(PlayerId)
    if not PlayerId then return end
    local src = source
    if not src then return end

    local Sender = QBCore.Functions.GetPlayer(src)

    local contactInfo = {
        name = Sender.PlayerData.charinfo.firstname.." "..Sender.PlayerData.charinfo.lastname,
        number = Sender.PlayerData.charinfo.phone,
        bank = Sender.PlayerData.charinfo.account,
    }

    TriggerClientEvent('qb-phone:client:giveContactRequest', PlayerId, contactInfo)
end)

RegisterNetEvent('qb-phone:server:acceptContactRequest', function(contactInfo)
    if not contactInfo then return end
    local src = source
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid

    local result = MySQL.query.await("SELECT * FROM player_contacts WHERE citizenid = ? AND number = ?", {cid, contactInfo.number})
    if result[1] then return TriggerClientEvent('QBCore:Notify', src, 'You already have this number added!', "error") end

    exports.oxmysql:insert('INSERT INTO player_contacts (citizenid, name, number) VALUES (?, ?, ?)', {cid, tostring(contactInfo.name), contactInfo.number})
    TriggerClientEvent('qb-phone:client:updateContactInfo', src, contactInfo)
end)

RegisterNetEvent('qb-phone:server:CancelCall', function(ContactData)
    local Ply = QBCore.Functions.GetPlayerByPhone(tostring(ContactData.TargetData.number))
    if not Ply then return end
    TriggerClientEvent('qb-phone:client:CancelCall', Ply.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:AnswerCall', function(CallData)
    local Ply = QBCore.Functions.GetPlayerByPhone(CallData.TargetData.number)
    if not Ply then return end

    TriggerClientEvent('qb-phone:client:AnswerCall', Ply.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:SaveMetaData', function(MData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.SetMetaData("phone", MData)
end)