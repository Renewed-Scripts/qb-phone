local QBCore = exports['qb-core']:GetCoreObject()



-- exports['qb-phone']:RemoveCrypto(Player, type, amount)
local function RemoveCrypto(Player, type, amount)
    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata[type]

    if not Crypto then return end

    Player.Functions.SetMetaData(type, (Crypto - amount))
end exports("RemoveCrypto", RemoveCrypto)


-- exports['qb-phone']:AddCrypto(Player, type, amount)
local function AddCrypto(Player, type, amount)
    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata[type]

    if not Crypto then return end

    Player.Functions.SetMetaData(type, (Crypto + amount))
end exports("AddCrypto", AddCrypto)

local function GetConfig(metadata)
    for k, v in pairs(Config.CryptoCoins) do
        if v.metadata == metadata then
            return v
        end
    end
end

RegisterNetEvent('qb-phone:server:PurchaseCrypto', function(type, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local v = Config.CryptoCoins[GetConfig(type)]
    local cashAmount = amount * v.value

    if Player.PlayerData.money.bank and Player.PlayerData.money.bank >= cashAmount then
        Player.Functions.RemoveMoney('bank', cashAmount, "Crypto Purchased: "..v.abbrev)
        AddCrypto(Player, type, amount)
    end
end)