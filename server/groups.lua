local QBCore = exports['qb-core']:GetCoreObject()

---- EMPLOYMENT (GROUP APPS)

local Players = {} -- Don't Touch
local EmploymentGroup = {}

-- All the utility Functions to help us developer have a funner job
local function GetPlayerCharName(src)
    local player = QBCore.Functions.GetPlayer(src)
    return player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
end

local function NotifyGroup(group, msg, type)
    for _, v in pairs(EmploymentGroup[group].members) do
        TriggerClientEvent('QBCore:Notify', v.Player, msg, type)
    end
end exports("NotifyGroup", NotifyGroup)

local function CreateBlipForGroup(groupID, name, data)
    if not groupID then return print("CreateBlipForGroup was sent an invalid groupID :"..groupID) end

    for i=1, #EmploymentGroup[groupID].members do
        TriggerClientEvent("groups:createBlip", EmploymentGroup[groupID].members[i].Player, name, data)
    end
end exports('CreateBlipForGroup', CreateBlipForGroup)

local function RemoveBlipForGroup(groupID, name)
    if not groupID then return print("CreateBlipForGroup was sent an invalid groupID :"..groupID) end

    for i=1, #EmploymentGroup[groupID].members do
        TriggerClientEvent("groups:removeBlip", EmploymentGroup[groupID].members[i].Player, name)
    end
end exports('RemoveBlipForGroup', RemoveBlipForGroup)


-- All group functions to get members leaders and size.
local function GetGroupByMembers(src)
    if not Players[src] then return nil end
    for group, _ in pairs(EmploymentGroup) do
        for _, v in pairs (EmploymentGroup[group].members) do
            if v.Player == src then
                return group
            end
        end
    end
end exports("GetGroupByMembers", GetGroupByMembers)

local function getGroupMembers(groupID)
    if not groupID then return print("getGroupMembers was sent an invalid groupID :"..groupID) end
    local temp = {}
    for _,v in pairs(EmploymentGroup[groupID].members) do
        temp[#temp+1] = v.Player
    end
    return temp
end exports('getGroupMembers', getGroupMembers)

local function getGroupSize(groupID)
    if not groupID then return print("getGroupSize was sent an invalid groupID :"..groupID) end
    return #EmploymentGroup[groupID].members
end exports('getGroupSize', getGroupSize)

local function GetGroupLeader(groupID)
    if not groupID then return print("GetGroupLeader was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].leader
end exports("GetGroupLeader", GetGroupLeader)

local function DestroyGroup(groupID)
    if not EmploymentGroup[groupID] then return print("DestroyGroup was sent an invalid groupID :"..groupID) end
    for _, v in pairs(EmploymentGroup[groupID].members) do
        Players[v.Player] = false
    end
    EmploymentGroup[groupID] = nil
    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
end

local function RemovePlayerFromGroup(src, groupID)
    local player = QBCore.Functions.GetPlayer(src)
    if Players[src] then
        if EmploymentGroup[groupID] then
            local g = EmploymentGroup[groupID].members
            for k,v in pairs(g) do
                if v.CID == player.PlayerData.citizenid then
                    EmploymentGroup[groupID].members[k] = nil
                    EmploymentGroup[groupID].Users -= 1
                    Players[src] = false
                    NotifyGroup(groupID, GetPlayerCharName(src).." Has left the group...", "success")
                    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
                    TriggerClientEvent("QBCore:Notify", src, "You have left the group", "primary")

                    if EmploymentGroup[groupID].Users <= 0 then
                        DestroyGroup(groupID)
                    end

                    break
                end
            end
        end
    end
end

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

local function isGroupLeader(src, groupID)
    if not groupID then return end
    local grouplead = GetGroupLeader(groupID)
    return grouplead == src or false
end exports('isGroupLeader', isGroupLeader)

---- All the job functions for the groups

local function setJobStatus(groupID, status, stages)
    if not groupID then return print("setJobStatus was sent an invalid groupID :"..groupID) end
    EmploymentGroup[groupID].status = status
    EmploymentGroup[groupID].stage = stages
    local m = getGroupMembers(groupID)
    for i=1, #m do
        TriggerClientEvent("qb-phone:client:AddGroupStage", m[i], status, stages)
    end
end exports('setJobStatus', setJobStatus)

local function resetJobStatus(groupID)
    if not groupID then return print("setJobStatus was sent an invalid groupID :"..groupID) end
    EmploymentGroup[groupID].status = "WAITING"
    EmploymentGroup[groupID].stage = {}
    local m = getGroupMembers(groupID)
    for i=1, #m do
        TriggerClientEvent("qb-phone:client:AddGroupStage", m[i], EmploymentGroup[groupID].status, EmploymentGroup[groupID].stage)
        TriggerClientEvent('qb-phone:client:RefreshGroupsApp', m[i], EmploymentGroup, true)
    end
end exports('resetJobStatus', resetJobStatus)

local function getJobStatus(groupID)
    if not groupID then return print("getJobStatus was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].status
end exports('getJobStatus', getJobStatus)

AddEventHandler('playerDropped', function()
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


RegisterNetEvent("qb-phone:server:employment_checkJobStauts", function ()
    local src = source
    local checkStatus = GetGroupByMembers(src)
    if checkStatus then
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

RegisterNetEvent("TestGroups", function()
    local src = source
    local TestTable = {
        {name = "Pick Up Truck", isDone = true, id = 1},
        {name = "Pick up garbage", isDone = false , id = 2},
        {name = "Drop off garbage", isDone = false , id = 3},
    }

    setJobStatus((GetGroupByMembers(src)), "garbage", TestTable)
end)

RegisterNetEvent('qb-phone:server:employment_DeleteGroup', function(data)
    local src = source
    print(json.encode(data))
    if not Players[src] then return print("You are not in a group?!?") end
    if GetGroupLeader(data.delete) == src then
        DestroyGroup(data.delete)
    else
        RemovePlayerFromGroup(data.delete, src)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetGroupsApp', function(_, cb)
    cb(EmploymentGroup)
end)

RegisterNetEvent('qb-phone:server:employment_JoinTheGroup', function(data)
    print(json.encode(data))
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    for _, v in pairs(EmploymentGroup[data.id].members) do
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
        break
    end
end)

local function GetGroupStages(groupID)
    if not groupID then return print("GetGroupStages was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].stage
end exports('GetGroupStages', GetGroupStages)

QBCore.Functions.CreateCallback('qb-phone:server:getAllGroups', function(source, cb)
    local src = source

    if Players[src] then
        print(getJobStatus(GetGroupByMembers(src)))
        print(json.encode(GetGroupStages(GetGroupByMembers(src))))
        cb(EmploymentGroup, true, getJobStatus(GetGroupByMembers(src)), GetGroupStages(GetGroupByMembers(src)))
    else
        cb(EmploymentGroup, false)
    end
end)

QBCore.Functions.CreateCallback('qb-phone:server:employment_CheckPlayerNames', function(_, cb, csn)
    local Names = {}
    for _, v in pairs(EmploymentGroup[csn].members) do
        Names[#Names+1] = v.name
    end
    cb(Names)
end)


RegisterNetEvent('qb-phone:server:employment_leave_grouped', function(data)
    local src = source
    print("leave")
    if not Players[src] then return end
    RemovePlayerFromGroup(src, data.id)
end)
