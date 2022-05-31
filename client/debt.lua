local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('SendBillForPlayer_debt', function(data, cb)
    TriggerServerEvent('qb-phone:server:SendBillForPlayer_debt', data)
    cb("ok")
end)

RegisterNUICallback('GetHasBills_debt', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetHasBills_debt', function(Has)
        cb(Has)
    end)
end)

RegisterNUICallback('debit_AcceptBillForPay', function(data, cb)
    TriggerServerEvent('qb-phone:server:debit_AcceptBillForPay', data)
    cb("ok")
end)

RegisterNetEvent('qb-phone:RefreshPhoneForDebt', function()
    SendNUIMessage({
        action = "DebtRefresh",
    })
end)