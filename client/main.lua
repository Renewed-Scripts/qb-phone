local QBCore = exports['qb-core']:GetCoreObject()

--- Global Variables ---
PlayerData = QBCore.Functions.GetPlayerData()

local frontCam = false

FullyLoaded = LocalPlayer.state.isLoggedIn

PhoneData = {
    MetaData = {},
    isOpen = false,
    PlayerData = nil,
    Contacts = {},
    Tweets = {},
    Hashtags = {},
    Chats = {},
    CallData = {},
    RecentCalls = {},
    Invoices = {},
    Garage = {},
    Mails = {},
    Adverts = {},
    Documents = {},
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    Images = {},
    ChatRooms = {},
}




-- Localized Variables --
local CallVolume = 0.2


-- Functions

local function IsNumberInContacts(num)
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            return v.name
        end
    end

    return "Unknown"
end

local function hasPhone()
    if PlayerData.items then
        for _, v in pairs(PlayerData.items) do
            if v.name == 'phone' then
                return true
            end
        end
    end
end exports('hasPhone', hasPhone)

local function CalculateTimeToDisplay()
	local hour = GetClockHours()
    local minute = GetClockMinutes()

    local obj = {}

	if minute <= 9 then
		minute = "0" .. minute
    end

    obj.hour = hour
    obj.minute = minute

    return obj
end

local function updateTime()
    while PhoneData.isOpen do
        SendNUIMessage({
            action = "UpdateTime",
            InGameTime = CalculateTimeToDisplay(),
        })
        Wait(1500)
    end
end

local PublicPhoneobject = {
    -2103798695,1158960338,
    1281992692,1511539537,
    295857659,-78626473,
    -1559354806
}

exports["qb-target"]:AddTargetModel(PublicPhoneobject, {
    options = {
        {
            type = "client",
            event = "qb-phone:client:publocphoneopen",
            icon = "fas fa-phone-alt",
            label = "Public Phone",
        },
    },
    distance = 1.0
})


local function LoadPhone()
    QBCore.Functions.TriggerCallback('qb-phone:server:GetPhoneData', function(pData)

        -- Should fix errors with phone not loading correctly --
        while pData == nil do Wait(25) end

        PhoneData.PlayerData = PlayerData
        local PhoneMeta = PhoneData.PlayerData.metadata["phone"]
        PhoneData.MetaData = PhoneMeta

        PhoneData.MetaData.profilepicture = PhoneMeta.profilepicture or "default"

        if pData.PlayerContacts and next(pData.PlayerContacts) then
            PhoneData.Contacts = pData.PlayerContacts
        end

        if pData.Chats and next(pData.Chats) then
            local Chats = {}
            for _, v in pairs(pData.Chats) do
                Chats[v.number] = {
                    name = IsNumberInContacts(v.number),
                    number = v.number,
                    messages = json.decode(v.messages)
                }
            end

            PhoneData.Chats = Chats
        end

        if pData.Hashtags and next(pData.Hashtags) then
            PhoneData.Hashtags = pData.Hashtags
        end

        if pData.Invoices and next(pData.Invoices) then
            for _, v in pairs(pData.Invoices) do
                PhoneData.Invoices[#PhoneData.Invoices+1] = {
                    id = v.id,
                    citizenid = QBCore.Functions.GetPlayerData().citizenid,
                    sender = v.name,
                    society = v.job,
                    sendercitizenid = v.senderCID,
                    amount = v.amount
                }
            end
        end

        if pData.Tweets and next(pData.Tweets) then
            PhoneData.Tweets = pData.Tweets
        end

        if pData.Documents and next(pData.Documents) then
            PhoneData.Documents = pData.Documents
        end

        if pData.Mails and next(pData.Mails) then
            for _, v in pairs(pData.Mails) do
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
        end

        if pData.Adverts and next(pData.Adverts) then
            PhoneData.Adverts = pData.Adverts
        end


        if pData.Images and next(pData.Images) then
            PhoneData.Images = pData.Images
        end

        if pData.ChatRooms ~= nil and next(pData.ChatRooms) ~= nil then
            PhoneData.ChatRooms = pData.ChatRooms
        end

        SendNUIMessage({
            action = "LoadPhoneData",
            PhoneData = PhoneData,
            PlayerData = PlayerData,
            PlayerJob = PlayerData,
            PhoneJobs = QBCore.Shared.Jobs,
            applications = Config.PhoneApplications,
            PlayerId = GetPlayerServerId(PlayerId())
        })

    end)
