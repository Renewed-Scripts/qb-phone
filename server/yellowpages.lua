local QBCore = exports['qb-core']:GetCoreObject()
local Calls = {}

QBCore.Functions.CreateCallback('qb-phone:server:GetCurrentyellowpages', function(_, cb)
    local yellowpages = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.onduty then
                yellowpages[#yellowpages+1] = {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                    typejob = Player.PlayerData.job.name
                }
            end
        end
    end
    cb(yellowpages)
end)

QBCore.Functions.CreateCallback("qb-phone:server:getRandomJobContact", function(source,cb,job)
    local Players = QBCore.Functions.GetPlayers()
    local Player = QBCore.Functions.GetPlayer(source)
    local plrs = {}
    for _,v in pairs(Players) do
        local Plr = QBCore.Functions.GetPlayer(v)
        if Plr.PlayerData.job.name == job and Plr.PlayerData.job.onduty and Plr.PlayerData.source ~= Player.PlayerData.source and (Plr.PlayerData.metadata.FlightMode == nil or Plr.PlayerData.metadata.FlightMode == false) then
            table.insert(plrs,v)
        end
    end
    if #plrs > 0 then
        local Plr = QBCore.Functions.GetPlayer(plrs[math.random(0, #plrs)])
        cb({
            source = Plr.PlayerData.source,
            number = Plr.PlayerData.charinfo.phone,
            name = Plr.PlayerData.charinfo.firstname .. " " .. Plr.PlayerData.charinfo.lastname,
            joblabel = Plr.PlayerData.job.label
        })
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetCallState2', function(source, cb, src)
    local Target = QBCore.Functions.GetPlayer(src)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Target then return cb(false, false) end
    
    if Target.PlayerData.citizenid == Player.PlayerData.citizenid then return cb(false, false) end

    if Calls[Target.PlayerData.citizenid] then
        if Calls[Target.PlayerData.citizenid].inCall then
            cb(false, true)
        else
            cb(true, true)
        end
    else
        cb(true, true)
    end
end)