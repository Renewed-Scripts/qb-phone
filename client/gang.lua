local QBCore = exports['qb-core']:GetCoreObject()
local PlayerGang = QBCore.Functions.GetPlayerData().gang

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = QBCore.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

-- NUI Callbacks
RegisterNUICallback('GetGangMembers', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetGangMembers', function(members)
        cb(members)
    end, PlayerGang.name)
end)

RegisterNUICallback('Removegangmember', function(data, cb)
    if not data or not data.cid then return end

    TriggerServerEvent('qb-phone:server:YeetMember', data.cid)

    cb("ok")
end)

RegisterNUICallback('ChangeGangRole', function(data, cb)
    if not data then return end

    TriggerServerEvent('qb-phone:server:ManageGangMembers', data.gang, tostring(data.cid), data.grade)
    cb("ok")
end)

RegisterNUICallback('HireGangMember', function(data, cb)
    if not data then return end
    if not data.gang or not data.stateid or not data.grade then return end
    TriggerServerEvent('qb-phone:server:HireGangMember', data.gang, data.stateid, data.grade)

    cb("ok")
end)
