local QBCore = exports['qb-core']:GetCoreObject()

local inJob = false
local GroupBlips = {}

local function FindBlipByName(name)
    for i=1, #GroupBlips do
        if GroupBlips[i] and GroupBlips[i].name == name then
            return i
        end
    end
end

RegisterNetEvent("groups:removeBlip", function(name)
    local i = FindBlipByName(name)
    if i then
        local blip = GroupBlips[i]["blip"]
        SetBlipRoute(blip, false)
        RemoveBlip(blip)
        GroupBlips[i] = nil
    end
end)

RegisterNetEvent('groups:phoneNotification', function(data)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = data.title,
            text = data.text,
            icon = data.icon,
            color = data.color,
            timeout = data.timeout,
        },
    })
end)

RegisterNetEvent("groups:createBlip", function(name, data)
    if not data then return print("Invalid Data was passed to the create blip event") end

    if FindBlipByName(name) then
        TriggerEvent("groups:removeBlip", name)
    end

    local blip = nil
    if data.entity then
        blip = AddBlipForEntity(data.entity)
    elseif data.netId then
        blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(data.netId))
    elseif data.radius then
        blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    else
        blip = AddBlipForCoord(data.coords)
    end

    if not data.color then data.color = 1 end
    if not data.alpha then data.alpha = 255 end

    if not data.radius then
        if not data.sprite then data.sprite = 1 end
        if not data.scale then data.scale = 0.7 end
        if not data.label then data.label = "NO LABEL FOUND" end

        SetBlipSprite(blip, data.sprite)
        SetBlipScale(blip, data.scale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(data.label)
        EndTextCommandSetBlipName(blip)
    end

    SetBlipColour(blip, data.color)
    SetBlipAlpha(blip, data.alpha)

    if data.route then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, data.routeColor)
    end
    GroupBlips[#GroupBlips+1] = {name = name, blip = blip}
end)

RegisterNUICallback('GetGroupsApp', function (_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:getAllGroups', function (getGroups, inGroup, currentJob, stages)
        cb(getGroups)
    end)
end)

RegisterNetEvent('qb-phone:client:RefreshGroupsApp', function(Groups, finish)
    if finish then inJob = false end
    if inJob then return end
    SendNUIMessage({
        action = "refreshApp",
        data = Groups,
    })
end)

RegisterNetEvent('qb-phone:client:AddGroupStage', function(status, stage)
    inJob = true
    print(status, json.encode(stage))
    SendNUIMessage({
        action = "addGroupStage",
        data = Groups,
        status =  stage
    })
end)


RegisterNUICallback('employment_CreateJobGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:employment_CreateJobGroup', data)
    cb("ok")
end)

RegisterNUICallback('employment_JoinTheGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:employment_JoinTheGroup', data)
    cb("ok")
end)

RegisterNUICallback('employment_leave_grouped', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:employment_leave_grouped', data)
    cb("ok")
end)

RegisterNUICallback('employment_DeleteGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:employment_DeleteGroup', data)
    cb("ok")
end)


RegisterNUICallback('employment_CheckPlayerNames', function(data, cb) --employment
    QBCore.Functions.TriggerCallback('qb-phone:server:employment_CheckPlayerNames', function(HasName)
        cb(HasName)
    end, data.id)
end)