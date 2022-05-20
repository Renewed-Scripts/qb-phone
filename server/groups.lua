local QBCore = exports['qb-core']:GetCoreObject() -- core object


-- Localized tables for groups
local Players = {} -- Has all the players that are in groups in a table to do various checks
local EmploymentGroup = {} -- has all the groups store with data awe are looking at / for



---- ** GROUP LOCALIZED FUNCTIONS AND EXPORTS MUST BE USED SERVER SIDE ** ----

-- Gets the players Character name
local function GetPlayerCharName(src)
    local player = QBCore.Functions.GetPlayer(src)
    return player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
end

-- Notifies all the group members seperately with a message
local function NotifyGroup(group, msg, type)
    for _, v in pairs(EmploymentGroup[group].members) do
        TriggerClientEvent('QBCore:Notify', v.Player, msg, type)
    end
end exports("NotifyGroup", NotifyGroup)


-- Creates a synced group blip so everyone in the group can see it
local function CreateBlipForGroup(groupID, name, data)
    if groupID == nil then return print("CreateBlipForGroup was sent an invalid groupID :"..groupID) end

    for i=1, #EmploymentGroup[groupID].members do
        TriggerClientEvent("groups:createBlip", EmploymentGroup[groupID].members[i].Player, name, data)
    end
end exports('CreateBlipForGroup', CreateBlipForGroup)

-- Removes the blip for everyone in the group when done being used 
local function RemoveBlipForGroup(groupID, name)
    if groupID == nil then return print("CreateBlipForGroup was sent an invalid groupID :"..groupID) end

    for i = 1, #EmploymentGroup[groupID].members do
        TriggerClientEvent("groups:removeBlip", EmploymentGroup[groupID].members[i].Player, name)
    end
end exports('RemoveBlipForGroup', RemoveBlipForGroup)


-- All group functions to get members leaders and size.

-- gets the group by searching the player source use it like local group = exports["qb-phone"]:GetGroupByMembers(source)
local function GetGroupByMembers(src)
    if Players[src] then 
        for group, _ in pairs(EmploymentGroup) do
            for k, v in pairs (EmploymentGroup[group].members) do
                if v.Player == src then
                    return group
                end
            end
        end
    end
end exports("GetGroupByMembers", GetGroupByMembers)

