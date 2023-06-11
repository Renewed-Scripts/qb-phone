QBCore = exports['qb-core']:GetCoreObject()

local phoneProp = 0
local phoneModel = joaat("prop_npc_phone_02")

function LoadAnimation(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(1)
	end
end

function CheckAnimLoop()
    CreateThread(function()
        while PhoneData.AnimationData.lib and PhoneData.AnimationData.anim do
            if not IsEntityPlayingAnim(cache.ped, PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 3) then
                LoadAnimation(PhoneData.AnimationData.lib)
                TaskPlayAnim(cache.ped, PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 3.0, 3.0, -1, 50, 0, false, false, false)
            end
            Wait(500)
        end
    end)
end

function newPhoneProp()
	deletePhone()
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Wait(1)
	end
	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
	local bone = GetPedBoneIndex(cache.ped, 28422)
	if phoneModel == joaat("prop_cs_phone_01") then
		AttachEntityToEntity(phoneProp, cache.ped, bone, 0.0, 0.0, 0.0, 50.0, 320.0, 50.0, true, true, false, false, 2, true)
	else
		AttachEntityToEntity(phoneProp, cache.ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
	end
end

function deletePhone()
	if phoneProp then
		DeleteObject(phoneProp)
		phoneProp = 0
	end
end

function DoPhoneAnimation(anim)
    local AnimationLib = 'cellphone@'
    local AnimationStatus = anim
    if cache.vehicle then
        AnimationLib = 'anim@cellphone@in_car@ps'
    end
    LoadAnimation(AnimationLib)
    TaskPlayAnim(cache.ped, AnimationLib, AnimationStatus, 3.0, 3.0, -1, 50, 0, false, false, false)
    PhoneData.AnimationData.lib = AnimationLib
    PhoneData.AnimationData.anim = AnimationStatus
    CheckAnimLoop()
end