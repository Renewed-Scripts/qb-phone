local QBCore = exports['qb-core']:GetCoreObject()

local invoices = {}
local checked = false -- makes a database search and double ups as a Ping check to make sure the client gets the data and can handle it before it shows the UI

local function GetInvoiceFromID(id)
    for k, v in pairs(invoices) do
        if v.id == id then
            return k
        end
    end
end

-- NUI Callback

RegisterNUICallback('GetInvoices', function(_, cb)
    if not checked then
        QBCore.Functions.TriggerCallback('qb-phone:server:GetInvoices', function(Invoices)
            invoices = Invoices
            checked = true
        end)
    end

    while not checked do Wait(25) end
    cb(invoices)
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local senderCitizenId = data.senderCitizenId
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId

    TriggerServerEvent('qb-phone:server:PayMyInvoice', society, amount, invoiceId, senderCitizenId)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId
    TriggerServerEvent('qb-phone:server:DeclineMyInvoice', society, amount, invoiceId)
end)

-- Events

RegisterNetEvent('qb-phone:client:AcceptorDenyInvoice', function(id, name, job, senderCID, amount, resource)
    invoices[#invoices+1] = {
        id = id,
        citizenid = QBCore.Functions.GetPlayerData().citizenid,
        sender = name,
        society = job,
        sendercitizenid = senderCID,
        amount = amount
    }

    local success = exports['qb-phone']:PhoneNotification("Invoice", 'Invoice of $'..amount.." Sent from "..name, 'fas fa-file-invoice-dollar', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        TriggerServerEvent('qb-phone:server:PayMyInvoice', job, amount, id, senderCID, resource)
    else
        TriggerServerEvent('qb-phone:server:DeclineMyInvoice', job, amount, id, senderCID, resource)
    end
end)

RegisterNetEvent('qb-phone:client:RemoveInvoiceFromTable', function(id)
    local table = GetInvoiceFromID(id)
    if table then
        invoices[table] = nil
    end
end)

RegisterCommand('invoice', function()
    TriggerServerEvent('qb-phone:server:CreateInvoice', 2, 2, 1000)
end, false)
