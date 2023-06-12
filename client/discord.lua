-- Find a room loaded in memory by room id or by room code.
-- @params int id
-- @params string code
--
-- @returns boolean | table
local function doesRoomExist(id, code)
    if id and not code then
        -- Find a room based on the room id
        for _, room in pairs(PhoneData.ChatRooms) do
            if room.id == id then
                return room
            end
        end
    elseif code and not id then
        -- Find a room based on the room code
        for _, room in pairs(PhoneData.ChatRooms) do
            if room.room_code == code then
                return room
            end
        end
    end

    return false
end

-- Checks if a citizen id is a member of a room.
-- @params string citizenid
-- @params int roomID
--
-- @returns boolean
local function isMemberOfRoom(citizenid, roomID)
    for _, room in pairs(PhoneData.ChatRooms) do
        if room.id == roomID then
            local memberList = json.decode(room.room_members)

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

local function getChatRoomData(id)
    for _, room in pairs(PhoneData.ChatRooms) do
        if room.id == tonumber(id) then
            return room
        end
    end
end

local function slugCase(s)
    return string.lower(s):gsub(" ", "-")
end

RegisterNetEvent('qb-phone:client:notification', function(app, message)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = app,
            text =message,
            icon = "fab fa-discord",
            color = "rgb(183 183 181)",
            timeout = 5500
        },
    })
end)

RegisterNetEvent('qb-phone:client:RefreshChatRooms', function(ChatRooms)
    PhoneData.ChatRooms = ChatRooms
    SendNUIMessage({action = "RefreshChatRooms", Rooms = PhoneData.ChatRooms})
end)

RegisterNetEvent('qb-phone:client:RefreshGroupChat', function(src, message)
    SendNUIMessage({action = "RefreshGroupChat", messageData  = message})
    local MyPlayerId = PhoneData.PlayerData.source

    if src ~= MyPlayerId then
        if isMemberOfRoom(PhoneData.PlayerData.citizenid, message.room_id) then
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "New post in #" .. slugCase(getChatRoomData(message.room_id).room_name),
                    text =message.message,
                    icon = "fab fa-discord",
                    color = "rgb(183 183 181)",
                    timeout = 5500
                },
            })
        end
    end
end)

