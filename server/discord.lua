local QBCore = exports['qb-core']:GetCoreObject()
ChatRooms = {}

-- Generates a random letter
--
-- @returns string
local charset = {}  do
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

-- Generates a random room code (5 characters long)
--
-- @returns string
local function generateRoomCode()
    return string.upper(charset[math.random(1, 26)] ..  charset[math.random(1, 26)] .. math.random(1, 9) .. math.random(1, 9) .. charset[math.random(1, 26)])
end

-- Find a room loaded in memory by room id or by room code.
-- @params int id
-- @params string code
--
-- @returns boolean | table
local function doesRoomExist(id, code)
    if id and not code then
        -- Find a room based on the room id
        for _, room in pairs(ChatRooms) do
            if room.id == id then
                return room
            end
        end
    elseif code and not id then
        -- Find a room based on the room code
        for _, room in pairs(ChatRooms) do
            if room.room_code == code then
                return room
            end
        end
    end

    return false
end

-- Check if a citizen id is a member of a room.
--
-- @param cid string
-- @param roomid int
--
-- @returns boolean
local function isMemberOfRoom(citizenid, roomID)
    for k, room in pairs(ChatRooms) do
        if room.id == roomID then
            memberList = json.decode(room.room_members)

            if next(memberList) then
                for _, memberData in pairs(memberList) do
                    if citizenid == memberData.cid  then
                        return true
                    end
                end
            else
                return false
            end
        end
    end
    return false
end

-- Check if a citizen id is an owner of a room.
--
-- @param cid string
-- @param roomid int
--
-- @returns boolean
local function isOwnerOfRoom(citizenid, roomID)
    for k, room in pairs(ChatRooms) do
        if (room.id == roomID) and (citizenid == room.room_owner_id) then
            return true
        end
    end
    return false
end

-- Check if a room is masked or not.
--
-- @param roomid int
--
-- @returns boolean
local function isRoomMasked(roomID)
    for k, room in pairs(ChatRooms) do
        if (room.id == roomID) and (room.is_masked) then
            return true
        end
    end

    return false
end

-- Check if the player's phone is hacked.
--
-- @param Player table (QBCore.Functions.GetPlayer())
--
-- @returns boolean
local function isPhoneHacked(Player)
    local phones = Player.Functions.GetItemsByName('phone')
    local isHacked = false

    if phones then
        for _, phone in pairs(phones) do
            if phone.info.hacked then
                isHacked = true
                break
            end
        end
    end

    return isHacked
end

local function escape_sqli(source)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return source:gsub("['\"]", replacements)
end


AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        Wait(1000)
        local chatrooms = MySQL.query.await("SELECT room_owner_id, room_name, is_masked FROM phone_chatrooms")

        if chatrooms[1] then
            for _, room in pairs(chatrooms) do
                local price = 15

                if room.is_masked then
                    price = 75
                end

                local Player = QBCore.Functions.GetPlayerByCitizenId(room.room_owner_id)

                if Player then
                    if Player.PlayerData.money.bank >= price then
                        Player.Functions.RemoveMoney('bank', price)
                        TriggerEvent('qb-phone:server:sendNewEventMail', room.room_owner_id, {
                            room.room_owner_id,
                            sender = "Discord Rooms",
                            subject = "Paid Subscription for (" .. room.room_name .. ") $" .. price,
                            message = "You have been billed for your ownership of the chat channel " .. room.room_name .. " for the amount of $" .. price .. ". If you no longer wish to continue paying, please deactivate the room in your phone app."
                        })
                    end
                end
            end
        end
    end
end)


QBCore.Functions.CreateCallback('qb-phone:server:GetGroupChatMessages', function(source, cb, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local permitted = true

    if isRoomMasked(roomID) then
        if not isPhoneHacked(Player) then
            permitted = false

            TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'Your phone is not secure enough to do this.')
            cb(false)
        end
    end

    if permitted then
        local messages = MySQL.query.await("SELECT * FROM phone_chatroom_messages WHERE room_id=@roomID ORDER BY created DESC LIMIT 40", {['@roomID'] = roomID})

        if messages[1] then
            cb(messages)
        else
            cb(false)
        end
    end

end)

