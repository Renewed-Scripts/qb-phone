local QBCore = exports['qb-core']:GetCoreObject()

local CachedJobs = {}
local CachedPlayers = {}


local function getMyJobs(cid)
    local jobs = {}
    local employees = {}
    for k, v in pairs(CachedJobs) do
        if v.employees[cid] then
            if not jobs[k] then
                jobs[k] = v.employees[cid]
            end

            if not employees[k] then
                employees[k] = v.employees
            end
        end
    end

    return jobs, employees
end

local FirstStart = false

CreateThread(function()
    ---- Convertion Tool I guess LOL ----
    if not FirstStart then return end
    while not QBCore do Wait(25) end
    for k, _ in pairs(QBCore.Shared.Jobs) do
        if k ~= 'unemployed' then
            if not CachedJobs[k] then CachedJobs[k] = {} end

            local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%".. k .."%'", {})
            if players[1] then
                for _, v in pairs(players) do
                    print(json.decode(v.job).grade.level)
                    if not CachedJobs[k].employees then CachedJobs[k].employees = {} end
                    if not CachedJobs[k].employees[v.citizenid] then
                        CachedJobs[k].employees[v.citizenid] = {
                            cid = v.citizenid,
                            grade = json.decode(v.job).grade.level,
                            name = json.decode(v.charinfo).firstname .. ' ' .. json.decode(v.charinfo).lastname
                        }
                    end
                end

                MySQL.insert('INSERT INTO player_jobs (`jobname`, `employees`) VALUES (?, ?)', {
                    k,
                    json.encode(CachedJobs[k].employees)
                })
            else
                MySQL.insert('INSERT INTO player_jobs (`jobname`, `employees`) VALUES (?, ?)', {
                    k,
                    json.encode({})
                })
            end
        end
    end
end)

CreateThread(function()
    if FirstStart then return end
    while not QBCore do Wait(25) end

    local jobs = MySQL.query.await("SELECT * FROM `player_jobs`", {})
    if jobs[1] then
        for _, v in pairs(jobs) do
            if not CachedJobs[v.jobname] then
                CachedJobs[v.jobname] = {
                    employees = json.decode(v.employees),
                    maxEmployee = v.maxEmployee
                }
            end

            table.sort(CachedJobs[v.jobname].employees, function(a, b)
                return a.grade.level > b.grade.level
            end)
        end
    end
end)



-- Change User Data --
RegisterNetEvent('qb-phone:server:fireUser', function(Job, CID)
    local srcPlayer = QBCore.Functions.GetPlayer(source)

    if not Job or not CID then return print("Not all arguments filled") end
    if not CachedJobs[Job] then return print("Not Cached job") end
    if not CachedJobs[Job].employees[CID] then return print("Player is not employed LOL") end
    if not srcPlayer then return print("Player not found") end

    local srcCID = srcPlayer.PlayerData.citizenid

    --if srcCID == CID then return end

    if not CachedJobs[Job].employees[srcCID].grade then return end

    local grade = tostring(CachedJobs[Job].employees[srcCID].grade)
    if not QBCore.Shared.Jobs[Job].grades[grade].isboss then return end

    if CachedJobs[Job].employees[srcCID].grade < CachedJobs[Job].employees[CID].grade then return end


    CachedJobs[Job].employees[CID] = nil
    MySQL.update('UPDATE player_jobs SET employees = ? WHERE jobname = ?',{json.encode(CachedJobs[Job].employees), Job})

    TriggerClientEvent("qb-phone:client:JobsHandler", -1, job, CachedJobs[Job].employees)


    if CachedPlayers[CID][Job] then
        local Player = QBCore.Functions.GetPlayerByCitizenId(CID)
        if Player.PlayerData.job.name == Job then
            Player.Functions.SetJob("unemployed")
        end

        CachedPlayers[CID][Job] = nil

        if Player.PlayerData.source then
            TriggerClientEvent('qb-phone:client:MyJobsHandler', Player.PlayerData.source, Job, nil, nil)
        end
    end
end)

