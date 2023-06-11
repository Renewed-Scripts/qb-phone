-- NUI Callback

RegisterNUICallback('AcceptMailButton', function(data, cb)
    if data.buttonEvent or data.buttonData then
        if data.isServer then
            TriggerServerEvent(data.buttonEvent, data.buttonData)
        else
            TriggerEvent(data.buttonEvent, data.buttonData)
        end
    end

    TriggerServerEvent('qb-phone:server:ClearButtonData', data.mailId)
    cb('ok')
end)

RegisterNUICallback('GetMails', function(_, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local MailId = data.mailId
    TriggerServerEvent('qb-phone:server:RemoveMail', MailId)
    cb('ok')
end)

-- Events

RegisterNetEvent('qb-phone:client:NewMailNotify', function(MailData)
    TriggerEvent('qb-phone:client:CustomNotification',
        "Mail",
        "New E-Mail from: "..MailData.sender,
        "fas fa-envelope",
        "ff002f",
        1500
    )

    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
end)

RegisterNetEvent('qb-phone:client:UpdateMails', function(NewMails)

    PhoneData.Mails = {}

    for _, v in pairs(NewMails) do
        PhoneData.Mails[#PhoneData.Mails+1] = {
            citizenid = v.citizenid,
            sender = v.sender,
            subject = v.subject,
            message = v.message,
            read = v.read,
            mailid = v.mailId,
            date = v.date,
            button = type(v.button) == "string" and json.decode(v.button) or v.button
        }
    end

    PhoneData.Mails = NewMails

    SendNUIMessage({
        action = "UpdateMails",
        Mails = NewMails
    })
end)