RegisterNUICallback('GetGroupChatMessages', function(data, cb)
    local Player = PhoneData.PlayerData.citizenid

    for _, room in pairs(PhoneData.ChatRooms) do
        if room.id == data.roomID then
            local memberList = json.decode(room.room_members)

            if not room.room_pin then
                lib.callback('qb-phone:server:GetGroupChatMessages', false, function(messages)
                    cb(messages)
                end, data.roomID)
            else
                if next(memberList) then
                    for _, memberData in pairs(memberList) do
                        if Player == memberData.cid or Player == room.room_owner_id then
                            lib.callback('qb-phone:server:GetGroupChatMessages', false, function(messages)
                                cb(messages)
                            end, data.roomID)
                            break
                        end
                    end
                else
                    if Player == room.room_owner_id then
                        lib.callback('qb-phone:server:GetGroupChatMessages', false, function(messages)
                            cb(messages)
                        end, data.roomID)
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('SearchGroupChatMessages', function(data, cb)
    local Player = PhoneData.PlayerData.citizenid
    local Room   = data.roomID
    local SearchTerm = data.searchTerm

    for _, room in pairs(PhoneData.ChatRooms) do
        if(room.id == Room) then
            local memberList = json.decode(room.room_members)
            if next(memberList) then
                for _, memberData in pairs(memberList) do
                    if Player == memberData.cid or Player == room.room_owner_id then
                        lib.callback('qb-phone:server:SearchGroupChatMessages', false, function(messages)
                            cb(messages)
                        end, Room, SearchTerm)
                        break
                    end
                end
            else
                if Player == room.room_owner_id then
                    lib.callback('qb-phone:server:SearchGroupChatMessages', false, function(messages)
                        cb(messages)
                    end, Room, SearchTerm)
                end
            end
        end
    end
end)

RegisterNUICallback('GetPinnedMessages', function(data, cb)
    local Player = PhoneData.PlayerData.citizenid
    local Room   = data.roomID

    for _, room in pairs(PhoneData.ChatRooms) do
        if(room.id == Room) then
            local memberList = json.decode(room.room_members)

            if next(memberList) then
                -- luacheck: ignore
                for _, memberData in pairs(memberList) do
                    if Player == memberData.cid or Player == room.room_owner_id then
                        lib.callback('qb-phone:server:GetPinnedMessages', false, function(messages)
                            cb(messages)
                        end, Room)
                    end
                    break
                end
            else
                if Player == room.room_owner_id then
                    lib.callback('qb-phone:server:GetPinnedMessages', false, function(messages)
                        cb(messages)
                    end, Room)
                end
            end
        end
    end
end)

RegisterNUICallback('SendGroupChatMessage', function(data, cb)
    local Player = PhoneData.PlayerData.citizenid
    local Message = {
        memberName = PhoneData.PlayerData.charinfo.firstname .. ' ' ..  PhoneData.PlayerData.charinfo.lastname,
        message = data.message,
        room_id = data.roomID
    }

    for _, room in pairs(PhoneData.ChatRooms) do
        if(room.id == Message.room_id) then
            local memberList = json.decode(room.room_members)

            if next(memberList) then
                for _, memberData in pairs(memberList) do
                    if Player == memberData.cid or Player == room.room_owner_id then
                        TriggerServerEvent("qb-phone:server:SendGroupChatMessage", Message, nil, data.roomID)

                        cb(true)
                        break
                    end
                end
            else
                if Player == room.room_owner_id then
                    TriggerServerEvent("qb-phone:server:SendGroupChatMessage", Message, nil, data.roomID)
                    cb(true)
                end
            end
        end
    end
end)

RegisterNUICallback('JoinGroupChat', function(data, cb)
    local roomID = data.roomID
    local roomPin = data.roomPin
    local Player = PhoneData.PlayerData.citizenid
    local room = doesRoomExist(roomID)
    local members, member
    local playerName = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname

    if not room then
        cb(false)
    else
        if isMemberOfRoom(Player, roomID) then
            cb(false)
        else
            if roomPin then
                lib.callback('qb-phone:server:TryPinCode', false, function(result)
                    if result then
                        members = json.decode(room.room_members)

                        if next(members) then
                            member  = {}
                            member[Player] = {
                                cid = PhoneData.PlayerData.citizenid,
                                name = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname,
                                notify = true
                            }

                            for k, v in pairs(member) do
                                members[k] = v
                            end

                            for k, room2 in pairs(PhoneData.ChatRooms) do
                                if(room2.id == roomID) then
                                    PhoneData.ChatRooms[k].room_members = json.encode(members)
                                    break
                                end
                            end
                            lib.callback("qb-phone:server:JoinGroupChat", false, function(success)
                                if success then
                                    TriggerServerEvent("qb-phone:server:SendGroupChatMessage", nil, {
                                        room_id = roomID,
                                        messageType = "SYSTEM",
                                        message = playerName .. " has joined the channel, welcome!",
                                        roomID = data.roomID,
                                        name = "Member Activity"
                                    })
                                    cb(true)
                                end
                            end, PhoneData.ChatRooms, roomID)
                        else
                            member = {}
                            member[Player] = {
                                cid = PhoneData.PlayerData.citizenid,
                                name = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname,
                                notify = true
                            }
                            for k, room2 in pairs(PhoneData.ChatRooms) do
                                if(room2.id == roomID) then
                                    PhoneData.ChatRooms[k].room_members = json.encode(member)
                                    break
                                end
                            end
                            lib.callback("qb-phone:server:JoinGroupChat", false, function(success)
                                if success then
                                    TriggerServerEvent("qb-phone:server:SendGroupChatMessage", nil, {
                                        room_id = roomID,
                                        messageType = "SYSTEM",
                                        message = playerName .. " has joined the channel, welcome!",
                                        roomID = data.roomID,
                                        name = "Member Activity"
                                    })
                                    cb(true)
                                end
                            end, PhoneData.ChatRooms, roomID)
                        end
                    else
                        cb(false)
                    end
                end, roomPin, roomID)
            else
                members = json.decode(room.room_members)

                if next(members) then
                    member  = {}
                    member[Player] = {
                        cid = PhoneData.PlayerData.citizenid,
                        name = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname,
                        notify = true
                    }

                    for k, v in pairs(member) do
                        members[k] = v
                    end

                    for k, room2 in pairs(PhoneData.ChatRooms) do
                        if(room2.id == roomID) then
                            PhoneData.ChatRooms[k].room_members = json.encode(members)
                            break
                        end
                    end

                    lib.callback("qb-phone:server:JoinGroupChat", false, function(success)
                        if success then
                            TriggerServerEvent("qb-phone:server:SendGroupChatMessage", nil, {
                                room_id = roomID,
                                messageType = "SYSTEM",
                                message = playerName .. " has joined the channel, welcome!",
                                roomID = data.roomID,
                                name = "Member Activity"
                            })
                            cb(true)
                        end
                    end, PhoneData.ChatRooms, roomID)
                else
                    member = {}

                    member[Player] = {
                        cid = PhoneData.PlayerData.citizenid,
                        name = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname,
                        notify = true
                    }

                    for k, room2 in pairs(PhoneData.ChatRooms) do
                        if(room2.id == roomID) then
                            PhoneData.ChatRooms[k].room_members = json.encode(member)
                            break
                        end
                    end

                    lib.callback("qb-phone:server:JoinGroupChat", false, function(success)
                        if success then
                            TriggerServerEvent("qb-phone:server:SendGroupChatMessage", nil, {
                                room_id = roomID,
                                messageType = "SYSTEM",
                                message = playerName .. " has joined the channel, welcome!",
                                roomID = data.roomID,
                                name = "Member Activity"
                            })

                            cb(true)
                        end
                    end, PhoneData.ChatRooms, roomID)
                end
            end
        end
    end
end)

RegisterNUICallback('LeaveGroupChat', function(data, cb)
    local roomID = tonumber(data.roomID)
    local Player = data.citizenid or PhoneData.PlayerData.citizenid
    local room   = doesRoomExist(roomID)
    local members, memberName

    if not room then
        cb(false)
    else
        if isMemberOfRoom(Player, roomID) then
            members = json.decode(room.room_members)
            for k, v in pairs(members) do
                if(k == data.citizenid) then
                    memberName = v.name
                    members[k] = nil
                end
            end

            for k, v in pairs(PhoneData.ChatRooms) do
                if(v.id == roomID) then
                    PhoneData.ChatRooms[k].room_members = json.encode(members)
                    break
                end
            end

            TriggerServerEvent("qb-phone:server:SendGroupChatMessage", nil, {
                room_id = roomID,
                messageType = "SYSTEM",
                message = memberName .. " has left the channel, goodbye lad.",
                roomID = data.roomID,
                name = "Member Activity"
            })

            TriggerServerEvent('qb-phone:server:LeaveGroupChat', PhoneData.ChatRooms, roomID)
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterNUICallback('ChangeRoomPin', function(data, cb)
    local roomID = data.roomID
    local room   = doesRoomExist(roomID)
    local pin    = data.pinCode

    if not room then
        cb(false)
    else
        if pin then
            lib.callback('qb-phone:server:IsRoomOwner', false, function(isOwner)
                if isOwner then
                    for k, v in pairs(PhoneData.ChatRooms) do
                        if(v.id == roomID) then
                            if pin == '' then
                                PhoneData.ChatRooms[k].protected = false
                            else
                                PhoneData.ChatRooms[k].protected = true
                            end
                            break
                        end
                    end

                    TriggerServerEvent('qb-phone:server:ChangeRoomPin', PhoneData.ChatRooms, roomID, pin)
                    cb(true)
                else
                    cb(false)
                end
            end, roomID)
        end
    end
end)

RegisterNUICallback('GetChatRooms', function(_, cb)
    cb(PhoneData.ChatRooms)
end)

RegisterNUICallback('DeactivateRoom', function(data, cb)
    for k, room in pairs(PhoneData.ChatRooms) do
        if room.id == data.roomID then
            lib.callback('qb-phone:server:IsRoomOwner', false, function(isOwner)
                if isOwner then
                    PhoneData.ChatRooms[k] = nil
                    TriggerServerEvent('qb-phone:server:DeactivateRoom', PhoneData.ChatRooms, data.roomID)
                    cb(true)
                else
                    cb(false)
                end
            end, data.roomID)
            break
        end
    end
end)

RegisterNUICallback('ToggleMessagePin', function(data, cb)
    local roomID = tonumber(data.roomID)
    local messageID = tonumber(data.messageID)

    for _, room in pairs(PhoneData.ChatRooms) do
        if room.id == roomID then
            lib.callback('qb-phone:server:IsRoomOwner', false, function(isOwner)
                if isOwner then
                    TriggerServerEvent('qb-phone:server:ToggleMessagePin', messageID, roomID)
                    cb(true)
                else
                    cb(false)
                end
            end, data.roomID)
            break
        end
    end
end)

RegisterNUICallback('CreateDiscordRoom', function(data, cb)
    local roomData = {
        room_owner_name = PhoneData.PlayerData.charinfo.firstname .. " " .. PhoneData.PlayerData.charinfo.lastname,
        room_name = data.name,
        room_pin = data.pass and data.pass ~= '' and data.pass or false,
    }

    lib.callback("qb-phone:server:PurchaseRoom", false, function(status)
        cb(status)
    end, 250, roomData)
end)