-- Functions

local function GenerateMailId()
    return math.random(111111, 999999)
end



RegisterNetEvent('qb-phone:server:RemoveMail', function(MailId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not MailId or not Player then return end

    local CID = Player.PlayerData.citizenid


    MySQL.query('DELETE FROM player_mails WHERE mailid = ? AND citizenid = ?', {MailId, CID})
    SetTimeout(100, function()
        local mails = MySQL.query.await('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {CID})
        TriggerClientEvent('qb-phone:client:UpdateMails', src, mails)
    end)
end)


RegisterNetEvent('qb-phone:server:sendNewMail', function(mailData, citizenID)

    if not mailData or not mailData.sender or not mailData.subject or not mailData.message then return end
    local Player

    if citizenID then
        Player = QBCore.Functions.GetPlayerByCitizenId(citizenID)
    else
        Player = QBCore.Functions.GetPlayer(source)
    end

    if Player then
        local CID = Player.PlayerData.citizenid
        if mailData.button then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {CID, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {CID, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        end

        TriggerClientEvent('qb-phone:client:NewMailNotify', Player.PlayerData.source, mailData)

        SetTimeout(200, function()
            local mails = MySQL.query.await('SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {CID})
            if mails[1] then
                for _, v in pairs(mails) do
                    if v.button then
                        v.button = json.decode(v.button)
                    end
                end
            end

            TriggerClientEvent('qb-phone:client:UpdateMails', Player.PlayerData.source, mails)
        end)
    elseif citizenID then
        if mailData.button then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {citizenID, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {citizenID, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        end
    end
end)

function sendNewMailToOffline(citizenid, mailData)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player then
        local src = Player.PlayerData.source
        if mailData.button == nil then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {Player.PlayerData.citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
            TriggerClientEvent('qb-phone:client:NewMailNotify', src, mailData)
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {Player.PlayerData.citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
            TriggerClientEvent('qb-phone:client:NewMailNotify', src, mailData)
        end
        SetTimeout(200, function()
            local mails = MySQL.query.await(
                'SELECT * FROM player_mails WHERE citizenid = ? ORDER BY `date` ASC', {Player.PlayerData.citizenid})
            if mails[1] ~= nil then
                for k, _ in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end

            TriggerClientEvent('qb-phone:client:UpdateMails', src, mails)
        end)
    else
        if mailData.button == nil then
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0})
        else
            MySQL.insert('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (?, ?, ?, ?, ?, ?, ?)', {citizenid, mailData.sender, mailData.subject, mailData.message, GenerateMailId(), 0, json.encode(mailData.button)})
        end
    end
end
exports("sendNewMailToOffline",sendNewMailToOffline)