-- Functions

local function IsNumberInContacts(num)
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            return v.name
        end
    end
end

local function GetKeyByDate(Number, Date)
    if PhoneData.Chats[Number] and PhoneData.Chats[Number].messages then
        for key, chat in pairs(PhoneData.Chats[Number].messages) do
            if chat.date == Date then
                return key
            end
        end
    end
end

-- NUI Callback

RegisterNUICallback('GetWhatsappChat', function(data, cb)
    if PhoneData.Chats[data.phone] then
        cb(PhoneData.Chats[data.phone])
    else
        cb(false)
    end
end)

RegisterNUICallback('GetWhatsappChats', function(_, cb)
    cb(PhoneData.Chats)
end)

RegisterNUICallback('SendMessage', function(data, cb)
    print(json.encode(data))
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType
    local ChatKey = GetKeyByDate(data.ChatNumber, ChatDate)
    local name = IsNumberInContacts(SenderNumber) or SenderNumber

    if PhoneData.Chats[data.ChatNumber] then
        if not PhoneData.Chats[data.ChatNumber].messages then
            PhoneData.Chats[data.ChatNumber].messages = {}
        end

        if not PhoneData.Chats[data.ChatNumber].messages[ChatKey] then
            PhoneData.Chats[data.ChatNumber].messages[#PhoneData.Chats[data.ChatNumber].messages+1] = {
                date = ChatDate,
                messages = {},
            }
        end
    end

    if not ChatKey then
        if not PhoneData.Chats[data.ChatNumber] then
            PhoneData.Chats[data.ChatNumber] = {
                name = name,
                number = ChatNumber,
                messages = {},
            }
        end

        PhoneData.Chats[data.ChatNumber].messages[#PhoneData.Chats[data.ChatNumber].messages+1] = {
            date = ChatDate,
            messages = {},
        }

        ChatKey = GetKeyByDate(data.ChatNumber, ChatDate)
    end

    if ChatMessage then
        PhoneData.Chats[data.ChatNumber].messages[ChatKey].messages[#PhoneData.Chats[data.ChatNumber].messages[ChatKey].messages+1] = {
            message = ChatMessage,
            time = ChatTime,
            sender = PhoneData.PlayerData.citizenid,
            type = ChatType,
            data = {},
        }
    else
        PhoneData.Chats[data.ChatNumber].messages[ChatKey].messages[#PhoneData.Chats[data.ChatNumber].messages[ChatKey].messages+1] = {
            message = "Photo",
            time = ChatTime,
            sender = PhoneData.PlayerData.citizenid,
            type = ChatType,
            data = {
                url = data.url
            },
        }
    end

    TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[data.ChatNumber].messages, ChatNumber)
    SendNUIMessage({
        action = "UpdateChat",
        chatData = PhoneData.Chats[ChatNumber],
        chatNumber = ChatNumber,
    })


    cb("ok")
end)

-- Events

RegisterNetEvent('qb-phone:client:UpdateMessages', function(ChatMessages, SenderNumber, New)
    local NumberKey = tostring(SenderNumber)

    local name = IsNumberInContacts(SenderNumber) or SenderNumber
    print(json.encode(PhoneData.PlayerData))
    if SenderNumber == PhoneData.PlayerData.charinfo.phone then return end
    if not ChatMessages then return end
    if New == nil then return end

    if New then
        PhoneData.Chats[NumberKey] = {
            name = name,
            number = SenderNumber,
            messages = ChatMessages
        }
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages
    end

    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Messages",
            text = "New Message From: "..name,
            icon = "fas fa-comment",
            color = "#25D366",
            timeout = math.random(4000, 7500),
        },
    })

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "UpdateChat",
            chatData = PhoneData.Chats[NumberKey],
            chatNumber = NumberKey,
        })
    else
        Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
    end

    if not PhoneData.Chats[NumberKey].Unread then PhoneData.Chats[NumberKey].Unread = 1 end
    if PhoneData.Chats[NumberKey].Unread then PhoneData.Chats[NumberKey].Unread += 1 end
end)