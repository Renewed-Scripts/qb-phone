local QBCore = exports['qb-core']:GetCoreObject()

local function isAuthorized(job)
    return Config.DebtJobs[job]
end

local function format_int(n)
    if not n then return 0 end
    n = tonumber(n)
    if n >= 1e14 then return tostring(n) end
    if n <= -1e14 then return "-" .. tostring(math.abs(n)) end
    local negative = n < 0
    n = tostring(math.abs(n))
    local dp = string.find(n, "%.") or #n + 1

    for i = dp - 4, 1, -3 do
        n = n:sub(1, i) .. "," .. n:sub(i + 1)
    end

    -- Make sure the amount is padded with zeroes
    if n[#n - 1] == "." then
        n = n .. "0"
    end

    return (negative and "-" or "") .. n
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


    exports.oxmysql:insert('INSERT INTO phone_debt (citizenid, amount,  sender, sendercitizenid, reason) VALUES (?, ?, ?, ?, ?)',{billed.PlayerData.citizenid, amount, biller.PlayerData.charinfo.firstname.." "..biller.PlayerData.charinfo.lastname, biller.PlayerData.citizenid, data.Reason})
    TriggerClientEvent('qb-phone:DebtSend', src)
    Wait(0) -- Waiting a single frame to ensure that database updates in time for the client to receive the event
    TriggerClientEvent('qb-phone:DebtRecieved', billed.PlayerData.source)
    TriggerClientEvent('qb-phone:RefreshPhoneForDebt', billed.PlayerData.source)
end)

RegisterNetEvent('qb-phone:server:debit_AcceptBillForPay', function(data)
    local src = source -- src is the player who paid the bill
    local Ply = QBCore.Functions.GetPlayer(src)
    local OtherPly = QBCore.Functions.GetPlayerByCitizenId(data.CSN) -- this is the sender for the bill
    local ID = tonumber(data.id)
    local Amount = tonumber(data.Amount)

    if Ply.Functions.RemoveMoney('bank', Amount, tostring(data.Reason)) then -- Makes sure the money is removed!
        exports.oxmysql:execute('DELETE FROM phone_debt WHERE id = ?', {ID})
        Wait(0) -- Waiting a single frame to ensure that database updates in time for the client to receive the event
        TriggerClientEvent('qb-phone:RefreshPhoneForDebt', src)

        if OtherPly and Config.DebtJobs[OtherPly.PlayerData.job.name].comissionEnabled then
            local comission = Amount * Config.DebtJobs[OtherPly.PlayerData.job.name].comission
            Amount = Amount - comission
            TriggerClientEvent("QBCore:Notify", OtherPly.PlayerData.source, 'You received $'..comission..' in commission!', "primary")

            OtherPly.Functions.AddMoney('bank', comission, OtherPly.PlayerData.job.name.." Debt Commission | $"..Amount.." Paid By: "..Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)
            TriggerClientEvent('qb-phone:DebtMail', OtherPly.PlayerData.source, Ply.PlayerData.charinfo.firstname..' '..Ply.PlayerData.charinfo.lastname)

            if Config.ManagementType == "simple-banking" then
                TriggerEvent('qb-banking:society:server:DepositMoney', src, Amount, OtherPly.PlayerData.job.name)
            elseif Config.ManagementType == "qb-management" then
                exports['qb-management']:AddMoney(OtherPly.PlayerData.job.name, Amount)
            end
        else
            if Config.ManagementType == "simple-banking" then
                TriggerEvent('qb-banking:society:server:DepositMoney', src, Amount, OtherPly.PlayerData.job.name)
            elseif Config.ManagementType == "qb-management" then
                exports['qb-management']:AddMoney(OtherPly.PlayerData.job.name, Amount)
            end
        end
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetHasBills_debt', function(source, cb)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local Debt = exports.oxmysql:executeSync('SELECT * FROM phone_debt WHERE citizenid = ?', {Ply.PlayerData.citizenid})
    Wait(100)
    if Debt[1] then
        cb(Debt)
    end
end)