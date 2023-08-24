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

    local blip
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
    local getGroups = lib.callback.await('qb-phone:server:getAllGroups', false)
    cb(getGroups)
end)

RegisterNetEvent('qb-phone:client:RefreshGroupsApp', function(Groups, finish)
    if finish then inJob = false end
    if inJob then return end
    SendNUIMessage({
        action = "refreshApp",
        data = Groups,
    })
end)


RegisterNetEvent('qb-phone:client:AddGroupStage', function(_, stage)
    inJob = true
    SendNUIMessage({
        action = "addGroupStage",
        status =  stage
    })
end)


RegisterNUICallback('jobcenter_CreateJobGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:jobcenter_CreateJobGroup', data)
    cb("ok")
end)

RegisterNUICallback('jobcenter_JoinTheGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:jobcenter_JoinTheGroup', data)
    cb("ok")
end)

RegisterNUICallback('jobcenter_leave_grouped', function(data, cb) --employment
    if not data then return end
    local success = exports['qb-phone']:PhoneNotification("Job Center", 'Are you sure you want to leave the group?', 'fas fa-users', '#FFBF00', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        TriggerServerEvent('qb-phone:server:jobcenter_leave_grouped', data)
    end
    cb("ok")
end)

RegisterNUICallback('jobcenter_DeleteGroup', function(data, cb) --employment
    TriggerServerEvent('qb-phone:server:jobcenter_DeleteGroup', data)
    cb("ok")
end)


RegisterNUICallback('jobcenter_CheckPlayerNames', function(data, cb) --employment
    local HasName = lib.callback.await('qb-phone:server:jobcenter_CheckPlayerNames', false, data.id)
    cb(HasName)
end)