QBCore.Functions.CreateCallback('qb-phone:server:SearchGroupChatMessages', function(source, cb, roomID, searchTerm)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local search = escape_sqli(searchTerm)
    local permitted = true

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) or isMemberOfRoom(Player.PlayerData.citizenid, roomID) then
        if isRoomMasked(roomID) then
            if not isPhoneHacked(Player) then
                permitted = false

                TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'Your phone is not secure enough to do this.')
                cb(false)
            end
        elseif(permitted) then
            local messages = MySQL.query.await("SELECT * FROM phone_chatroom_messages WHERE message LIKE ? AND room_id=?", {
                "%" .. search .. "%",
                roomID
            })

            if messages[1] then
                cb(messages)
            else
                cb(false)
            end
        end
    else
        TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'You must be a member or room owner to search.')
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetPinnedMessages', function(source, cb, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) or isMemberOfRoom(Player.PlayerData.citizenid, roomID) then
        local messages = MySQL.query.await("SELECT * FROM phone_chatroom_messages WHERE room_id=? AND is_pinned=1", {roomID})

        if messages[1] then
            cb(messages)
        else
            cb(false)
        end
    else
        TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'You must be a member or room owner to fetch that.')
        cb(false)
    end
end)


QBCore.Functions.CreateCallback('qb-phone:server:TryPinCode', function(source, cb, pinCode, roomID)
    local room = MySQL.scalar.await("SELECT 1 FROM phone_chatrooms WHERE id=@roomID AND room_pin=@roomPin", {['@roomID'] = roomID, ['roomPin'] = pinCode})

    cb(room)
end)

QBCore.Functions.CreateCallback('qb-phone:server:IsRoomOwner', function(source, cb, roomID)
    local Player = QBCore.Functions.GetPlayer(source)
    local room = MySQL.scalar.await("SELECT 1 FROM phone_chatrooms WHERE id=@roomID AND room_owner_id=@owner", {['@roomID'] = roomID, ['owner'] = Player.PlayerData.citizenid})

    if room then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('qb-phone:server:SendGroupChatMessage', function(messageData, systemMessage, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local permitted = true
    if messageData and not systemMessage then
        if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) or isMemberOfRoom(Player.PlayerData.citizenid, roomID) then
            if isRoomMasked(roomID) then
                if not isPhoneHacked(Player) then
                    permitted = false
                    TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'Your phone is not secure enough to do this.')
                    cb(false)
                else
                    local message = escape_sqli(messageData.message)
                    local msg = MySQL.insert.await("INSERT INTO phone_chatroom_messages (room_id, member_id, message, member_name) VALUES (?,?,?,?)", {
                        messageData.room_id,
                        Player.PlayerData.citizenid,
                        message,
                        messageData.memberName
                    })
                    messageData.messageID = msg
                    TriggerClientEvent('qb-phone:client:RefreshGroupChat', -1, src, messageData)
                    TriggerEvent("qb-log:server:CreateLog", "phone-chatrooms", "Message Posted (room: ".. messageData.room_id .. ", from: ".. Player.PlayerData.citizenid ..")", "blue", messageData.message)
                end
            elseif(permitted) then
                local message = escape_sqli(messageData.message)
                local msg = MySQL.insert.await("INSERT INTO phone_chatroom_messages (room_id, member_id, message, member_name) VALUES (?,?,?,?)", {
                    messageData.room_id,
                    Player.PlayerData.citizenid,
                    message,
                    messageData.memberName
                })
                messageData.messageID = msg
                TriggerClientEvent('qb-phone:client:RefreshGroupChat', -1, src, messageData)
                TriggerEvent("qb-log:server:CreateLog", "phone-chatrooms", "Message Posted (room: ".. messageData.room_id .. ", from: ".. Player.PlayerData.citizenid ..")", "blue", messageData.message)
            end
        else
            TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'You must be a member or room owner to send messages.')
        end
    else
        local message = escape_sqli(systemMessage.message)

        MySQL.insert("INSERT INTO phone_chatroom_messages (room_id, member_id, message, member_name) VALUES (?,?,?,?)", {
            systemMessage.room_id,
            systemMessage.messageType,
            message,
            systemMessage.name
        })
        TriggerClientEvent('qb-phone:client:RefreshGroupChat', -1, src, systemMessage)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:JoinGroupChat', function(source, cb, updatedRooms, roomID, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local permitted = true
    if isRoomMasked(roomID) then
        if not isPhoneHacked then
            permitted = false

            TriggerClientEvent('qb-phone:client:notification', src, 'Discord', 'Your phone is not secure enough to join this room.')
            cb(false)
        end
    end
    if permitted and not isMemberOfRoom(Player.PlayerData.citizenid, roomID) then
        ChatRooms = updatedRooms
        local members
        for k, v in pairs(ChatRooms) do
            if(v.id == roomID) then
                members = v.room_members
                break
            end
        end
        if members then
            MySQL.update("UPDATE phone_chatrooms SET room_members = ? WHERE id = ?", {
                members,
                roomID
            })
        end
        TriggerClientEvent('qb-phone:client:RefreshChatRooms', -1, ChatRooms)
        cb(true)
    end
