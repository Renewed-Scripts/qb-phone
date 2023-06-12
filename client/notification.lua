local Result = nil
local test = false

-- NUI Callbacks

RegisterNUICallback('AcceptNotification', function()
    Result = true
    Wait(100)
    test = false
    return Result
end)

RegisterNUICallback('DenyNotification', function()
    Result = false
    Wait(100)
    test = false
    return Result
end)

-- Events

RegisterNetEvent("qb-phone:client:CustomNotification", function(title, text, icon, color, timeout) -- Send a PhoneNotification to the phone from anywhere
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = title,
            text = text,
            icon = icon,
            color = color,
            timeout = timeout,
        },
    })
end)

-- ex. local success = exports['qb-phone']:PhoneNotification("PING", info.Name..' Incoming Ping', 'fas fa-map-pin', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')

RegisterNetEvent("qb-phone:client:CustomNotification2", function(title, text, icon, color, timeout, accept, deny) -- Send a PhoneNotification to the phone from anywhere
    SendNUIMessage({
        action = "PhoneNotificationCustom",
        PhoneNotify = {
            title = title,
            text = text,
            icon = icon,
            color = color,
            timeout = timeout,
            accept = accept,
            deny = deny,
        },
    })
end)
-- Functions

local function PhoneNotification(title, text, icon, color, timeout, accept, deny)
    Result = nil
    test = true
    SendNUIMessage({
        action = "PhoneNotificationCustom",
        PhoneNotify = {
            title = title,
            text = text,
            icon = icon,
            color = color,
            timeout = timeout,
            accept = accept,
            deny = deny,
        },
    })
    while test do
        Wait(5)
    end
    Wait(100)
    return Result
end exports("PhoneNotification", PhoneNotification)
