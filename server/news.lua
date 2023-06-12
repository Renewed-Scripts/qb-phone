local LSBNTable = {}
local LSBNTableID = 0

RegisterNetEvent('qb-phone:server:Send_lsbn_ToChat', function(data)
    LSBNTableID = LSBNTableID + 1
    if data.Type == "Text" then
        LSBNTable[LSBNTableID] = {['Text'] = data.Text, ['Image'] = "none", ['ID'] = LSBNTableID, ['Type'] = data.Type, ['Time'] = data.Time,}
    elseif data.Type == "Image" then
        LSBNTable[LSBNTableID] = {['Text'] = data.Text, ['Image'] = data.Image, ['ID'] = LSBNTableID, ['Type'] = data.Type, ['Time'] = data.Time,}
    end
    local Tables = {
        {
            ['Text'] = data.Text, ['Image'] = data.Image, ['ID'] = LSBNTableID, ['Type'] = data.Type, ['Time'] = data.Time,
        },
    }
    TriggerClientEvent('qb-phone:LSBN-reafy-for-add', -1, Tables, true, data.Text)
end)

RegisterNetEvent('qb-phone:server:GetLSBNchats', function()
    local src = source
    TriggerClientEvent('qb-phone:LSBN-reafy-for-add', src, LSBNTable, false, nil)
end)