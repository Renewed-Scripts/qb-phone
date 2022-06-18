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
        TriggerEvent('qb-phone:client:CustomNotification',
            "LSBN",
            text,
            "fas fa-bullhorn",
            "#d8e212",
            1500
        )
    end

    SendNUIMessage({
        action = "AddNews",
        data = data,
    })
end)