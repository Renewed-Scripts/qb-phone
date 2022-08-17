local QBCore = exports['qb-core']:GetCoreObject()

-- QBCore.Functions.CreateUseableItem(Config.PhoneHackItem, function(source, item)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(source)

--     if Player.Functions.GetItemByName(Config.PhoneHackItem) then
--         if Player.Functions.GetItemByName('phone') then
--             TriggerClientEvent('qb-phone:client:TriggerPhoneHack', src)
--         else
--             TriggerClientEvent('QBCore:Notify', src, "You don't have a phone to use this on.", "error")
--         end
--     end
-- end)

RegisterNetEvent('qb-phone:server:HackPhone', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem('phone', 1)
    Player.Functions.AddItem('phone', 1, false, {hacked = true})

    TriggerClientEvent('QBCore:Notify', src, "Your phone is now jailbroken.", "success")
end)

QBCore.Functions.CreateCallback('qb-phone:server:hasHackedPhone', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local phones = Player.Functions.GetItemsByName('phone')
    local isHacked = false

    if phones then
        for _, phone in pairs(phones) do
            if phone.info.hacked then
                isHacked = true

                break
            end
        end
    else
        cb(false)
    end

    cb(isHacked)
end)

