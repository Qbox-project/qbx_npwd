local hasPhone = false

local function doPhoneCheck(isUnload, totalCount)
    hasPhone = false

    if isUnload then
        exports.npwd:setPhoneDisabled(true)
        return
    end

    if totalCount then
        hasPhone = totalCount > 0
        exports.npwd:setPhoneDisabled(not hasPhone)
        return
    end

    local items = exports.ox_inventory:Search('count', PhoneList)

    if type(items) == 'number' then
        hasPhone = items > 0
    else
        for _, v in pairs(items) do
            if v > 0 then
                hasPhone = true
                break
            end
        end
    end

    exports.npwd:setPhoneDisabled(not hasPhone)
end

exports("HasPhone", function()
    return hasPhone
end)

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    doPhoneCheck()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    doPhoneCheck(true)
    TriggerServerEvent('qbx_npwd:server:UnloadPlayer')
end)

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    for i = 1, #PhoneList do
        if PhoneList[i] == itemName then
            doPhoneCheck(false, totalCount)
            break
        end
    end
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or GetResourceState('npwd') ~= 'started' then return end

    doPhoneCheck()
end)

-- Allows use of phone as an item.
RegisterNetEvent('qbx_npwd:client:setPhoneVisible', function(isPhoneVisible)
    exports.npwd:setPhoneVisible(isPhoneVisible)
end)