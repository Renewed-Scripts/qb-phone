local CasinoTable = {}
local BetNumber = 0

RegisterNetEvent('qb-phone:server:CasinoAddBet', function(data)
    BetNumber += 1
    CasinoTable[BetNumber] = {['Name'] = data.name, ['chanse'] = data.chanse, ['id'] = BetNumber}
    TriggerClientEvent('qb-phone:client:addbetForAll', -1, CasinoTable)
end)

local CasinoBetList = {}
local casino_status = true

RegisterNetEvent('qb-phone:server:BettingAddToTable', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = tonumber(data.amount)
    local CSN = Player.PlayerData.citizenid
    if casino_status then
        if Player.PlayerData.money.bank >= amount then
            if not CasinoBetList[CSN] then
                Player.Functions.RemoveMoney('bank', amount, "casino betting")
                CasinoBetList[CSN] = {['csn'] = CSN, ['amount'] = amount, ['player'] = data.player, ['chanse'] = data.chanse, ['id'] = data.id}
            else
                TriggerClientEvent('QBCore:Notify', src, "You are already betting...", "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "You do not have enough money!", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Betting is not active...", "error")
    end
end)

RegisterNetEvent('qb-phone:server:DeleteAndClearTable', function()
    local src = source
    CasinoTable = {}
    CasinoBetList = {}
    BetNumber = 0
    TriggerClientEvent('qb-phone:client:addbetForAll', -1, CasinoTable)
    TriggerClientEvent('QBCore:Notify', src, "Done", "primary")
end)

lib.callback.register('qb-phone:server:CheckHasBetTable', function(_)
    return CasinoTable
end)


RegisterNetEvent('qb-phone:server:casino_status', function()
    casino_status = not casino_status
end)

lib.callback.register('qb-phone:server:CheckHasBetStatus', function(_)
    return casino_status
end)

RegisterNetEvent('qb-phone:server:WineridCasino', function(data)
    local Winer = data.id
    for _, v in pairs(CasinoBetList) do
        if v.id == Winer then
            local OtherPly = QBCore.Functions.GetPlayerByCitizenId(v.csn)
            if OtherPly then
                local amount = v.amount * v.chanse
                OtherPly.Functions.AddMoney('bank', tonumber(amount), "Casino Winner")
            end
        end
    end
end)