end
local function DisableDisplayControlActions()
    DisableControlAction(0, 1, true) -- disable mouse look
    DisableControlAction(0, 2, true) -- disable mouse look
    DisableControlAction(0, 3, true) -- disable mouse look
    DisableControlAction(0, 4, true) -- disable mouse look
    DisableControlAction(0, 5, true) -- disable mouse look
    DisableControlAction(0, 6, true) -- disable mouse look
    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee
    DisableControlAction(0, 177, true) -- disable escape
    DisableControlAction(0, 200, true) -- disable escape
    DisableControlAction(0, 202, true) -- disable escape
    DisableControlAction(0, 322, true) -- disable escape
    DisableControlAction(0, 245, true) -- disable chat
end

local function OpenPhone()
    if hasPhone() then
        PhoneData.PlayerData = PlayerData
        SetNuiFocus(true, true)
        
        SendNUIMessage({
            action = "open",
            Tweets = PhoneData.Tweets,
            AppData = Config.PhoneApplications,
            CallData = PhoneData.CallData,
            PlayerData = PhoneData.PlayerData,
        })
        PhoneData.isOpen = true
        if Config.AllowWalking then
        SetNuiFocusKeepInput(true)
        CreateThread(function()
            while PhoneData.isOpen do
                DisableDisplayControlActions()
                Wait(1)
            end
        end)
    end
        if not PhoneData.CallData.InCall then
            DoPhoneAnimation('cellphone_text_in')
        else
            DoPhoneAnimation('cellphone_call_to_text')
        end

        SetTimeout(250, function()
            newPhoneProp()
        end)

        updateTime()
    else
        QBCore.Functions.Notify("You don't have a phone?", "error")
    end
end

local function GenerateCallId(caller, target)
    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
    return CallId
end

local function CancelCall()
    TriggerServerEvent('qb-phone:server:CancelCall', PhoneData.CallData)
    if PhoneData.CallData.CallType == "ongoing" then
        exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}
    PhoneData.CallData.CallId = nil

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
    end
    PhoneData.AnimationData.lib = nil
    PhoneData.AnimationData.anim = nil

    TriggerServerEvent('qb-phone:server:SetCallState', false)

    SendNUIMessage({
        action = "SetupHomeCall",
        CallData = PhoneData.CallData,
    })

    SendNUIMessage({
        action = "CancelOutgoingCall",
    })

    TriggerEvent('qb-phone:client:CustomNotification',
        "PHONE CALL",
        "Disconnected...",
        "fas fa-phone-square",
        "#e84118",
        5000
    )
end

local function CallCheck()
    if PhoneData.CallData.CallType == "ongoing" then
        if not hasPhone() or PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] or PlayerData.metadata['ishandcuffed'] then
            CancelCall()
        end
    end
end

local function CallContact(CallData, AnonymousCall)
    local RepeatCount = 0
    PhoneData.CallData.CallType = "outgoing"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.charinfo.phone, CallData.number)

    TriggerServerEvent('qb-phone:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
    TriggerServerEvent('qb-phone:server:SetCallState', true)

    for _ = 1, Config.CallRepeats, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount ~= Config.CallRepeats then
                if PhoneData.CallData.InCall then
                    RepeatCount += 1
                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "dialing", 0.1)
                else
                    break
                end
                Wait(Config.RepeatTimeout)
            else
                CancelCall()
                break
            end
        else
            break
        end
    end
end

local function AnswerCall()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('qb-phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        CreateThread(function()
            while PhoneData.CallData.AnsweredCall do
                PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                Wait(2000)
                SendNUIMessage({
                    action = "UpdateCallTime",
                    Time = PhoneData.CallData.CallTime,
                    Name = PhoneData.CallData.TargetData.name,
                })

                Wait(1000)
            end
        end)

        TriggerServerEvent('qb-phone:server:AnswerCall', PhoneData.CallData)
        exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        TriggerEvent('qb-phone:client:CustomNotification',
            "Phone",
            "You don't have an incoming call...",
            "fas fa-phone",
            "#e84118",
            4500
        )
    end
end

local function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

-- Command

RegisterCommand('phone', function()
    if not PhoneData.isOpen then
        if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() then
            OpenPhone()
        else
            QBCore.Functions.Notify("Action not available at the moment..", "error")
        end
    end
end) RegisterKeyMapping('phone', 'Open Phone', 'keyboard', 'M')

RegisterCommand("+answer", function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing" and not PhoneData.CallData.CallType == "ongoing") then
        if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() and hasPhone() then
            AnswerCall()
        else
            QBCore.Functions.Notify("Action not available at the moment..", "error")
        end
    end
end) RegisterKeyMapping('+answer', 'Answer Phone Call', 'keyboard', 'Y')

