local hasPhone = false

local function DoPhoneCheck(isUnload)
    hasPhone = false

    if isUnload then
        exports.npwd:setPhoneDisabled(true)
        return
    end

    local items = exports.ox_inventory:Search('count', Config.PhoneList)

    for _, v in pairs(items) do
        if v > 0 then
            hasPhone = true
            break
        end
    end

    exports.npwd:setPhoneDisabled(not hasPhone)
end

local function HasPhone()
    return hasPhone
end

exports("HasPhone", HasPhone)

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    DoPhoneCheck()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DoPhoneCheck(true)
    TriggerServerEvent("qbx-npwd:server:UnloadPlayer")
end)

-- Handles state when PlayerData is changed. We're just looking for inventory updates.
RegisterNetEvent('QBCore:Player:SetPlayerData', function(PlayerData)
    DoPhoneCheck()
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or GetResourceState('npwd') ~= 'started' then return end

    DoPhoneCheck()
end)

-- Allows use of phone as an item.
RegisterNetEvent('qbx-npwd:client:setPhoneVisible', function(isPhoneVisible)
    exports.npwd:setPhoneVisible(isPhoneVisible)
end)
