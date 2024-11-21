local camZPlus1 = 1500
local camZPlus2 = 50
local pointCamCoords = 75
local pointCamCoords2 = 0
local cam1Time = 500
local cam2Time = 1000
local choosingSpawn = false
local lastLoc = nil
local isDead = nil
local newPlayer = nil

RegisterNetEvent('qbr-spawn:client:openUI', function(cData)
    SetEntityVisible(PlayerPedId(), false)
    DoScreenFadeOut(250)
    Wait(1000)
    DoScreenFadeIn(250)
    lastLoc = vector3(cData.position.x, cData.position.y, cData.position.z)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cData.position.x, cData.position.y, cData.position.z + camZPlus1, -85.00, 0.00, 0.00, 100.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1000, true, true)
    Wait(500)
    SetDisplay(true)
end)

RegisterNUICallback("exit", function(data)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "ui",
        status = false
    })
    choosingSpawn = false
end)

local cam = nil
local cam2 = nil

RegisterNUICallback('setCam', function(data)
    print(json.encode(data, {indent = true}))
    local location = tostring(data.posname)
    local type = tostring(data.type)

    DoScreenFadeOut(200)
    Wait(500)
    DoScreenFadeIn(200)

    if DoesCamExist(cam) then
        DestroyCam(cam, true)
    end

    if DoesCamExist(cam2) then
        DestroyCam(cam2, true)
    end

    if type == "current" then
        local pedPos = lastLoc
        cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pedPos.x, pedPos.y, pedPos.z + camZPlus1, 300.00,0.00,0.00, 110.00, false, 0)
        PointCamAtCoord(cam2, pedPos.x, pedPos.y, pedPos.z + pointCamCoords)
        SetCamActiveWithInterp(cam2, cam, cam1Time, true, true)
        if DoesCamExist(cam) then
            DestroyCam(cam, true)
        end
        Wait(cam1Time)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pedPos.x, pedPos.y, pedPos.z + camZPlus2, 300.00,0.00,0.00, 110.00, false, 0)
        PointCamAtCoord(cam, pedPos.x, pedPos.y, pedPos.z + pointCamCoords2)
        SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
        SetEntityCoords(PlayerPedId(), pedPos.x, pedPos.y, pedPos.z)
    end
    if type == "normal" then
        if newPlayer then
            local campos = SSWELL.FirstSpawns[location].coords

            cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus1, 300.00,0.00,0.00, 110.00, false, 0)
            PointCamAtCoord(cam2, campos.x, campos.y, campos.z + pointCamCoords)
            SetCamActiveWithInterp(cam2, cam, cam1Time, true, true)
            if DoesCamExist(cam) then
                DestroyCam(cam, true)
            end
            Wait(cam1Time)
    
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus2, 300.00,0.00,0.00, 110.00, false, 0)
            PointCamAtCoord(cam, campos.x, campos.y, campos.z + pointCamCoords2)
            SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
            SetEntityCoords(PlayerPedId(), campos.x, campos.y, campos.z)
        end
    end
end)

RegisterNUICallback('spawnplayer', function(data)
    local location = tostring(data.spawnloc)
    local type = tostring(data.typeLoc)
    local ped = PlayerPedId()
    local pedPos = lastLoc
    local pedHeading = GetEntityHeading(ped)
    print(newPlayer)
    print(type)
    if type == "current" then
        SetDisplay(false)
        DoScreenFadeOut(500)
        Wait(2000)
        SetEntityCoords(PlayerPedId(), pedPos.x, pedPos.y, pedPos.z)
        SetEntityHeading(PlayerPedId(), pedHeading)
        FreezeEntityPosition(PlayerPedId(), false)
        FreezeEntityPosition(ped, false)
        RenderScriptCams(false, true, 1500, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        SetCamActive(cam2, false)
        DestroyCam(cam2, true)
        SetEntityVisible(PlayerPedId(), true)
        Wait(500)
        DoScreenFadeIn(250)
        TriggerEvent("vorp:initSpawnChar", isDead)
        Wait(1000)
        lastLoc = nil
        isDead = nil
        newPlayer = nil
    elseif type == "normal" then
        local pos = {}
        print(json.encode(pos, {indent = true}))
        if newPlayer then
            pos = SSWELL.FirstSpawns[location].coords
            SetDisplay(false)
            DoScreenFadeOut(500)
            Wait(2000)
            SetEntityCoords(ped, pos.x, pos.y, pos.z)
            Wait(500)
            SetEntityCoords(ped, pos.x, pos.y, pos.z)
            SetEntityHeading(ped, pos.h)
            FreezeEntityPosition(ped, false)
            RenderScriptCams(false, true, 1500, true, true)
            SetCamActive(cam, false)
            DestroyCam(cam, true)
            SetCamActive(cam2, false)
            DestroyCam(cam2, true)
            SetEntityVisible(PlayerPedId(), true)
            Wait(500)
            DoScreenFadeIn(250)
            TriggerEvent("vorp:initSpawnChar", isDead)
            Wait(1000)
            lastLoc = nil
            isDead = nil
            newPlayer = nil
        end
    end

end)

function SetDisplay(bool)
    choosingSpawn = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

CreateThread(function()
    while true do
        if choosingSpawn then
            DisableAllControlActions(0)
        else
            Wait(1000)
        end
        Wait(0)
    end
end)

--@ position ? u can get from entityCoords for debuggin or u can get the coords from the config.lua
--@ isDead ? its normally for check if player is dead or not (trigger for @vorp_character/client/client.lua) // Default false
--@ isNew ? is the player is new or not // Default false

--@ note : this spawn selector is for new player only, if u want make these spawn selector for new player or old player is ur choice. but need adjusment!

RegisterCommand("testspawns", function(source) -- for debuggin the spawns system
    local playerCoords = GetEntityCoords(PlayerPedId())
    TriggerEvent("qbr-spawn:client:setupSpawnUI", { position = playerCoords, isDead = false, isNew = true })
end)

RegisterNetEvent('qbr-spawn:client:setupSpawnUI', function(cData)
    if cData.position and type(cData.position) == "vector3" then
        isDead = cData.isDead
        newPlayer = cData.isNew
        TriggerEvent('qbr-spawn:client:openUI', { position = cData.position })
    else
        print("invalid")
    end
    TriggerEvent('qbr-spawn:client:setupSpawns', newPlayer)
end)


RegisterNetEvent('qbr-spawn:client:setupSpawns', function(newPlayer)
    print("hello")
    if newPlayer then
        print("im a new player")
        SendNUIMessage({
            action = "setupLocations",
            locations = SSWELL.FirstSpawns,
            new = true,
        })
    else
        SendNUIMessage({
            action = "setupLocations",
            locations = SSWELL.Spawns,
            houses = {},
        })
    end
end)
