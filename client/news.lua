-- NUI Callback

RegisterNUICallback('Send_lsbn_ToChat', function(data)
    TriggerServerEvent('qb-phone:server:Send_lsbn_ToChat', data)
end)

RegisterNUICallback('GetLSBNchats', function(data)
    TriggerServerEvent('qb-phone:server:GetLSBNchats', data)
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