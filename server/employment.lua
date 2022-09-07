local QBCore = exports['qb-core']:GetCoreObject()

local CachedJobs = {}
local CachedPlayers = {}


local function getMyJobs(cid)
    local jobs = {}
    local employees = {}
    for k, v in pairs(CachedJobs) do
        for i = 1, #v.employees do
            if v.employees[i].cid == cid then
                if not jobs[k] then
                    jobs[k] = v.employees[i]
                end

                if not employees[k] then
                    employees[k] = v.employees
                end
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
                    CachedJobs[k].employees[#CachedJobs[k].employees+1] = {
                        cid = v.citizenid,
                        grade = json.decode(v.job).grade.level,
                        name = json.decode(v.charinfo).firstname .. ' ' .. json.decode(v.charinfo).lastname
                    }
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



---- Get the table Key from job and citizenid ----
local function getKey(job, CID)
    for k, v in pairs(CachedJobs[job].employees) do
        if v.cid == CID then
            return k
        end
    end

    return nil
end






-- Change User Data --
RegisterNetEvent('qb-phone:server:fireUser', function(Job, CID)
    local srcPlayer = QBCore.Functions.GetPlayer(source)

    if not Job or not CID then return print("Not all arguments filled") end
    if not CachedJobs[Job] then return print("Not Cached job") end
    if not srcPlayer then return print("Player not found") end

    local srcCID = srcPlayer.PlayerData.citizenid

    if srcCID == CID then return end

    local srcK = getKey(Job, srcCID)

    if not srcK then return end

    local grade = tostring(CachedJobs[Job].employees[srcK].grade)
    if not QBCore.Shared.Jobs[Job].grades[grade].isboss then return end

    local k = getKey(Job, CID)
    if not k then return print("no K") end
    if CachedJobs[Job].employees[srcK].grade < CachedJobs[Job].employees[k].grade then return end

    table.remove(CachedJobs[Job].employees, k)
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

    local Reciever = QBCore.Functions.GetPlayerByCitizenId(CID)
    if not Reciever then return print("Reciever offline") end

    local k = getKey(Job, Player.PlayerData.citizenid)

    if not k then return print("Player not found") end

    local grade = tostring(CachedJobs[Job].employees[k].grade)
    if not QBCore.Shared.Jobs[Job].grades[grade].isboss then return print("Is not boss") end
    local amt = tonumber(amount)
    if Config.RenewedBanking then
        if not exports['Renewed-Banking']:removeAccountMoney(Job, amt) then return print("Not enough society money") end
    else
        if not exports['qb-management']:RemoveMoney(Job, amt) then return print("Not enough society money") end
    end
    Player.Functions.AddMoney('bank', amt)
end)

RegisterNetEvent('qb-phone:server:hireUser', function(Job, CID, grade)
    if not Job or not CID or not CachedJobs[Job] or Job == "unemployed" then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)



    for _, v in pairs(CachedJobs[Job].employees) do
        if v.cid == CID then
            return
        end
    end

    local k = #CachedJobs[Job].employees+1
    CachedJobs[Job].employees[k] = {
        cid = CID,
        grade = grade,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    }

    MySQL.update('UPDATE player_jobs SET employees = ? WHERE jobname = ?',{json.encode(CachedJobs[Job].employees), Job})

    if Player and CachedPlayers[CID] then
        CachedPlayers[CID][Job] = CachedJobs[Job].employees[k]
        TriggerClientEvent('qb-phone:client:MyJobsHandler', Player.PlayerData.source, Job, CachedPlayers[CID][Job], CachedJobs[Job].employees)
    end

    TriggerClientEvent("qb-phone:client:JobsHandler", -1, Job, CachedJobs[Job].employees)
    print("Hired")
end)

RegisterNetEvent('qb-phone:server:gradesHandler', function(Job, CID, grade)
    if not Job or not CID or not CachedJobs[Job] then return end
    local Player = QBCore.Functions.GetPlayerByCitizenId(CID)
    local k = getKey(Job, CID)

    if not k then return end

    CachedJobs[Job].employees[k] = {
        cid = CID,
        grade = grade,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    }

    MySQL.update('UPDATE player_jobs SET employees = ? WHERE jobname = ?',{json.encode(CachedJobs[Job].employees), Job})

    TriggerClientEvent("qb-phone:client:JobsHandler", -1, Job, CachedJobs[Job].employees)

    if Player and CachedPlayers[CID] then
        CachedPlayers[CID][Job] = CachedJobs[Job].employees[k]
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

