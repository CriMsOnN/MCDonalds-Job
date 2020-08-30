ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'mcdonalds', 'MCDonalds', 'society_mcdonalds', 'society_mcdonalds', 'society_mcdonalds', {type= 'private'})


RegisterNetEvent('mcdonalds:getStockItem')
AddEventHandler('mcdonalds:getStockItem', function(itemName, count) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds', function(inventory) 
        local inventoryItem = inventory.getItem(itemName)

        if count > 0 and inventoryItem.count >= count then
            if xPlayer.canCarryItem(itemName, count) then
                inventory.removeItem(itemName, count)
                xPlayer.addInventoryItem(itemName, count)
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = 'You have withdraw x' .. count .. ' ' .. inventoryItem.label})
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = 'Invalid quantity'})
            end
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error' , text = 'Invalid quantity'})
        end
    end)
end)



ESX.RegisterServerCallback('mcdonalds:getStockItems', function(source, cb) 
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds', function(inventory) 
        cb(inventory.items)
    end)
end)

RegisterServerEvent('mcdonalds:putStockItems')
AddEventHandler('mcdonalds:putStockItems', function(itemName, count) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourceItem = xPlayer.getInventoryItem(itemName)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds', function(inventory) 
        local inventoryItem = inventory.getItem(itemName)
        if sourceItem.count >= count and count > 0 then
            xPlayer.removeInventoryItem(itemName, count)
            inventory.addItem(itemName, count)
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type='inform', text='You added ' .. ' ' .. inventoryItem.label})
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type='error', text='Invalid quantity'})
        end
    end)
end)



RegisterServerEvent('mcdonalds:getFridgeStockItem')
AddEventHandler('mcdonalds:getFridgeStockItem', function(itemName, count)

	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds_fridge', function(inventory) 
        local inventoryItem = inventory.getItem(itemName)

        if count > 0 and inventoryItem.count >= count then
            if xPlayer.canCarryItem(itemName, count) then
                inventory.removeItem(itemName, count)
                xPlayer.addInventoryItem(itemName, count)
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'inform', text = 'You have withdraw x' .. count .. ' ' .. inventoryItem.label})
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = 'Invalid quantity'})
            end
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error' , text = 'Invalid quantity'})
        end
    end)
end)

ESX.RegisterServerCallback('mcdonalds:getFridgeStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds_fridge', function(inventory)
    cb(inventory.items)
  end)

end)

RegisterServerEvent('mcdonalds:putFridgeStockItems')
AddEventHandler('mcdonalds:putFridgeStockItems', function(itemName, count)

    local xPlayer = ESX.GetPlayerFromId(source)
    local sourceItem = xPlayer.getInventoryItem(itemName)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mcdonalds_fridge', function(inventory) 
        local inventoryItem = inventory.getItem(itemName)
        if sourceItem.count >= count and count > 0 then
            xPlayer.removeInventoryItem(itemName, count)
            inventory.addItem(itemName, count)
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type='inform', text='You added ' .. ' ' .. inventoryItem.label})
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type='error', text='Invalid quantity'})
        end
    end)

end)

ESX.RegisterServerCallback('mcdonalds:getPlayerInventory', function(source, cb) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local items = xPlayer.inventory

    cb({
        items = items
    })
end)

RegisterServerEvent('mcdonalds:buyItem')
AddEventHandler('mcdonalds:buyItem', function(itemName, price, itemLabel) 
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local qtty = xPlayer.getInventoryItem(itemName).count
    local societyAccount = nil

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mcdonalds', function(account) 
        societyAccount = account
        if societyAccount ~= nil and societyAccount.money >= price then
            if xPlayer.canCarryItem(itemName, qtty) then
                societyAccount.removeMoney(price)
                xPlayer.addInventoryItem(itemName, 1)
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type='inform', text='You bought ' .. itemLabel})
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type = 'error', text = 'You cannot carry more'})
            end
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, {type='error', text='Not enough money'})
        end

    end)
end)