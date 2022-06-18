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

-- should trigger these on serve rside instead of here but im lazy rn --

RegisterNetEvent('qb-phone:DebtSend', function()
    TriggerEvent('qb-phone:client:CustomNotification',
        "Debt",
        "Debt Successfully Sent!",
        "fas fa-dollar-sign",
        "#1DA1F2",
        4500
    )
end)

RegisterNetEvent('qb-phone:DebtRecieved', function()
    TriggerEvent('qb-phone:client:CustomNotification',
        "Debt",
        "Bill Recieved!",
        "fas fa-dollar-sign",
        "#1DA1F2",
        4500
    )
end)

RegisterNetEvent('qb-phone:DebtMail', function(name)
    TriggerEvent('qb-phone:client:CustomNotification',
        "Debt Recieved",
        "Payment Recieved From "..name,
        "fas fa-dollar-sign",
        "#1DA1F2",
        4500
    )
end)