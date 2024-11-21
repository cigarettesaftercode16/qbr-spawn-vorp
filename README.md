# qbr-spawn

## Spawn System for Vorp Core Frame Work Original From QBRFramework 🧑‍🤝‍🧑

## Only for new player, if u want to make these for old or new player is ur choice. i just wanna say, u need more adjusment for that!

## Screenshots
![Spawn](https://cdn.discordapp.com/attachments/1021700112776437760/1183161143800373409/image.png?ex=658753ae&is=6574deae&hm=8f35526c88469d9326f1e031376698c0801e593e019e179b0061146fed76e9b0&)
![Spawn2](https://cdn.discordapp.com/attachments/1021700112776437760/1183160768309497886/image.png?ex=65875355&is=6574de55&hm=856dbd8cc38fef03d729dc56db7e3370105aa382870db469b63ba8ac942b7a27&)

## Features
Ability to select spawn after selecting the character

## Dependencies
- vorp_core
- vorp_character

## Installation

# Download the script and put it in the [qbr] directory.

# Add the following code to your server.cfg/resouces.cfg

```
ensure vorp_core
ensure vorp_character
ensure qbr-spawn
```

## License
```
QBCore Framework
Copyright (C) 2021 Joshua Eger

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>
```

## Steps : 

Add these event to @vorp_core/client/spawnplayer.lua

RegisterNetEvent("vorp:initSpawnChar", function(isdead)
    if isdead then
        if not Config.CombatLogDeath then
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.forcedrespawn, T.forced, T.Almost)
            end
            SetEntityCanBeDamaged(PlayerPedId(), true)
            CoreAction.Player.RespawnPlayer() -- this one doesnt need to trigger events, its for player combat log
            Wait(Config.LoadinScreenTimer)
            Wait(1000)
            ShutdownLoadingScreen()
            Wait(5000)
        else
            if Config.Loadinscreen then
                Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Holddead, T.Loaddead, T.Almost)
            end
            Wait(10000)
            TriggerEvent("vorp_inventory:CloseInv")
            Wait(4000)
            SetEntityCanBeDamaged(PlayerPedId(), true)
            SetEntityHealth(PlayerPedId(), 0, 0)
            Citizen.InvokeNative(0xC6258F41D86676E0, PlayerPedId(), 0, -1)
            ShutdownLoadingScreen()
        end
    else
        local PlayerId = PlayerId()
        if Config.Loadinscreen then
            Citizen.InvokeNative(0x1E5B70E53DB661E5, 0, 0, 0, T.Hold, T.Load, T.Almost)
            Wait(Config.LoadinScreenTimer)
            Wait(1000)
            ShutdownLoadingScreen()
        end
        if not Config.HealthRecharge.enable then
            Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, 0.0) -- SetPlayerHealthRechargeMultiplier
        else
            Citizen.InvokeNative(0x8899C244EBCF70DE, PlayerId, Config.HealthRecharge.multiplier)
            multiplierHealth = Citizen.InvokeNative(0x22CD23BB0C45E0CD, PlayerId) -- GetPlayerHealthRechargeMultiplier
        end

        if not Config.StaminaRecharge.enable then
            Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, 0.0) -- SetPlayerStaminaRechargeMultiplier
        else
            Citizen.InvokeNative(0xFECA17CF3343694B, PlayerId, Config.StaminaRecharge.multiplier)
            multiplierStamina = Citizen.InvokeNative(0x617D3494AD58200F, PlayerId) -- GetPlayerStaminaRechargeMultiplier
        end
        SetEntityCanBeDamaged(PlayerPedId(), true)

        if Config.SavePlayersStatus then
            TriggerServerEvent("vorp:GetValues")
            Wait(200)
            if HealthData then
                local player = PlayerPedId()
                Citizen.InvokeNative(0xC6258F41D86676E0, player, 0, HealthData.hInner or 600)
                SetEntityHealth(player, (HealthData.hOuter and HealthData.hOuter > 0 and HealthData.hOuter or 600) + (HealthData.hInner and HealthData.hInner > 0 and HealthData.hInner or 600), 0)
                Citizen.InvokeNative(0xC6258F41D86676E0, player, 1, HealthData.sInner or 600)
                Citizen.InvokeNative(0x675680D089BFA21F, player, (HealthData.sOuter or (1065353215 * 100)) / 1065353215 * 100)
            end
            HealthData = {}
        else
            CoreAction.Admin.HealPlayer()
        end
    end
    SetTimeout(2000, function()
        DoScreenFadeIn(4000)
        repeat Wait(500) until IsScreenFadedIn()
    end)
end)

Replace these event to @vorp_core/server/server.lua

RegisterServerEvent("vorpcharacter:saveCharacter", function(data)
	local _source = source
	Core.getUser(_source).addCharacter(data)
	Wait(600)
	local spawnPosition = vector3(QB.FirstSpawns["emerald"].coords.x, QB.FirstSpawns["emerald"].coords.y, QB.FirstSpawns["emerald"].coords.z)
	TriggerClientEvent("qbr-spawn:client:setupSpawnUI", _source, {position = spawnPosition, isDead = false, isNew = true})
	-- TriggerClientEvent("vorp:initCharacter", _source, Config.SpawnCoords.position, Config.SpawnCoords.heading, false)
	SetTimeout(3000, function()
		TriggerEvent("vorp_NewCharacter", _source)
	end)
end)
