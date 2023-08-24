-- Functions

local function GetKeyByNumber(Number)
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                return k
            end
        end
    end
end

-- NUI Callback

RegisterNUICallback('PostAdvert', function(data, cb)
    local url

    if data.url and string.match(data.url, '[a-z]*://[^ >,;]*') then
        url = data.url
    end

    TriggerServerEvent('qb-phone:server:AddAdvert', data.message, url)
    cb("ok")
end)


RegisterNUICallback('FlagAdvert', function(data, cb)
    TriggerServerEvent('qb-phone:server:flagAdvert', data.number)
    cb("ok")
end)

RegisterNUICallback("DeleteAdvert", function(_, cb)
    TriggerServerEvent("qb-phone:server:DeleteAdvert")
    cb("ok")
end)

RegisterNUICallback('LoadAdverts', function(_, cb)
    cb(PhoneData.Adverts)
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local chat = data.number
    local ChatKey = GetKeyByNumber(chat)

    if PhoneData.Chats[ChatKey].Unread then
        local newAlerts = (Config.PhoneApplications['whatsapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end

    cb("ok")
end)

-- Events

RegisterNetEvent('qb-phone:client:UpdateAdverts', function(Adverts, LastAd, src)
    if not FullyLoaded or not Adverts then return end
    PhoneData.Adverts = Adverts

    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })

    if not LastAd or not src then return end
    if GetPlayerServerId(cache.ped) == src then return end

    TriggerEvent('qb-phone:client:CustomNotification',
        "Advertisement",
        "New Ad Posted: "..LastAd,
        "fas fa-ad",
        "#ff8f1a",
        4500
    )
end)