end)

RegisterNetEvent('qb-phone:server:LeaveGroupChat', function(updatedRooms, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local members = {}

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) or isMemberOfRoom(Player.PlayerData.citizenid, roomID) then
        ChatRooms = updatedRooms

        for k, v in pairs(ChatRooms) do
            if(v.id == roomID) then
                members = v.room_members
                break
            end
        end

        if members then
            MySQL.update("UPDATE phone_chatrooms SET room_members = ? WHERE id = ?", {
                members,
                roomID
            })
        end

        TriggerClientEvent('qb-phone:client:RefreshChatRooms', -1, ChatRooms)
    end
end)

RegisterNetEvent('qb-phone:server:ChangeRoomPin', function(updatedRooms, roomID, pin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) then
        MySQL.update("UPDATE phone_chatrooms SET room_pin = ? WHERE id = ?", {
            pin,
            roomID
        })

        ChatRooms = updatedRooms
        TriggerClientEvent('qb-phone:client:RefreshChatRooms', -1, ChatRooms)
    end
end)

RegisterNetEvent('qb-phone:server:DeactivateRoom', function(updatedRooms, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) then
        MySQL.query("DELETE FROM phone_chatrooms WHERE id = ?", {
            roomID
        })

        ChatRooms = updatedRooms
        TriggerClientEvent('qb-phone:client:RefreshChatRooms', -1, ChatRooms)
    end
end)

RegisterNetEvent('qb-phone:server:CreateRoom', function(source, roomData, isSecured)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local roomCode = generateRoomCode()
    local protected = false

    if isSecured then
        roomData.is_masked = true
    end

    if roomData.room_pin and roomData.room_pin ~= '' then
        protected = true
    end

    local roomID = MySQL.insert.await("INSERT INTO phone_chatrooms (room_code, room_name, room_owner_id, room_owner_name, room_pin, is_masked) VALUES(?, ?, ?, ?, ?, ?)", {
        roomCode,
        roomData.room_name,
        Player.PlayerData.citizenid,
        roomData.room_owner_name,
        roomData.room_pin or "",
        roomData.is_masked or false,
    })

    local ChatRoom = {
        id = roomID,
        room_code = roomCode,
        room_name  = roomData.room_name,
        room_owner_id = Player.PlayerData.citizenid,
        room_owner_name = roomData.room_owner_name,
        is_masked = roomData.is_masked or false,
        room_members = '{}',
        protected = protected
    }

    ChatRooms[#ChatRooms + 1] = ChatRoom

    TriggerClientEvent('qb-phone:client:RefreshChatRooms', -1, ChatRooms)
    TriggerEvent("qb-log:server:CreateLog", "phone-chatrooms", "Channel Created:  ".. roomData.room_name .."(id: ".. roomID.. ", by: "..Player.PlayerData.citizenid..")", "blue")
end)

QBCore.Functions.CreateCallback('qb-phone:server:PurchaseRoom', function(source, cb, price)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
		TriggerClientEvent('QBCore:Notify', source, "You have purchased the channel.", 'success')
		cb(true)
	else
		TriggerClientEvent('QBCore:Notify', source, "You do not have enough money to buy the room.", 'success')
		cb(false)
	end
end)

RegisterNetEvent('qb-phone:server:ToggleMessagePin', function(messageID, roomID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if isOwnerOfRoom(Player.PlayerData.citizenid, roomID) then
        local pinnedStatus = MySQL.query.await("SELECT is_pinned FROM phone_chatroom_messages WHERE id = ?", {messageID})

        if pinnedStatus[1] then
            MySQL.update("UPDATE phone_chatroom_messages SET is_pinned = NOT is_pinned WHERE id = ?", {messageID})
        end
    end
end)