local QBCore = exports['qb-core']:GetCoreObject()


local Debts = {}

local function isAuthorized(job)
    return Config.DebtJobs[job]
end

local function DeleteCachedDebt(citizenid, id)
    for k, v in pairs(Debts[citizenid]) do
        if v.id == id then
            Debts[citizenid][k] = nil
            return
        end
    end
end

RegisterNetEvent('qb-phone:server:SendBillForPlayer_debt', function(data)
    local src = source
    local biller = QBCore.Functions.GetPlayer(src)
    local billed = QBCore.Functions.GetPlayer(tonumber(data.ID))
    local amount = tonumber(data.Amount)

    if not biller or not billed or not amount or amount < 0 then return TriggerClientEvent('QBCore:Notify', src, 'Error 404', "error") end
    if not isAuthorized(biller.PlayerData.job.name) then return TriggerClientEvent('QBCore:Notify', src, 'You do not have access to do this', "error") end
    if Config.DebtJobs[biller.PlayerData.job.name] and not biller.PlayerData.job.onduty then return TriggerClientEvent('QBCore:Notify', src, 'You must be on duty to do this...', "error") end
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(billed.PlayerData.source))) > 10 then return TriggerClientEvent('QBCore:Notify', src, 'You are too far away from the player', "error") end

    TriggerClientEvent('qb-phone:DebtSend', src)

    MySQL.insert('INSERT INTO phone_debt (citizenid, amount,  sender, sendercitizenid, reason) VALUES (?, ?, ?, ?, ?)', {
        billed.PlayerData.citizenid,
        amount,
        biller.PlayerData.charinfo.firstname.." "..biller.PlayerData.charinfo.lastname,
        biller.PlayerData.citizenid,
        data.Reason
    }, function(id)
        if id then
            if not Debts[billed.PlayerData.citizenid] then Debts[billed.PlayerData.citizenid] = {} end
            Debts[billed.PlayerData.citizenid][#Debts[billed.PlayerData.citizenid]+1] = {
                id = id,
                citizenid = billed.PlayerData.citizenid,
                amount = amount,
                sender = biller.PlayerData.charinfo.firstname.." "..biller.PlayerData.charinfo.lastname,
                sendercitizenid = biller.PlayerData.citizenid,
                reason = data.Reason,
            }

            TriggerClientEvent('qb-phone:DebtRecieved', billed.PlayerData.source)
            TriggerClientEvent('qb-phone:RefreshPhoneForDebt', billed.PlayerData.source)
        end
    end)
end)

RegisterNetEvent('qb-phone:server:debit_AcceptBillForPay', function(data)
    local src = source -- src is the player who paid the bill
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayerByCitizenId(data.CSN) -- this is the sender for the bill
    local ID = tonumber(data.id)
    local Amount = tonumber(data.Amount)

    if Ply.Functions.RemoveMoney('bank', Amount, tostring(data.Reason)) then -- Makes sure the money is removed!
        exports.oxmysql:execute('DELETE FROM phone_debt WHERE id = ?', {ID})
        TriggerClientEvent('qb-phone:RefreshPhoneForDebt', src)
        DeleteCachedDebt(Ply.PlayerData.citizenid, ID)


        if OtherPly and isAuthorized(OtherPly.PlayerData.job.name) and Config.DebtJobs[OtherPly.PlayerData.job.name].comissionEnabled then
            local comission = Amount * Config.DebtJobs[OtherPly.PlayerData.job.name].comission
            Amount -= comission
            TriggerClientEvent("QBCore:Notify", OtherPly.PlayerData.source, 'You received $'..comission..' in commission!', "primary")

            OtherPly.Functions.AddMoney('bank', comission, OtherPly.PlayerData.job.name.." Debt Commission | $"..Amount.." Paid By: "..Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)
            TriggerClientEvent('qb-phone:DebtMail', OtherPly.PlayerData.source, Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)

            if Config.ManagementType == "simple-banking" then
                TriggerEvent('qb-banking:society:server:DepositMoney', src, Amount, OtherPly.PlayerData.job.name)
            elseif Config.ManagementType == "qb-management" then
                exports['qb-management']:AddMoney(OtherPly.PlayerData.job.name, Amount)
            end
        elseif isAuthorized(jobData.name) and Config.DebtJobs[jobData.name].comissionEnabled then
            local jobData = MySQL.query.await('SELECT job FROM players WHERE citizenid = ?', {data.CSN})
            if jobData[1] then
                jobData = json.decode(jobData[1].job)
                local comission = Amount * Config.DebtJobs[jobData.name].comission
                Amount -= comission
                if Config.ManagementType == "simple-banking" then
                    TriggerEvent('qb-banking:society:server:DepositMoney', src, Amount, jobData.name)
                elseif Config.ManagementType == "qb-management" then
                    exports['qb-management']:AddMoney(jobData.name, Amount)
                end
            end
        end
    end
end)

CreateThread(function()
    Wait(1000)
    local newDebts = exports.oxmysql:executeSync('SELECT * FROM phone_debt', {})
    if newDebts then
        for k, v in pairs(newDebts) do
            print(v.citizenid)
            if not Debts[v.citizenid] then Debts[v.citizenid] = {} end
            Debts[v.citizenid][#Debts[v.citizenid]+1] = {
                id = v.id,
                citizenid = v.citizenid,
                amount = v.amount,
                sender = v.sender,
                sendercitizenid = v.sendercitizenid,
                reason = v.reason,
            }
        end
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetHasBills_debt', function(source, cb)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    if Debts[Ply.PlayerData.citizenid] and #Debts[Ply.PlayerData.citizenid] >= 1 then
        cb(Debts[Ply.PlayerData.citizenid])
    else
        cb(nil)
    end
end)