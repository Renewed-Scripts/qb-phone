---- EMPLOYMENT (GROUP APPS)

local Players = {} -- Don't Touch
local EmploymentGroup = {}

-- All the utility Functions to help us developer have a funner job
local function GetPlayerCharName(src)
    local player = QBCore.Functions.GetPlayer(src)
    return player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
end

local function NotifyGroup(group, msg, type)
    if not group or not EmploymentGroup[group] then return print("Group not found...") end
    for _, v in pairs(EmploymentGroup[group].members) do
        TriggerClientEvent('QBCore:Notify', v.Player, msg, type)
    end
end exports("NotifyGroup", NotifyGroup)

local function pNotifyGroup(group, header, msg, icon, colour, length)
    if not group or not EmploymentGroup[group] then return print("Group not found...") end
    for _, v in pairs(EmploymentGroup[group].members) do
        TriggerClientEvent('qb-phone:client:CustomNotification', v.Player,
            header or "NO HEADER",
            msg or "NO MSG",
            icon or "fas fa-phone-square",
            colour or "#e84118",
            length or 7500
        )
    end
end exports("pNotifyGroup", pNotifyGroup)

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
    if not EmploymentGroup[groupID] then return print("getGroupSize was sent an invalid groupID :"..groupID) end
    return #EmploymentGroup[groupID].members
end exports('getGroupSize', getGroupSize)

local function GetGroupLeader(groupID)
    if not groupID then return print("GetGroupLeader was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].leader
end exports("GetGroupLeader", GetGroupLeader)

local function DestroyGroup(groupID)
    if not EmploymentGroup[groupID] then return print("DestroyGroup was sent an invalid groupID :"..groupID) end
    local members = getGroupMembers(groupID)
    if members and #members > 0 then
        for i = 1, #members do
            if members[i] then
                Players[members[i]] = false
            end
        end
    end

    exports['qb-phone']:resetJobStatus(groupID)
    TriggerEvent("qb-phone:server:GroupDeleted", groupID, members)

    EmploymentGroup[groupID] = nil
    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)

end exports("DestroyGroup", DestroyGroup)

local function RemovePlayerFromGroup(src, groupID, disconnected)
    if not Players[src] or not EmploymentGroup[groupID] then return print("RemovePlayerFromGroup was sent an invalid groupID :"..groupID) end
    local g = EmploymentGroup[groupID].members
    for k,v in pairs(g) do
        if v.Player == src then
            table.remove(EmploymentGroup[groupID].members, k)
            EmploymentGroup[groupID].Users -= 1
            Players[src] = false
            pNotifyGroup(groupID, "Job Center", v.name.." Has left the group", "fas fa-users", "#FFBF00", 7500)
            TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
            if not disconnected then TriggerClientEvent("QBCore:Notify", src, "You have left the group", "primary") end

            if EmploymentGroup[groupID].Users <= 0 then
                DestroyGroup(groupID)
            end

            return
        end
    end
end

local function ChangeGroupLeader(groupID)
    local m = EmploymentGroup[groupID].members
    local l = GetGroupLeader(groupID)
    if #m > 1 then
        for i=1, #m do
            if m[i].Player ~= l then
                EmploymentGroup[groupID].leader = m[i].Player
                return true
            end
        end
    end
    return false
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
    if not m then return end
    for i=1, #m do
        if m[i] then
            TriggerClientEvent("qb-phone:client:AddGroupStage", m[i], status, stages)
        end
    end
end exports('setJobStatus', setJobStatus)