-- gets all the group members SRC so you can use it to give items, pings etc.
local function getGroupMembers(groupID)
    if groupID == nil then return print("getGroupMembers was sent an invalid groupID :"..groupID) end
    local temp = {}
    for k,v in pairs(EmploymentGroup[groupID].members) do
        temp[#temp+1] = v.Player
    end
    return temp
end exports('getGroupMembers', getGroupMembers)


-- Gets the group size incase you need to make sure no more than x amount can join the activity
local function getGroupSize(groupID)
    if groupID == nil then return print("getGroupSize was sent an invalid groupID :"..groupID) end
    return #EmploymentGroup[groupID].members
end exports('getGroupSize', getGroupSize)

-- Gets the group leader SRC, you can then use this to do a check if player is leader then can start job etc.
local function GetGroupLeader(groupID)
    if groupID == nil then return print("GetGroupLeader was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].leader
end exports("GetGroupLeader", GetGroupLeader)

-- Destroys the group incase they drop out
local function DestroyGroup(groupID)
    if not EmploymentGroup[groupID] then return print("DestroyGroup was sent an invalid groupID :"..groupID) end
    for k, v in pairs(EmploymentGroup[groupID].members) do
        Players[v.Player] = false
    end
    EmploymentGroup[groupID] = nil
    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
end

-- Removes player from group can be used for some things I just use it for when they leave the server
local function RemovePlayerFromGroup(src, groupID)
    local player = QBCore.Functions.GetPlayer(src)
    if Players[src] then 
        if EmploymentGroup[groupID] then
            local g = EmploymentGroup[groupID].members
            for k,v in pairs(g) do
                if v.CID == player.PlayerData.citizenid then
                    EmploymentGroup[groupID].members[k] = nil
                    EmploymentGroup[groupID].Users = EmploymentGroup[groupID].Users - 1
                    Players[src] = false
                    NotifyGroup(groupID, GetPlayerCharName(src).." Has left the group...", "success")
                    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
                    TriggerClientEvent("QBCore:Notify", src, "You have left the group", "primary")

                    if EmploymentGroup[groupID].Users <= 0 then
                        DestroyGroup(groupID)
                    end

                    return
                end
            end
        end
    end
end

-- If the group leader disconnects and there's still more people in the group a new leader just gets assigned.
local function ChangeGroupLeader(groupID)
    local m = EmploymentGroup[groupID].members
    local l = GetGroupLeader(groupID)
    if #m > 1 then 
        for i=1, #m do 
            if m[i] ~= l then 
                EmploymentGroup[groupID].leader = m[i]
                break
            end
        end
    end
end

-- Can also use this to check if player is leader or not
local function isGroupLeader(src, groupID)
    if groupID == nil then return end
    local grouplead = GetGroupLeader(groupID)
    if grouplead == src then
        return true
    else
        return false
    end
end

-- Sets that group job status, so like if you are doing a garbage run set this to garbage and with the stages you'd want in
local function setJobStatus(groupID, status, stages)
    if groupID == nil then return print("setJobStatus was sent an invalid groupID :"..groupID) end
    EmploymentGroup[groupID].status = status
    EmploymentGroup[groupID].stage = stages
    local m = getGroupMembers(groupID)
    for i=1, #m do
        TriggerClientEvent("qb-phone:client:AddGroupStage", m[i], status, stages)
    end
end exports('setJobStatus', setJobStatus)

-- Gets the job status so u can do checks and make sure they are not already doing a different job.
local function getJobStatus(groupID)
    if groupID == nil then return print("getJobStatus was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].status
end exports('getJobStatus', getJobStatus)

-- Just a export to get the current group stages.
local function GetGroupStages(groupID)
    if groupID == nil then return print("GetGroupStages was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].stage
end exports('GetGroupStages', GetGroupStages)


-- ** Call Backs ** --
QBCore.Functions.CreateCallback('qb-phone:server:GetGroupsApp', function(source, cb)
    cb(EmploymentGroup)
end)

QBCore.Functions.CreateCallback('qb-phone:server:getAllGroups', function(source, cb, csn)
    local src = source

    if Players[src] then
        print(getJobStatus(GetGroupByMembers(src)))
        print(json.encode(GetGroupStages(GetGroupByMembers(src))))
        cb(EmploymentGroup, true, getJobStatus(GetGroupByMembers(src)), GetGroupStages(GetGroupByMembers(src)))
    else
        cb(EmploymentGroup, false)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:employment_CheckPlayerNames', function(source, cb, csn)
    local Names = {}
    for k, v in pairs(EmploymentGroup[csn].members) do
        local Name = v.name
        Names[#Names+1] = Name
    end
    cb(Names)
end)


-- ** Net Events ** --
RegisterNetEvent("qb-phone:server:employment_checkJobStauts", function (data)
    local src = source 
    local checkStatus = GetGroupByMembers(src)
    if checkStatus ~= nil then
        TriggerClientEvent('qb-phone:client:showEmploymentPage', src)
    else
        TriggerClientEvent('qb-phone:client:showEmploymentGroupPage', src)
    end
end)

RegisterNetEvent("qb-phone:server:employment_CreateJobGroup", function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not Players[src] then 
        Players[src] = true
        EmploymentGroup[#EmploymentGroup+1] = {
            id = #EmploymentGroup+1,
            status = "WAITING",
            GName = data.name,
            GPass = data.pass,
            Users = 1,
            leader = src,
            members = {
                {name = GetPlayerCharName(src), CID = player.PlayerData.citizenid, Player = src,}
            },
            stage = {},
        }

        TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
    else
        TriggerClientEvent('QBCore:Notify', src, "You have already created a group", "error")
    end
end)

RegisterNetEvent('qb-phone:server:employment_DeleteGroup', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not Players[src] then return print("You are not in a group?!?") end
    if GetGroupLeader(data.delete) == player.PlayerData.citizenid then
        DestroyGroup(data.delete)
    else
        RemovePlayerFromGroup(data.delete, src)
    end
end)

RegisterNetEvent('qb-phone:server:employment_JoinTheGroup', function(data)
    print(json.encode(data))
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    for k, v in pairs(EmploymentGroup[data.id].members) do
        if v.CID == data.PCSN then
            TriggerClientEvent('QBCore:Notify', src, "You have already joined a group", "error")
            return
        end

        NotifyGroup(data.id, GetPlayerCharName(src).." Have Joined the Group", "success")
        EmploymentGroup[data.id].members[#EmploymentGroup[data.id].members+1] = {name = GetPlayerCharName(src), CID = player.PlayerData.citizenid, Player = src,}
        EmploymentGroup[data.id].Users = EmploymentGroup[data.id].Users + 1
        Players[src] = true
        TriggerClientEvent('QBCore:Notify', src, "You joined the group", "success")
        TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
        return
    end
end)

RegisterNetEvent('qb-phone:server:employment_leave_grouped', function(data)
    local src = source
    if not Players[src] then return end
    RemovePlayerFromGroup(src, data.id)
end)

-- ** Events Handlers ** --
AddEventHandler('playerDropped', function(reason)
	local src = source
    local groupID = GetGroupByMembers(src)
    if groupID ~= 0 then
        if isGroupLeader(src, groupID) then 
            if ChangeGroupLeader(groupID) then
                TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
            else 
                DestroyGroup(groupID)
                TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
            end 
        else 
            RemovePlayerFromGroup(groupID, src)
        end 
    end	
end)

