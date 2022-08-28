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
    local debtData = Config.RenewedFinances and exports['qb-finances']:getDebt() or {}
    cb(debtData)
end)


-- refresh the shit

RegisterNetEvent('qb-phone:client:refreshDebt', function()
    local debtData = Config.RenewedFinances and exports['qb-finances']:getDebt() or {}
    SendNUIMessage({
        action = "refreshDebt",
        debt = debtData,
    })
end)