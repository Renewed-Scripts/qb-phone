-- exports['qb-phone']:RemoveCrypto(Player, type, amount)
local function RemoveCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata.crypto
    if not Crypto then return end
    amount =  tonumber(amount)
    if amount < 1 then return false end

    if (Crypto[type] - amount) >= 0 then
        Crypto[type] -= amount
        Player.Functions.SetMetaData("crypto", Crypto)
        TriggerClientEvent('qb-phone:client:UpdateCrypto', src)
        return true
    else
        return false
    end
end exports("RemoveCrypto", RemoveCrypto)


-- exports['qb-phone']:hasEnough(Player, type, amount)
local function hasEnough(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return end

    local Crypto = Player.PlayerData.metadata.crypto

    if not Crypto then return end
    if Crypto[type] - tonumber(amount) >= 0 then
        return true
    else
        return false
    end
end exports("hasEnough", hasEnough)


-- exports['qb-phone']:AddCrypto(Player, type, amount)
local function AddCrypto(src, type, amount)
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not type or not amount then return false end

    local Crypto = Player.PlayerData.metadata.crypto

    if not Crypto then return false end
    Crypto[type] = Crypto[type] + tonumber(amount)
    Player.Functions.SetMetaData("crypto", Crypto)
    TriggerClientEvent('qb-phone:client:UpdateCrypto', src)

    return true
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

    if not v.purchase then return end -- Only modders should be only to do this so no need to send a message to client

    local txt = "Purchased " .. amount .. "x " .. v.abbrev

    if Player.PlayerData.money.bank >= cashAmount then
        Player.Functions.RemoveMoney('bank', cashAmount, txt)
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "WALLET",
            "You Purchased "..amount.." "..type.."!",
            "fas fa-chart-line",
            "#D3B300",
            7500
        )

        if Config.RenewedBanking then
            local cid = Player.PlayerData.citizenid
            local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            exports['Renewed-Banking']:handleTransaction(cid, "Crypto Purchase", cashAmount, txt, "Los Santos Crypto", name, "withdraw")
        end

        AddCrypto(src, type, amount)
    else
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "WALLET",
            "Not Enough Money",
            "fas fa-chart-line",
            "#D3B300",
            7500
        )
    end
end)

RegisterNetEvent('qb-phone:server:SellCrypto', function(type, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.metadata.crypto[type] then return end -- if the crypto dosnt exist
    local v = Config.CryptoCoins[GetConfig(type)]
    local cryptoAmount = tonumber(amount) * v.value

    if not v.sell then return end -- Only modders should be only to do this so no need to send a message to client
    
    local txt = "Sold " .. amount .. "x " .. v.abbrev
    
    if not RemoveCrypto(src, type, amount) then return end

        Player.Functions.AddMoney('bank', cryptoAmount, txt)
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "WALLET",
            "You Sold "..amount.." "..type.."!",
            "fas fa-chart-line",
            "#D3B300",
            7500
        )

        if Config.RenewedBanking then
            local cid = Player.PlayerData.citizenid
            local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            exports['Renewed-Banking']:handleTransaction(cid, "Sold Crypto", cryptoAmount, txt, "Los Santos Crypto", name, "deposit")
        end
end)

RegisterNetEvent('qb-phone:server:ExchangeCrypto', function(type, amount, stateid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Receiver = QBCore.Functions.GetPlayer(tonumber(stateid))
    if not Player or not Player.PlayerData.metadata.crypto[type] then return end -- if the crypto dosnt exist
    if not Receiver then return TriggerClientEvent("QBCore:Notify", src, 'This state id does not exists!', "error") end

    if Player.PlayerData.citizenid ~= Receiver.PlayerData.citizenid then
        if RemoveCrypto(src, type, amount) then
            TriggerClientEvent('qb-phone:client:CustomNotification', src,
                "WALLET",
                "You sent "..amount.." "..type.."!",
                "fas fa-chart-line",
                "#D3B300",
                7500
            )

            AddCrypto(Receiver.PlayerData.source, type, amount)
            TriggerClientEvent('qb-phone:client:CustomNotification', Receiver.PlayerData.source,
                "WALLET",
                "You received "..amount.." "..type.."!",
                "fas fa-chart-line",
                "#D3B300",
                7500
            )
        else
            TriggerClientEvent('qb-phone:client:CustomNotification', src,
                "WALLET",
                "Cannot transfer crypto!",
                "fas fa-chart-line",
                "#D3B300",
                7500
            )

        end
    else
        TriggerClientEvent('qb-phone:client:CustomNotification', src,
            "WALLET",
            "Cannot send crypto to yourself!",
            "fas fa-chart-line",
            "#D3B300",
            7500
        )
    end
end)
