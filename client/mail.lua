-- NUI Callback

RegisterNUICallback('AcceptMailButton', function(data, cb)
    if data.buttonEvent or data.buttonData then
        TriggerEvent(data.buttonEvent, data.buttonData)
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
    SendNUIMessage({
        action = "UpdateMails",
        Mails = NewMails
    })
    PhoneData.Mails = NewMails
end)