RegisterCommand("+decline", function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing" or PhoneData.CallData.CallType == "ongoing") then
        if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() then
            CancelCall()
        else
            QBCore.Functions.Notify("Action not available at the moment..", "error")
        end
    end
end) RegisterKeyMapping('+decline', 'Decline Phone Call', 'keyboard', 'J')

-- NUI Callbacks

RegisterNUICallback('DissalowMoving', function()
    if not Config.AllowWalking then return end
    SetNuiFocusKeepInput(false)
end)

RegisterNUICallback('AllowMoving', function()
    if not Config.AllowWalking then return end
    SetNuiFocusKeepInput(true)
end)


RegisterNUICallback('CancelOutgoingCall', function()
    CancelCall()
end)

RegisterNUICallback('DenyIncomingCall', function()
    CancelCall()
end)

RegisterNUICallback('CancelOngoingCall', function()
    CancelCall()
end)

RegisterNUICallback('AnswerCall', function()
    AnswerCall()
end)

RegisterNUICallback('ClearRecentAlerts', function(_, cb)
    Config.PhoneApplications["phone"].Alerts = 0
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    cb('ok')
end)

RegisterNUICallback('SetBackground', function(data, cb)
    local background = data.background
    PhoneData.MetaData.background = background
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
    cb('ok')
end)

