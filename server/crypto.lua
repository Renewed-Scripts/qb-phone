local QBCore = exports['qb-core']:GetCoreObject()



-- exports['qb-phone']:RemoveCrypto(Player, type, amount)
local function RemoveCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata.crypto

    if not Crypto then return end
    if Crypto[type] - tonumber(amount) > 0 then
        Crypto[type] = Crypto[type] - tonumber(amount)
        Player.Functions.SetMetaData("crypto", Crypto)
        return true
    else
        return false
    end
end exports("RemoveCrypto", RemoveCrypto)


-- exports['qb-phone']:AddCrypto(Player, type, amount)
local function AddCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata.crypto

    if not Crypto then return end
    Crypto[type] = Crypto[type] + tonumber(amount)
    Player.Functions.SetMetaData("crypto", Crypto)
end exports("AddCrypto", AddCrypto)

local function GetConfig(metadata)
    for k, v in pairs(Config.CryptoCoins) do
        if v.metadata == metadata then
            return k
        end
    end
end

RegisterNetEvent('qb-phone:server:PurchaseCrypto', function(type, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.metadata.crypto[type] then return end -- if the crypto dosnt exist
    local v = Config.CryptoCoins[GetConfig(type)]
    local cashAmount = tonumber(amount) * v.value

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