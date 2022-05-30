local QBCore = exports['qb-core']:GetCoreObject()

-- NUI Callback

RegisterNUICallback('GetInvoices', function(data, cb)
    if PhoneData.Invoices ~= nil and next(PhoneData.Invoices) ~= nil then
        cb(PhoneData.Invoices)
    else
        cb(nil)
    end
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local senderCitizenId = data.senderCitizenId
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId

    QBCore.Functions.TriggerCallback('qb-phone:server:PayInvoice', function(CanPay, Invoices)
        if CanPay then PhoneData.Invoices = Invoices end
        cb(CanPay)
    end, society, amount, invoiceId, senderCitizenId)
    TriggerServerEvent('qb-phone:server:BillingEmail', data, true)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId

    QBCore.Functions.TriggerCallback('qb-phone:server:DeclineInvoice', function(CanPay, Invoices)
        PhoneData.Invoices = Invoices
        cb('ok')
    end, society, amount, invoiceId)
    TriggerServerEvent('qb-phone:server:BillingEmail', data, false)
end)

-- Events

RegisterNetEvent('qb-phone:client:BillingEmail', function(data, paid, name)
    if paid then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Billing Department',
            subject = 'Invoice Paid',
            message = 'Invoice Has Been Paid From '..name..' In The Amount Of $'..data.amount,
        })
    else
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Billing Department',
            subject = 'Invoice Declined',
            message = 'Invoice Has Been Declined From '..name..' In The Amount Of $'..data.amount,
        })
    end
end)