RegisterNUICallback('GetMissedCalls', function(_, cb)
    cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('HasPhone', function(_, cb)
    cb(hasPhone())
end)

RegisterNUICallback('Close', function()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetTimeout(300, function()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        PhoneData.isOpen = false
    end)
end)

RegisterNUICallback('AddNewContact', function(data, cb)
    PhoneData.Contacts[#PhoneData.Contacts+1] = {
        name = data.ContactName,
        number = data.ContactNumber,
    }
    Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[data.ContactNumber] and next(PhoneData.Chats[data.ContactNumber]) then
        PhoneData.Chats[data.ContactNumber].name = data.ContactName
    end
    TriggerServerEvent('qb-phone:server:AddNewContact', data.ContactName, data.ContactNumber)
end)

RegisterNUICallback('EditContact', function(data, cb)
    local NewName = data.CurrentContactName
    local NewNumber = data.CurrentContactNumber
    local OldName = data.OldContactName
    local OldNumber = data.OldContactNumber

    for _, v in pairs(PhoneData.Contacts) do
        if v.name == OldName and v.number == OldNumber then
            v.name = NewName
            v.number = NewNumber
        end
    end
    if PhoneData.Chats[NewNumber] and next(PhoneData.Chats[NewNumber]) then
        PhoneData.Chats[NewNumber].name = NewName
    end
    Wait(100)
    cb(PhoneData.Contacts)
    TriggerServerEvent('qb-phone:server:EditContact', NewName, NewNumber, OldName, OldNumber)
end)

RegisterNUICallback('UpdateProfilePicture', function(data, cb)
    local pf = data.profilepicture
    PhoneData.MetaData.profilepicture = pf
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
    cb('ok')
end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:FetchResult', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('DeleteContact', function(data, cb)
    local Name = data.CurrentContactName
    local Number = data.CurrentContactNumber

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == Name and v.number == Number then
            table.remove(PhoneData.Contacts, k)

            TriggerEvent('qb-phone:client:CustomNotification',
                "Phone",
                "Contact deleted!",
                "fa fa-phone-alt",
                "#04b543",
                1500
            )

            break
        end
    end
    Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[Number] and next(PhoneData.Chats[Number]) then
        PhoneData.Chats[Number].name = Number
    end
    TriggerServerEvent('qb-phone:server:RemoveContact', Name, Number)
end)

RegisterNUICallback('ClearGeneralAlerts', function(data, cb)
    SetTimeout(400, function()
        Config.PhoneApplications[data.app].Alerts = 0
        SendNUIMessage({
            action = "RefreshAppAlerts",
            AppData = Config.PhoneApplications
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
        cb('ok')
    end)
end)

RegisterNUICallback('CallContact', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCallState', function(CanCall, IsOnline)
        local status = {
            CanCall = CanCall,
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        cb(status)
        if CanCall and not status.InCall then
            CallContact(data.ContactData, data.Anonymous)
        end
    end, data.ContactData)
end)

RegisterNUICallback("TakePhoto", function(_, cb)
    SetNuiFocus(false, false)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    while true do
        if IsControlJustPressed(1, 27) then
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 177) then
            DestroyMobilePhone()
            CellCamActivate(false, false)
            cb(json.encode({ url = nil }))
            OpenPhone()
            break
        elseif IsControlJustPressed(1, 176) then
            QBCore.Functions.TriggerCallback("qb-phone:server:GetWebhook",function(hook)
                QBCore.Functions.Notify('Touching up photo...', 'primary')
                exports['screenshot-basic']:requestScreenshotUpload(tostring(hook), "files[]", function(uploadData)
                    local image = json.decode(uploadData)
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    TriggerServerEvent('qb-phone:server:addImageToGallery', image.attachments[1].proxy_url)
                    Wait(400)
                    TriggerServerEvent('qb-phone:server:getImageFromGallery')
                    cb(json.encode(image.attachments[1].proxy_url))
                    QBCore.Functions.Notify('Photo saved!', "success")
                    OpenPhone()
                end)
            end)
            break
        end
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
        EnableAllControlActions(0)
        Wait(0)
    end
end)

-- Events

RegisterNetEvent('qb-phone:client:AddRecentCall', function(data, time, type)
    PhoneData.RecentCalls[#PhoneData.RecentCalls+1] = {
        name = IsNumberInContacts(data.number),
        time = time,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    }
    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
end)

RegisterNetEvent('qb-phone:client:CancelCall', function()
    if PhoneData.CallData.CallType == "ongoing" then
        SendNUIMessage({
            action = "CancelOngoingCall"
        })
        exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
    end
    PhoneData.AnimationData.lib = nil
    PhoneData.AnimationData.anim = nil

    TriggerServerEvent('qb-phone:server:SetCallState', false)

    SendNUIMessage({
        action = "SetupHomeCall",
        CallData = PhoneData.CallData,
    })

    SendNUIMessage({
        action = "CancelOutgoingCall",
    })

    TriggerEvent('qb-phone:client:CustomNotification',
        "PHONE CALL",
        "Disconnected...",
        "fas fa-phone-square",
        "#e84118",
        5000
    )
end)

RegisterNUICallback('phone-silent-button', function(_, cb)
    if CallVolume == tonumber("0.2") then
        CallVolume = 0
        QBCore.Functions.Notify("Silent Mode On", "success")
        cb(true)
    else
        CallVolume = 0.2
        QBCore.Functions.Notify("Silent Mode Off", "error")
        cb(false)
    end
end)

RegisterNetEvent('qb-phone:client:GetCalled', function(CallerNumber, CallId, AnonymousCall)
    local RepeatCount = 0
    local CallData = {
        number = CallerNumber,
        name = IsNumberInContacts(CallerNumber),
        anonymous = AnonymousCall
    }
    if hasPhone() then
        if AnonymousCall then
            CallData.name = "UNKNOWN CALLER"
        end

        PhoneData.CallData.CallType = "incoming"
        PhoneData.CallData.InCall = true
        PhoneData.CallData.AnsweredCall = false
        PhoneData.CallData.TargetData = CallData
        PhoneData.CallData.CallId = CallId

        TriggerServerEvent('qb-phone:server:SetCallState', true)

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        for _ = 1, Config.CallRepeats + 1, 1 do
            if not PhoneData.CallData.AnsweredCall then
                if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                    if PhoneData.CallData.InCall then
                        RepeatCount = RepeatCount + 1
                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "ringing", CallVolume)

                        if not PhoneData.isOpen then
                            SendNUIMessage({
                                action = "IncomingCallAlert",
                                CallData = PhoneData.CallData.TargetData,
                                Canceled = false,
                                AnonymousCall = AnonymousCall,
                            })
                        end
                    else
                        SendNUIMessage({
                            action = "IncomingCallAlert",
                            CallData = PhoneData.CallData.TargetData,
                            Canceled = true,
                            AnonymousCall = AnonymousCall,
                        })
                        TriggerServerEvent('qb-phone:server:AddRecentCall', "missed", CallData)
                        break
                    end
                    Wait(Config.RepeatTimeout)
                else
                    SendNUIMessage({
                        action = "IncomingCallAlert",
                        CallData = PhoneData.CallData.TargetData,
                        Canceled = true,
                        AnonymousCall = AnonymousCall,
                    })
                    TriggerServerEvent('qb-phone:server:AddRecentCall', "missed", CallData)
                    break
                end
            else
                TriggerServerEvent('qb-phone:server:AddRecentCall', "missed", CallData)
                break
            end
        end
    else
        SendNUIMessage({
            action = "IncomingCallAlert",
            CallData = PhoneData.CallData.TargetData,
            Canceled = true,
            AnonymousCall = AnonymousCall,
        })
        TriggerServerEvent('qb-phone:server:AddRecentCall', "missed", CallData)
    end
end)

RegisterNetEvent('qb-phone:client:AnswerCall', function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('qb-phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        CreateThread(function()
            while PhoneData.CallData.AnsweredCall do
                PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                SendNUIMessage({
                    action = "UpdateCallTime",
                    Time = PhoneData.CallData.CallTime,
                    Name = PhoneData.CallData.TargetData.name,
                })

                Wait(1000)
            end
        end)
        exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        TriggerEvent('qb-phone:client:CustomNotification',
            "Phone",
            "You don't have an incoming call...",
            "fas fa-phone",
            "#e84118",
            2500
        )
    end
end)

-- Handler Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    FullyLoaded = true
    Wait(250)
    LoadPhone()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    FullyLoaded = false
    PlayerData = {}
    PhoneData = {
        Documents = {},
        MetaData = {},
        isOpen = false,
        PlayerData = nil,
        Contacts = {},
        Tweets = {},
        Hashtags = {},
        Chats = {},
        CallData = {},
        RecentCalls = {},
        Garage = {},
        Mails = {},
        Adverts = {},
        GarageVehicles = {},
        AnimationData = {
            lib = nil,
            anim = nil,
        },
    }
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    PlayerData = val
    Wait(250)
    CallCheck()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    SendNUIMessage({
        action = "UpdateApplications",
        JobData = JobInfo,
        applications = Config.PhoneApplications
    })
end)

