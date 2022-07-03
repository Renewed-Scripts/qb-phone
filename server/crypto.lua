local QBCore = exports['qb-core']:GetCoreObject()



-- exports['qb-phone']:RemoveCrypto(Player, type, amount)
local function RemoveCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata[type]

    if not Crypto then return end

    Player.Functions.SetMetaData(type, (Crypto - amount))
end exports("RemoveCrypto", RemoveCrypto)


-- exports['qb-phone']:AddCrypto(Player, type, amount)
local function AddCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata[type]

    if not Crypto then return end

    Player.Functions.SetMetaData(type, (Crypto + amount))
end exports("AddCrypto", AddCrypto)

local function GetConfig(metadata)
    for _, v in pairs(Config.CryptoCoins) do
        if v.metadata == metadata then
            return v
        end
    end
end

RegisterNetEvent('qb-phone:server:PurchaseCrypto', function(type, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.metadata[type] then return end -- if the crypto dosnt exist

    local v = Config.CryptoCoins[GetConfig(type)]
    local cashAmount = amount * v.value

    if Player.PlayerData.money.bank and Player.PlayerData.money.bank >= cashAmount then
        Player.Functions.RemoveMoney('bank', cashAmount, "Crypto Purchased: "..v.abbrev)
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "Purchased Crypto",
            "You Purchased "..amount.." "..type.." Crypto",
            "fas fa-check-circle",
            "#0074FF",
            7500
        )
        AddCrypto(src, type, amount)
    else
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "Error",
            "Not Enough Money",
            "fas fa-dollar-sign",
            "#FF0000",
            7500
        )
    end
end)