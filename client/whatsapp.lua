-- Functions

local function IsNumberInContacts(num)
    local retval = num
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
            break
        end
    end
    return retval
end

local function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] then
        if PhoneData.Chats[Number].messages then
            for key, chat in pairs(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

local function GetKeyByNumber(Number)
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                return k
            end
        end
    end
end

local function ReorganizeChats(key)
    local ReorganizedChats = {}
    ReorganizedChats[1] = PhoneData.Chats[key]
    for k, chat in pairs(PhoneData.Chats) do
        if k ~= key then
            ReorganizedChats[#ReorganizedChats+1] = chat
        end
    end
    PhoneData.Chats = ReorganizedChats
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
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType
    local NumberKey = GetKeyByNumber(ChatNumber)
    local ChatKey = GetKeyByDate(NumberKey, ChatDate)
    if PhoneData.Chats[NumberKey]then
        if not PhoneData.Chats[NumberKey].messages then
            PhoneData.Chats[NumberKey].messages = {}
        end

        if PhoneData.Chats[NumberKey].messages[ChatKey] then
            if ChatType == "message" then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                }
            elseif ChatType == "picture" then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                    message = "Photo",
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        url = data.url
                    },
                }
            end
            TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, false)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        else
            PhoneData.Chats[NumberKey].messages[#PhoneData.Chats[NumberKey].messages+1] = {
                date = ChatDate,
                messages = {},
            }
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == "message" then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                }
            elseif ChatType == "picture" then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                    message = "Photo",
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        url = data.url
                    },
                }
            end
            TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        end
    else
        PhoneData.Chats[#PhoneData.Chats+1] = {
            name = IsNumberInContacts(ChatNumber),
            number = ChatNumber,
            messages = {},
        }
        NumberKey = GetKeyByNumber(ChatNumber)
        PhoneData.Chats[NumberKey].messages[#PhoneData.Chats[NumberKey].messages+1] = {
            date = ChatDate,
            messages = {},
        }
        ChatKey = GetKeyByDate(NumberKey, ChatDate)
        if ChatType == "message" then
            PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                message = ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
            }
        elseif ChatType == "picture" then
            PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages+1] = {
                message = "Photo",
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    url = data.url
                },
            }
        end
        TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
        NumberKey = GetKeyByNumber(ChatNumber)
        ReorganizeChats(NumberKey)
    end

    cb("ok")
    SendNUIMessage({
        action = "UpdateChat",
        chatData = PhoneData.Chats[GetKeyByNumber(ChatNumber)],
        chatNumber = ChatNumber,
    })
end)

-- Events

RegisterNetEvent('qb-phone:client:UpdateMessages', function(ChatMessages, SenderNumber, New)
    local NumberKey = GetKeyByNumber(SenderNumber)

    if New then
	    PhoneData.Chats[#PhoneData.Chats+1] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = {},
        }

        NumberKey = GetKeyByNumber(SenderNumber)

        PhoneData.Chats[NumberKey] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = ChatMessages
        }

        if PhoneData.Chats[NumberKey].Unread then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Messages",
                        text = "New message: "..IsNumberInContacts(SenderNumber),
                        icon = "fas fa-comment",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Messages",
                        text = "Messaged yourself?",
                        icon = "fas fa-comment",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            SendNUIMessage({
                action = "UpdateChat",
                chatData = Chats[GetKeyByNumber(SenderNumber)],
                chatNumber = SenderNumber,
                Chats = PhoneData.Chats,
            })
        else
	    SendNUIMessage({
	        action = "PhoneNotification",
	        PhoneNotify = {
		    title = "Messages",
		    text = "New message: "..IsNumberInContacts(SenderNumber),
		    icon = "fas fa-comment",
		    color = "#25D366",
		    timeout = 3500,
	        },
	    })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
        end
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages

        if PhoneData.Chats[NumberKey].Unread then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Messages",
                        text = "New message: "..IsNumberInContacts(SenderNumber),
                        icon = "fas fa-comment",
                        color = "#25D366",
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "Messages",
                        text = "Messaged yourself?",
                        icon = "fas fa-comment",
                        color = "#25D366",
                        timeout = 4000,
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            SendNUIMessage({
                action = "UpdateChat",
                chatData = Chats[GetKeyByNumber(SenderNumber)],
                chatNumber = SenderNumber,
                Chats = PhoneData.Chats,
            })
        else
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Messages",
                    text = "New message: "..IsNumberInContacts(SenderNumber),
                    icon = "fas fa-comment",
                    color = "#25D366",
                    timeout = 3500,
                },
            })

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
        end
    end
end)