RegisterNetEvent('qb-phone:server:SendEmploymentPayment', function(Job, CID, amount)
    local src = source
    if not Job or not CID or not amount or not CachedJobs[Job] or Job == "unemployed" then return print("lacking args") end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local srcCID = Player.PlayerData.citizenid

    --if srcCID == CID then return end

    if not CachedJobs[Job].employees[srcCID].grade then return end

    local grade = tostring(CachedJobs[Job].employees[srcCID].grade)
    if not QBCore.Shared.Jobs[Job].grades[grade].isboss then return print("Is not boss") end

    local Reciever = QBCore.Functions.GetPlayerByCitizenId(CID)
    if not Reciever then return print("Reciever offline") end

    local amt = tonumber(amount)
    if Config.RenewedBanking then
        if not exports['Renewed-Banking']:removeAccountMoney(Job, amt) then return print("Not enough society money") end
        local title = QBCore.Shared.Jobs[Job].label.." // Employee Payment"

        ---- Business Account ----
        local BusinessName = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
        local RecieverName = ("%s %s"):format(Reciever.PlayerData.charinfo.firstname, Reciever.PlayerData.charinfo.lastname)
        exports['Renewed-Banking']:handleTransaction(Job, title, amt, "Payment given of $"..amt.." given to "..RecieverName, BusinessName, RecieverName, "withdraw")

        ---- Player Account ----
        exports['Renewed-Banking']:handleTransaction(Reciever.PlayerData.citizenid, title, amt, "Payment recieved of $"..amt.." recieved from Business "..QBCore.Shared.Jobs[Job].label.. " and Manager "..BusinessName, BusinessName, RecieverName, "deposit")
    else
        if not exports['qb-management']:RemoveMoney(Job, amt) then return print("Not enough society money") end
    end
    Player.Functions.AddMoney('bank', amt)
end)

RegisterNetEvent('qb-phone:server:hireUser', function(Job, CID, grade)
    if not Job or not CID or not CachedJobs[Job] or Job == "unemployed" then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)

    if CachedJobs[Job].employees[CID] then return print("Already hired") end

    CachedJobs[Job].employees[CID] = {
        cid = CID,
        grade = grade or 0,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    }

    MySQL.update('UPDATE player_jobs SET employees = ? WHERE jobname = ?',{json.encode(CachedJobs[Job].employees), Job})

    if Player and CachedPlayers[CID] then
        CachedPlayers[CID][Job] = CachedJobs[Job].employees[CID]
        TriggerClientEvent('qb-phone:client:MyJobsHandler', Player.PlayerData.source, Job, CachedPlayers[CID][Job], CachedJobs[Job].employees)
    end

    TriggerClientEvent("qb-phone:client:JobsHandler", -1, Job, CachedJobs[Job].employees)
    print("Hired")
end)

RegisterNetEvent('qb-phone:server:gradesHandler', function(Job, CID, grade)
    if not Job or not CID or not CachedJobs[Job] then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)
    if not CachedJobs[Job].employees[CID] then return print("Not apart of the group") end

    CachedJobs[Job].employees[CID] = {
        cid = CID,
        grade = grade,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    }

    MySQL.update('UPDATE player_jobs SET employees = ? WHERE jobname = ?',{json.encode(CachedJobs[Job].employees), Job})

    TriggerClientEvent("qb-phone:client:JobsHandler", -1, Job, CachedJobs[Job].employees)

    if Player and CachedPlayers[CID] then
        CachedPlayers[CID][Job] = CachedJobs[Job].employees[CID]
        TriggerClientEvent('qb-phone:client:MyJobsHandler', Player.PlayerData.source, Job, CachedPlayers[CID][Job], CachedJobs[Job].employees)
    end
end)










---- Gets the client side cache for players ----
QBCore.Functions.CreateCallback("qb-phone:server:GetMyJobs", function(source, cb)
    if FirstStart then return end
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then return cb(nil, nil) end

    local job = Player.PlayerData.job.name

    local CID = Player.PlayerData.citizenid
    local employees = {}
    CachedPlayers[CID], employees = getMyJobs(CID)

    ---- If you were fired while being offline it will remove the job --
    if not CachedPlayers[CID][job] then
        Player.Functions.SetJob("unemployed")
    end


    cb(employees, CachedPlayers[CID])
end)