local function getJobStatus(groupID)
    if not groupID then return print("getJobStatus was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].status
end exports('getJobStatus', getJobStatus)

local function resetJobStatus(groupID)
    if not groupID then return print("setJobStatus was sent an invalid groupID :"..groupID) end
    EmploymentGroup[groupID].status = "WAITING"
    EmploymentGroup[groupID].stage = {}
    local m = getGroupMembers(groupID)
    if not m then return end
    for i=1, #m do
        if m[i] then
            TriggerClientEvent("qb-phone:client:AddGroupStage", m[i], EmploymentGroup[groupID].status, EmploymentGroup[groupID].stage)
            TriggerClientEvent('qb-phone:client:RefreshGroupsApp', m[i], EmploymentGroup, true)
        end
    end
end exports('resetJobStatus', resetJobStatus)

AddEventHandler('playerDropped', function()
    local src = source
    local groupID = GetGroupByMembers(src)
    if groupID then
        if isGroupLeader(src, groupID) then
            if ChangeGroupLeader(groupID) then
                RemovePlayerFromGroup(src, groupID, true)
            else
                DestroyGroup(groupID)
            end
        else
            RemovePlayerFromGroup(src, groupID, true)
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

RegisterNetEvent("qb-phone:server:jobcenter_CreateJobGroup", function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if Players[src] then TriggerClientEvent('QBCore:Notify', src, "You have already created a group", "error") return end
    if not data or not data.pass or not data.name then return end
    Players[src] = true
    local ID = #EmploymentGroup+1
    EmploymentGroup[ID] = {
        id = ID,
        status = "WAITING",
        GName = data.name,
        GPass = data.pass,
        Users = 1,
        leader = src,
        members = {
            {name = GetPlayerCharName(src), CID = player.PlayerData.citizenid, Player = src}
        },
        stage = {},
    }

    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
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

RegisterNetEvent('qb-phone:server:jobcenter_DeleteGroup', function(data)
    local src = source
    if not Players[src] then return print("You are not in a group?!?") end
    if GetGroupLeader(data.delete) == src then
        DestroyGroup(data.delete)
    else
        RemovePlayerFromGroup(src, data.delete)
    end
end)

lib.callback.register('qb-phone:server:GetGroupsApp', function(_)
    return EmploymentGroup
end)

RegisterNetEvent('qb-phone:server:jobcenter_JoinTheGroup', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if Players[src] then return TriggerClientEvent('QBCore:Notify', src, "You are already a part of a group!", "success") end

    local name = GetPlayerCharName(src)
    pNotifyGroup(data.id, "Job Center", name.." Has joined the group", "fas fa-users", "#FFBF00", 7500)
    EmploymentGroup[data.id].members[#EmploymentGroup[data.id].members+1] = {name = name, CID = player.PlayerData.citizenid, Player = src}
    EmploymentGroup[data.id].Users += 1
    Players[src] = true
    TriggerClientEvent('QBCore:Notify', src, "You joined the group", "success")
    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
end)

local function GetGroupStages(groupID)
    if not groupID then return print("GetGroupStages was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].stage
end exports('GetGroupStages', GetGroupStages)

lib.callback.register('qb-phone:server:getAllGroups', function(source)
    local src = source

    if Players[src] then
        return EmploymentGroup, true, getJobStatus(GetGroupByMembers(src)), GetGroupStages(GetGroupByMembers(src))
    else
        return EmploymentGroup, false
    end
end)

lib.callback.register('qb-phone:server:jobcenter_CheckPlayerNames', function(_, csn)
    local Names = {}
    for _, v in pairs(EmploymentGroup[csn].members) do
        Names[#Names+1] = v.name
    end
    return Names
end)

RegisterNetEvent('qb-phone:server:jobcenter_leave_grouped', function(data)
    local src = source
    if not Players[src] then return end
    RemovePlayerFromGroup(src, data.id)
end)

local function isGroupTemp(groupID)
    if not groupID or not EmploymentGroup[groupID] then return print("isGroupTemp was sent an invalid groupID :"..groupID) end
    return EmploymentGroup[groupID].ScriptCreated or false
end exports('isGroupTemp', isGroupTemp)

local function CreateGroup(src, name, password)
    if not src or not name then return end
    local Player = QBCore.Functions.GetPlayer(src)
    Players[src] = true
    local id = #EmploymentGroup+1
    EmploymentGroup[id] = {
	id = id,
        status = "WAITING",
        GName = name,
        GPass = password or QBCore.Shared.RandomInt(7),
        Users = 1,
        leader = src,
        members = {
            {name = GetPlayerCharName(src), CID = Player.PlayerData.citizenid, Player = src}
        },
        stage = {},
        ScriptCreated = true,
    }

    TriggerClientEvent('qb-phone:client:RefreshGroupsApp', -1, EmploymentGroup)
    return id
end exports('CreateGroup', CreateGroup)
