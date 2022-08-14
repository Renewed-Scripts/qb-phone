-- NUI Callback

-- Used for assts and to pay off the entire LOAN
RegisterNUICallback('SendAllPayment', function(data, cb)
    -- All your cracked code here brains here

    TriggerServerEvent('Renewed-Debts:server:PayFull', tonumber(data.id))

    cb("ok")
end)

RegisterNUICallback('SendMinimumPayment', function(data, cb)
    -- All your cracked code here brains here
    TriggerServerEvent('Renewed-Debts:server:PayPartial', tonumber(data.id))
    cb("ok")
end)


RegisterNUICallback('GetPlayersDebt', function(_, cb)
    cb(exports['qb-finances']:getDebt())
end)


-- refresh the shit

RegisterNetEvent('qb-phone:client:refreshDebt', function()
    SendNUIMessage({
        action = "refreshDebt",
        debt = exports['qb-finances']:getDebt(),
    })
end)