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


RegisterNetEvent('qb-phone:DebtSend', function()
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Debt",
            text = "Debt Successfully Sent!",
            icon = "fas fa-dollar-sign",
            color = "#1DA1F2",
        },
    })
end)

RegisterNetEvent('qb-phone:DebtRecieved', function()
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Debt",
            text = "Bill Recieved!",
            icon = "fas fa-dollar-sign",
            color = "#1DA1F2",
        },
    })
end)

RegisterNetEvent('qb-phone:DebtMail', function(name)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Debt Recieved",
            text = "Payment Recieved From "..name,
            icon = "fas fa-dollar-sign",
            color = "#1DA1F2",
        },
    })
end)