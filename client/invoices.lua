local QBCore = exports['qb-core']:GetCoreObject()

local function GetInvoiceFromID(id)
    for k, v in pairs(PhoneData.Invoices) do
        if v.id == id then
            return k
        end
    end
end

-- NUI Callback

RegisterNUICallback('GetInvoices', function(_, cb)
    cb(PhoneData.Invoices)
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
    PhoneData.Invoices[#PhoneData.Invoices+1] = {
        id = id,
        citizenid = QBCore.Functions.GetPlayerData().citizenid,
        sender = name,
        society = job,
        sendercitizenid = senderCID,
        amount = amount
    }

    local success = exports['qb-phone']:PhoneNotification("Invoice", 'Invoice of $'..amount.." Sent from "..name, 'fas fa-file-invoice-dollar', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        local table = GetInvoiceFromID(id)
        if table then
            TriggerServerEvent('qb-phone:server:PayMyInvoice', job, amount, id, senderCID, resource)
        end
    else
        local table = GetInvoiceFromID(id)
        if table then
            TriggerServerEvent('qb-phone:server:DeclineMyInvoice', job, amount, id, senderCID, resource)
        end
    end
end)

RegisterNetEvent('qb-phone:client:RemoveInvoiceFromTable', function(id)
    local table = GetInvoiceFromID(id)
    if table then
        PhoneData.Invoices[table] = nil

        SendNUIMessage({
            action = "refreshInvoice",
            invoices = PhoneData.Invoices,
        })
    end
end)

RegisterCommand('invoice', function()
    TriggerServerEvent('qb-phone:server:CreateInvoice', 1, 1, 1000)
end, false)
