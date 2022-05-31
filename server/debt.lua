local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:SendBillForPlayer_debt', function(data)
    local src = source
    local biller = QBCore.Functions.GetPlayer(src)
    local billed = QBCore.Functions.GetPlayer(tonumber(data.ID))
    local amount = tonumber(data.Amount)
    if billed then
        if (biller.PlayerData.job.name == "mechanic") then
            if biller.PlayerData.job.onduty then
                if amount and amount > 0  and amount <= 50000 then
                    exports.oxmysql:insert('INSERT INTO phone_debt (citizenid, amount,  sender, sendercitizenid, reason) VALUES (?, ?, ?, ?, ?)',{billed.PlayerData.citizenid, amount, biller.PlayerData.charinfo.firstname.." "..biller.PlayerData.charinfo.lastname, biller.PlayerData.citizenid, data.Reason})
                    TriggerClientEvent('QBCore:Notify', src, 'Debt successfully sent!', "success")
                    TriggerClientEvent('QBCore:Notify', billed.PlayerData.source, 'New Debt Received', "primary")
                    Wait(1)
                    TriggerClientEvent('qb-phone:RefreshPhoneForDebt', billed.PlayerData.source)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Must be a valid amount above 0 and below $50,000', "error")
                end
            else
                TriggerClientEvent("QBCore:Notify", src, 'You\'re not signed into your job!', "error")
            end
        else
            TriggerClientEvent("QBCore:Notify", src, 'You do not have the ability to send a debt!', "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player not Online', "error")
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetHasBills_debt', function(source, cb)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Debt = exports.oxmysql:executeSync('SELECT * FROM phone_debt WHERE citizenid = ?', {Ply.PlayerData.citizenid})
    Wait(400)
    if Debt[1] then
        cb(Debt)
    end
end)

RegisterNetEvent('qb-phone:server:debit_AcceptBillForPay', function(data)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayerByCitizenId(data.CSN)
    local ID = tonumber(data.id)
    local Amount = tonumber(data.Amount)
    local Commission = tonumber(data.Amount) * 0.20
    if OtherPly then
        if Ply.PlayerData.money.bank then
            if Ply.Functions.RemoveMoney('bank', Amount, "Remove Money For Debt") then -- Makes sure the money is removed!
                if OtherPly.PlayerData.job.name == "mechanic" then
                    OtherPly.Functions.AddMoney('bank', Amount+Commission, "Mechanic Debt Commission | $"..Amount.." Paid By: "..Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)
                    exports.oxmysql:execute('DELETE FROM phone_debt WHERE id = ?', {ID})
                    Wait(1)
                    TriggerClientEvent('qb-phone:RefreshPhoneForDebt', OtherPly.PlayerData.source)
                    TriggerClientEvent("QBCore:Notify", src, 'You received $'..Commission..' in commission!', "primary")
                    TriggerEvent('qb-banking:society:server:DepositMoney', source, Amount * 0.80, 'mechanic')
                elseif OtherPly.PlayerData.job.name == "ammbulance" or OtherPly.PlayerData.job.name == "doctor" then
                    OtherPly.Functions.AddMoney('bank', Commission, "EMS Debt Commission | $"..Amount.." Paid By: "..Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)
                    exports.oxmysql:execute('DELETE FROM phone_debt WHERE id = ?', {ID})
                    Wait(1)
                    TriggerClientEvent('qb-phone:RefreshPhoneForDebt', OtherPly.PlayerData.source)
                    TriggerClientEvent("QBCore:Notify", src, 'You received $'..Commission..' in commission!', "primary")
                    TriggerEvent('qb-banking:society:server:DepositMoney', source, Amount * 0.80, 'ems')
                else
                    OtherPly.Functions.AddMoney('bank', Amount,"Debt | $"..Amount.." Paid By: "..Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)
                    exports.oxmysql:execute('DELETE FROM phone_debt WHERE id = ?', {ID})
                    Wait(1)
                    TriggerClientEvent('qb-phone:RefreshPhoneForDebt', OtherPly.PlayerData.source)
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have enough money...', "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player not Online', "error")
    end
end)