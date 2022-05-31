-- NUI Callback

RegisterNUICallback('Send_lsbn_ToChat', function(data, cb)
    TriggerServerEvent('qb-phone:server:Send_lsbn_ToChat', data)
    cb("ok")
end)

RegisterNUICallback('GetLSBNchats', function(data, cb)
    TriggerServerEvent('qb-phone:server:GetLSBNchats', data)
    cb("ok")
end)

-- Events

RegisterNetEvent('qb-phone:LSBN-reafy-for-add', function(data, toggle, text)
    if toggle then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "LSBN",
                text = text,
                icon = "fas fa-bullhorn",
                color = "#d8e212",
                timeout = 1000,
            },
        })
    end

    SendNUIMessage({
        action = "AddNews",
        data = data,
    })
end)