local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-phone:server:SetJobJobCenter', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if Player.Functions.SetJob(data.job, 0) then
        TriggerClientEvent('QBCore:Notify', src, 'Changed your job to: '..data.label, "primary")
    else
        TriggerClientEvent('QBCore:Notify', src, 'Invalid Job...', "error")
    end
end)