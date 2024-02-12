lib.versionCheck('Qbox-project/qbx_npwd')

local currentResourceName = GetCurrentResourceName()
local debugIsEnabled = GetConvarInt(('%s-debug'):format(currentResourceName), 0) == 1

local function debugPrint(...)
    if not debugIsEnabled then return end

    local args <const> = { ... }

    local appendStr = ''
    for i = 1, #args do
        appendStr = appendStr .. ' ' .. tostring(args[i])
    end

    local msgTemplate = '^3[%s]^0%s'
    local finalMsg = msgTemplate:format(currentResourceName, appendStr)
    print(finalMsg)
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local playerIdent = player.PlayerData.citizenid
    local phoneNumber = tostring(player.PlayerData.charinfo.phone)
    local charInfo = player.PlayerData.charinfo
    local playerSrc = player.PlayerData.source

    MySQL.update.await('UPDATE players SET phone_number = ? WHERE citizenid = ?', { phoneNumber, playerIdent })

    exports.npwd:newPlayer({
        source = playerSrc,
        phoneNumber = tostring(charInfo.phone),
        identifier = playerIdent,
        firstname = charInfo.firstname,
        lastname = charInfo.lastname
    })

    debugPrint(('Loaded new player. S: %s, Iden: %s, Num: %s'):format(playerSrc, playerIdent, phoneNumber))
end)

RegisterNetEvent('qbx_npwd:server:UnloadPlayer', function()
    exports.npwd:unloadPlayer(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    if resName ~= currentResourceName then return end

    debugPrint('Launched with debug mode on')
    local players = exports.qbx_core:GetQBPlayers()

    for _, v in pairs(players) do
        exports.npwd:newPlayer({
            source = v.PlayerData.source,
            identifier = v.PlayerData.citizenid,
            phoneNumber = tostring(v.PlayerData.charinfo.phone),
            firstname = v.PlayerData.charinfo.firstname,
            lastname = v.PlayerData.charinfo.lastname,
        })
    end
end)

for i = 1, #PhoneList do
    exports.qbx_core:CreateUseableItem(PhoneList[i], function(source)
        TriggerClientEvent('qbx_npwd:client:setPhoneVisible', source, true)
    end)
end