RegisterNetEvent('qb-phone:client:clearAppAlerts', function()
    Config.PhoneApplications["phone"].Alerts = 0
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = QBCore.Functions.GetPlayerData()
        Wait(500)
        LoadPhone()
    end
end)

-- Public Phone Shit

RegisterNetEvent('qb-phone:client:publocphoneopen',function()
    SetNuiFocus(true, true)
    SendNUIMessage({type = 'publicphoneopen'})
end)

RegisterNUICallback('publicphoneclose', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

--- SHIT THAT IS GONE

RegisterNUICallback('CanTransferMoney', function(data, cb)
    local amount = tonumber(data.amountOf)
    local iban = data.sendTo
    if (PlayerData.money.bank - amount) >= 0 then
        QBCore.Functions.TriggerCallback('qb-phone:server:CanTransferMoney', function(Transferd)
            if Transferd then
                cb({TransferedMoney = true, NewBalance = (PlayerData.money.bank - amount)})
            else
		SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { timeout=3000, title = "Bank", text = "Account does not exist!", icon = "fas fa-university", color = "#ff0000", }, })
                cb({TransferedMoney = false})
            end
        end, amount, iban)
    else
        cb({TransferedMoney = false})
    end
end)

RegisterNetEvent('qb-phone:client:TransferMoney', function(amount, newmoney)
    PhoneData.PlayerData.money.bank = newmoney
    SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "Bank", text = "&#36;"..amount.." added to your account!", icon = "fas fa-university", color = "#8c7ae6", }, })
    SendNUIMessage({ action = "UpdateBank", NewBalance = PhoneData.PlayerData.money.bank })
end)

RegisterNetEvent("qb-phone-new:client:BankNotify", function(text)
    SendNUIMessage({
        action = "PhoneNotification",
        NotifyData = {
            title = "Bank",
            content = text,
            icon = "fas fa-university",
            timeout = 3500,
            color = "#ff002f",
        },
    })
end)

RegisterNetEvent('qb-phone:client:RemoveBankMoney', function(amount)
    if amount > 0 then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Bank",
                text = "$"..amount.." removed from your balance!",
                icon = "fas fa-university",
                color = "#ff002f",
                timeout = 3500,
            },
        })
    end
end)

RegisterNetEvent('qb-phone:client:GiveContactDetails', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        TriggerServerEvent('qb-phone:server:GiveContactDetails', PlayerId)
    else
        QBCore.Functions.Notify("No one nearby!", "error")
    end
end)

RegisterNetEvent("qb-phone:client:giveContactRequest", function(contactInfo)
    local success = exports['qb-phone']:PhoneNotification("CONTACT REQUEST", contactInfo.name..' contact request', 'fas fa-phone', '#b3e0f2', "NONE", 'fas fa-check-circle', 'fas fa-times-circle')
    if success then
        TriggerServerEvent('qb-phone:server:acceptContactRequest', contactInfo)
    end
end)

RegisterNetEvent('qb-phone:client:updateContactInfo', function(contactInfo)
    PhoneData.Contacts[#PhoneData.Contacts+1] = {
        name = contactInfo.name,
        number = contactInfo.number,
        iban = 0
    }
    SendNUIMessage({
        action = "RefreshContacts",
        Contacts = PhoneData.Contacts
    })
end)