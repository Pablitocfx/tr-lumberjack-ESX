ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- QBCore Menu Configuration
if Config.menu == "ox" then
    RegisterNetEvent('tr-lumberjack:client:depo', function()
        lib.registerContext({
            id = 'lumberjack_depo',
            title = Lang.interact1,
            options = {
                {
                    title = Lang.depo1,
                    event = 'tr-lumberjack:client:deliverytruck',
                    icon = 'fa-solid fa-truck'
                },
                {
                    title = string.format(Lang.depo2, Config.workVanPrice),
                    event = 'tr-lumberjack:client:workvan',
                    icon = 'fa-solid fa-car'
                },
                {
                    title = Lang.depo3,
                    event = 'tr-lumberjack:client:contractorshop',
                    icon = 'fa-solid fa-shop'
                },
                {
                    title = Lang.depo4,
                    event = 'tr-lumberjack:client:returnworkvan',
                    icon = 'fa-solid fa-car'
                },
                {
                    title = Lang.depo5,
                    event = 'tr-lumberjack:client:returndeliverytruck',
                    icon = 'fa-solid fa-car'
                },
            }
        })
        lib.showContext('lumberjack_depo')
    end)

    RegisterNetEvent('tr-lumberjack:client:trailerInteract', function()
        lib.registerContext({
            id = 'lumber_trailer',
            title = Lang.interact4,
            options = {
                {
                    title = Lang.delivery2,
                    event = 'tr-lumberjack:client:loadtrailer',
                    icon = 'fa-solid fa-trailer'
                },
                {
                    title = Lang.delivery3,
                    event = 'tr-lumberjack:client:unloadtrailer',
                    icon = 'fa-solid fa-truck'
                },
            }
        })
        lib.showContext('lumber_trailer')
    end)

    RegisterNetEvent('tr-lumberjack:client:crafting', function()
        if HasPlayerGotChoppedLogs() then
            lib.registerContext({
                id = 'lumberjack_crafting',
                title = string.format(Lang.craftingMenu, ChoppedLogs),
                options = {
                    {
                        title = Lang.craftPlanks,
                        description = Lang.craftPlanksAmount,
                        event = 'tr-lumberjack:client:craftinginput',
                        args = { number = 1 },
                        icon = 'fa-solid fa-gear'
                    },
                    {
                        title = Lang.craftHandles,
                        description = Lang.craftHandlesAmount,
                        event = 'tr-lumberjack:client:craftinginput',
                        args = { number = 2 },
                        icon = 'fa-solid fa-gear'
                    },
                    {
                        title = Lang.craftFirewood,
                        description = Lang.craftFirewoodAmount,
                        event = 'tr-lumberjack:client:craftinginput',
                        args = { number = 3 },
                        icon = 'fa-solid fa-gear'
                    },
                    {
                        title = Lang.craftWoodenToySets,
                        description = Lang.craftWoodenToySetsAmount,
                        event = 'tr-lumberjack:client:craftinginput',
                        args = { number = 4 },
                        icon = 'fa-solid fa-gear'
                    },
                }
            })
            lib.showContext('lumberjack_crafting')
        end
    end)

    local function openSellMenu(itemList, eventPrefix)
        local menuItems = {}

        for _, item in pairs(itemList) do
            local itemCount = exports.ox_inventory:Search('count', item.name)
            local itemAvailable = itemCount > 0
            table.insert(menuItems, {
                title = string.format(item.header, itemCount), -- Title with item count
                serverEvent = eventPrefix .. ':server:sellitem',
                args = {
                    number = itemCount,
                    itemType = item.name
                },
                disabled = not itemAvailable, -- Disable if no items available
                icon = 'fa-solid fa-gear'
            })
        end
        lib.registerContext({
            id = 'sell_menu',
            title = Lang.interact7,
            options = menuItems
        })

        lib.showContext('sell_menu')
    end

    RegisterNetEvent('tr-lumberjack:client:sell1', function()
        openSellMenu({
            {name = 'tr_woodplank', header = Lang.sellPlanks},
            {name = 'tr_firewood', header = Lang.sellFirewood}
        }, 'tr-lumberjack')
    end)

    RegisterNetEvent('tr-lumberjack:client:sell2', function()
        openSellMenu({
            {name = 'tr_woodhandles', header = Lang.sellHandles},
            {name = 'tr_toyset', header = Lang.sellToy}
        }, 'tr-lumberjack')
    end)
end
