local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local playerLogSales = {}

local function notifyPlayer(source, message, type)
    lib.notify({
        id = 'notification_' .. source,
        title = 'Notification',
        description = message,
        showDuration = false,
        position = 'top',
        style = { backgroundColor = '#141517', color = '#C1C2C5', ['.description'] = { color = '#909296' } },
        icon = 'ban',
        iconColor = '#C53030'
    })
end

RegisterServerEvent('tr-lumberjack:server:workvan', function(workVanPrice)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer and xPlayer.getMoney() >= workVanPrice then
        xPlayer.removeMoney(workVanPrice)
        notifyPlayer(source, string.format(Lang.paidWorkVan, workVanPrice), 'success')
    end
end)

RegisterServerEvent('tr-lumberjack:server:returnworkvan', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local depoCoords = vector3(Config.lumberDepo.x, Config.lumberDepo.y, Config.lumberDepo.z)

        if #(playerCoords - depoCoords) > 10.0 then
            notifyPlayer(source, Lang.tooFarFromDepo, 'error')
            return
        end
        xPlayer.addMoney(Config.returnPrice)
        notifyPlayer(source, Lang.storedVehicle, 'success')
    else
        notifyPlayer(source, Lang.invalidPlayer, 'error')
    end
end)

RegisterServerEvent('tr-lumberjack:server:addLog', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    local logCount = xPlayer.getInventoryItem('tr_log').count

    if logCount > 0 then
        notifyPlayer(source, Lang.carryingItem, 'error')
        return
    end

    xPlayer.addInventoryItem('tr_log', 1)
    notifyPlayer(source, Lang.addedLog, 'success')
end)

RegisterServerEvent('tr-lumberjack:server:removeLog', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        xPlayer.removeInventoryItem('tr_log', 1)
    end
end)

RegisterServerEvent('tr-lumberjack:server:deliverypaper', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local taskerCoords = vector3(Config.deliveryTasker.x, Config.deliveryTasker.y, Config.deliveryTasker.z)

        if #(playerCoords - taskerCoords) > 10.0 then
            notifyPlayer(source, Lang.tooFarFromTasker, 'error')
            return
        end

        if xPlayer.getInventoryItem('tr_deliverypaper').count > 0 then
            notifyPlayer(source, Lang.alreadyHaveDeliveryPaper, 'error')
            return
        end

        xPlayer.addInventoryItem('tr_deliverypaper', 1)
        notifyPlayer(source, Lang.timmyDialLog1, 'success')
    else
        notifyPlayer(source, Lang.invalidPlayer, 'error')
    end
end)

RegisterServerEvent('tr-lumberjack:server:sellinglog', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local dropOffCoords = Config.deliverDropOff

        if #(playerCoords - dropOffCoords) > 10.0 then
            notifyPlayer(source, Lang.tooFarFromDropOff, 'error')
            return
        end

        if xPlayer.getInventoryItem('tr_log').count < 1 then
            notifyPlayer(source, Lang.noLogsToSell, 'error')
            return
        end

        local minSell, maxSell = table.unpack(Config.sell.deliveryPerLog)
        local cashReward = math.random(minSell, maxSell)

        if not playerLogSales[source] then
            playerLogSales[source] = 0
        end
        playerLogSales[source] = playerLogSales[source] + 1

        xPlayer.removeInventoryItem('tr_log', 1)
        xPlayer.addMoney(cashReward)

        if playerLogSales[source] >= Config.maxLogs then
            xPlayer.removeInventoryItem('tr_deliverypaper', 1)
            TriggerClientEvent('tr-lumberjack:client:resetTimmyTask', source)
            playerLogSales[source] = 0
        end
        notifyPlayer(source, string.format(Lang.soldLog, cashReward), 'success')
    else
        notifyPlayer(source, Lang.invalidPlayer, 'error')
    end
end)

RegisterServerEvent('tr-lumberjack:server:choptree', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.canCarryItem('tr_choppedlog', 1) then
        xPlayer.addInventoryItem('tr_choppedlog', 1)
        notifyPlayer(source, Lang.chopAdded, 'success')
    else
        notifyPlayer(source, Lang.carryingWeight, 'error')
    end
end)

RegisterServerEvent('tr-lumberjack:server:craftinginput', function(argsNumber, logAmount)
    local source = source
    local slot = tonumber(argsNumber)
    local itemCount = tonumber(logAmount)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local craftingBenchCoords = vector3(Config.craftingBench.x, Config.craftingBench.y, Config.craftingBench.z)
    local distance = #(playerCoords - craftingBenchCoords)

    if distance > 5.0 then
        notifyPlayer(source, Lang.tooFarFromCraftingBench, 'error')
        return
    end

    if itemCount < 0 then
        if Config.debug then
            print("Invalid item count:", itemCount)
        end
        return
    end

    local itemToReceive
    local totalItems

    if slot == 1 then
        itemToReceive = 'tr_woodplank'
        totalItems = itemCount * Config.receive.tr_woodplank
    elseif slot == 2 then
        itemToReceive = 'tr_woodhandles'
        totalItems = itemCount * Config.receive.tr_woodhandles
    elseif slot == 3 then
        itemToReceive = 'tr_firewood'
        totalItems = itemCount * Config.receive.tr_firewood
    elseif slot == 4 then
        itemToReceive = 'tr_toyset'
        totalItems = itemCount * Config.receive.tr_toyset
    else
        if Config.debug then
            print("Invalid crafting type.")
        end
        return
    end

    if xPlayer.canCarryItem(itemToReceive, totalItems) then
        xPlayer.removeInventoryItem('tr_choppedlog', itemCount)
        Wait(7)
        xPlayer.addInventoryItem(itemToReceive, totalItems)
        notifyPlayer(source, string.format(Lang.craftedItems, totalItems, itemToReceive), 'success')
    else
        notifyPlayer(source, Lang.carryingWeight, 'error')
    end

    if Config.debug then
        print(string.format("Player %d crafted %d %s.", source, totalItems, itemToReceive))
    end
end)

RegisterServerEvent('tr-lumberjack:server:sellitem', function(args)
    local source = source
    local itemCount = tonumber(args.number)
    local itemType = args.itemType
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    local sellingLocation = nil
    if itemType == 'tr_firewood' or itemType == 'tr_woodplank' then
        sellingLocation = vector3(Config.seller1.x, Config.seller1.y, Config.seller1.z)
    elseif itemType == 'tr_toyset' or itemType == 'tr_woodhandles' then
        sellingLocation = vector3(Config.seller2.x, Config.seller2.y, Config.seller2.z)
    else
        notifyPlayer(source, Lang.invalidItem, 'error')
        return
    end

    if #(playerCoords - sellingLocation) > 10 then
        notifyPlayer(source, Lang.tooFarFromSellPoint, 'error')
        return
    end

    if itemCount > 0 then
        local sellPriceRange = Config.sell[itemType]
        if sellPriceRange then
            local sellPrice = math.random(sellPriceRange[1], sellPriceRange[2]) * itemCount
            xPlayer.addMoney(sellPrice)
            xPlayer.removeInventoryItem(itemType, itemCount)
            notifyPlayer(source, string.format(Lang.soldItems, itemCount, sellPrice), 'success')
        else
            notifyPlayer(source, Lang.invalidItem, 'error')
        end
    else
        notifyPlayer(source, Lang.noItemsToSell, 'error')
    end
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterShop("contractorshop", {
            name = Lang.depoShop,
            inventory = Config.depoItems
        })
    end
end)
