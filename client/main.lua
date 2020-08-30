local PlayerData              = {}
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local Blips                   = {}

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
  end)
  
  
  function SetVehicleMaxMods(vehicle)
  
    local props = {
      modEngine       = 0,
      modBrakes       = 0,
      modTransmission = 0,
      modSuspension   = 0,
      modTurbo        = false,
    }
  
    ESX.Game.SetVehicleProperties(vehicle, props)
  
  end

  Citizen.CreateThread(function() 
    local blipMarker = Config.Blips.Blip
    local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)
    SetBlipSprite(blipCoord, blipMarker.Sprite)
    SetBlipScale(blipCoord, blipMarker.Scale)
    SetBlipColour(blipCoord, blipMarker.Colour)
    SetBlipAsShortRange(blipCoord, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipMarker.title)
    EndTextCommandSetBlipName(blipCoord)
end) 

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) 
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) 
    PlayerData.job = job
    Citizen.Wait(5000)
end)

function cleanPlayer(playerPed)
    ClearPedBloodDamage(playerPed)
    ResetPedVisibleDamage(playerPed)
    ClearPedLastWeaponDamage(playerPed)
    ResetPedMovementClipset(playerPed, 0)
end

function setClipset(playerPed, clip)
    RequestAnimSet(clip)
    while not HasAnimeSetLoaded(clip) do
        Citizen.Wait(0)
    end

    SetPedMovementClipset(playerPed, clip, true)
end

function OpenVaultMenu()

    if Config.EnableVaultManagement then
        local elements = {
            {label = "Withdraw stock", value = 'get_stock'},
            {label = "Deposit stock", value = 'put_stock'}
        }

        ESX.UI.Menu.CloseAll()

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'vault',
            {
                title = "Vault",
                align = "bottom-right",
                elements = elements,
            },
            function(data, menu)
                if data.current.value == 'put_stock' then
                    OpenPutStocksMenu()
                end

                if data.current.value == 'get_stock' then
                    OpenGetStocksMenu()
                end
            end,

            function(data, menu) 
                menu.close()

                CurrentAction = 'menu_vault'
                CurrentActionMsg = 'Open Vault'
                CurrentActionData = {}
            end
        )
    end

end

function OpenFridgeMenu() 
    local elements = {
        {label = 'Withdraw stock', value = 'get_stock'},
        {label = 'Deposit stock', value = 'put_stock'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fridge',
        {
            title = 'Fridge',
            align = 'bottom-right', 
            elements = elements,
        },

        function(data, menu)
            if data.current.value == 'put_stock' then
                OpenPutFridgeStocksMenu()
            end

            if data.current.value == 'get_stock' then
                OpenGetFridgeStocksMenu()
            end
        end,

        function(data, menu)
            menu.close()
            CurrentAction = 'menu_fridge'
            CurrentActionMsg = 'Open Fridge'
            CurrentActionData = {}
        end
    )
end

function OpenGetFridgeStocksMenu()

    ESX.TriggerServerCallback('mcdonalds:getFridgeStockItems', function(items)
  
      print(json.encode(items))
      local elements = {}

      for i=1, #items, 1 do
        table.insert(elements, {
          label = 'x' ..items[i].count .. ' ' .. items[i].label,
          value = items[i].name
        })
      end
  
      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fridge_menu',
        {
          title    = 'Fridge',
          align    = 'bottom-right',
          elements = elements
        },
        function(data, menu)
  
          local itemName = data.current.value
  
          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'fridge_menu_get_item_count',
            {
              title = 'Quantity'
            },
            function(data2, menu2)
  
              local count = tonumber(data2.value)
  
              if count == nil then
                exports['mythic_notify']:SendAlert('error', 'Invalid quantity')
              else
                menu2.close()
                menu.close()
                OpenFridgeMenu()
  
                TriggerServerEvent('mcdonalds:getFridgeStockItem', itemName, count)
              end
  
            end,
            function(data2, menu2)
              menu2.close()
            end
          )
  
        end,
        function(data, menu)
          menu.close()
        end
      )
  
    end)
  
  end

  function OpenPutFridgeStocksMenu()

    ESX.TriggerServerCallback('mcdonalds:getPlayerInventory', function(inventory)
    
        local elements = {}

        for i = 1, #inventory.items, 1 do
            local item = inventory.items[i]

            --[[if item.count > 0 then
                table.insert(elements, {label = item.label .. ' x' .. item.count, type='item_standard', value = item.name})
            end]]
            if item.count > 0 then
              table.insert(elements, {
                label = item.label .. ' x' .. item.count,
                type = 'item_standard',
                value = item.name
              })
            end
        end
    
        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'fridge_menu',
          {
            title    = ('Fridge'),
            align    = 'bottom-right',
            elements = elements
          },
          function(data, menu)
    
            local itemName = data.current.value
    
            ESX.UI.Menu.Open(
              'dialog', GetCurrentResourceName(), 'fridge_menu_put_item_count',
              {
                title = 'Quantity'
              },
              function(data2, menu2)
    
                local count = tonumber(data2.value)
    
                if count == nil then
                  exports['mythic_notify']:SendAlert('error', 'Invalid Quantity')
                else
                  menu2.close()
                  menu.close()
                  ESX.UI.Menu.Close()
                  OpenFridgeMenu()
    
                  TriggerServerEvent('mcdonalds:putFridgeStockItems', itemName, count)
                end
    
              end,
              function(data2, menu2)
                menu2.close()
              end
            )
    
          end,
          function(data, menu)
            menu.close()
          end
        )
    
      end)
    
    end


Citizen.CreateThread(function()
    while true do

        Citizen.Wait(0)
        if ESX.GetPlayerData().job and ESX.GetPlayerData().job.name == 'mcdonalds' then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if GetDistanceBetweenCoords(coords, Config.Zones.Vaults.Pos.x, Config.Zones.Vaults.Pos.y, Config.Zones.Vaults.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open the vault')
              if IsControlJustPressed(0, 38) then
                OpenVaultMenu()
              end
            elseif GetDistanceBetweenCoords(coords, Config.Zones.Fridge.Pos.x, Config.Zones.Fridge.Pos.y, Config.Zones.Fridge.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open the fridge')
              if IsControlJustPressed(0, 38) then
                OpenFridgeMenu()
              end
            elseif GetDistanceBetweenCoords(coords, Config.Zones.Cloakrooms.Pos.x, Config.Zones.Cloakrooms.Pos.y, Config.Zones.Cloakrooms.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open the cloakroom')
              if IsControlJustPressed(0, 38) then
                OpenCloakroomMenu()
              end
            elseif GetDistanceBetweenCoords(coords, Config.Zones.Foods.Pos.x, Config.Zones.Foods.Pos.y, Config.Zones.Foods.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open food inventory')
              if IsControlJustPressed(0, 38) then
                OpenFoodInventory()
              end 
            elseif GetDistanceBetweenCoords(coords, Config.Zones.Drinks.Pos.x, Config.Zones.Drinks.Pos.y, Config.Zones.Drinks.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open drink inventory')
              if IsControlJustPressed(0, 38) then
                OpenDrinkInventory()
              end 
            elseif GetDistanceBetweenCoords(coords, Config.Zones.Boss.Pos.x, Config.Zones.Boss.Pos.y, Config.Zones.Boss.Pos.z, true) < Config.DrawDistance then
              drawTxt('~w~Press ~g~[E]~w~ to open boss actions')
              if IsControlJustPressed(0, 38) then
                ESX.UI.Menu.CloseAll()
                TriggerEvent('esx_society:openBossMenu', 'mcdonalds', function(data, menu) 
                  menu.close()

                  CurrentAction = 'menu_boss_actions'
                  CurrentActionMsg = 'Boss Menu'
                  CurrentActionData = {}
                end, { wash = false })
              end 
            else
                ESX.UI.Menu.CloseAll()
            end
        else
          Citizen.Wait(500)
        end

    end
end)

function setUniform(job, playerPed)
  TriggerEvent('skinchanger:getSkin', function(skin) 
    if skin.sex == 0 then
      if Config.Uniforms[job].male ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
      else
        exports['mythic_notify']:SendAlert('error', 'There is no outfit')
      end
      if job ~= 'citizen_wear' and job ~= 'work_clothes' then
        setClipset(playerPed, "MOVE_M@POSH@")
      end
    end
  end)
end

function OpenCloakroomMenu() 

  local playerPed = GetPlayerPed(-1)

  local elements = {
    { label = 'Citizen Wear', value = 'citizen_wear'},
    { label = 'Work clothes', value = 'work_clothes'}
  }

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'cloakroom',
    {
      title = 'Cloakroom',
      align = 'bottom-right',
      elements = elements,
    },
    function(data, menu)
      cleanPlayer(playerPed)

      if data.current.value == 'citizen_wear' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin) 
          TriggerEvent('skinchanger:loadSkin', skin)
        end)
      end

      if data.current.value == 'work_clothes' then
        setUniform(data.current.value, playerPed)
      end
    end,
    function(data, menu)
      menu.close()

    end
  )

end

function OpenFoodInventory()
  local elements = {}
  for i = 1, #Config.Zones.Foods.Items, 1 do
    local item = Config.Zones.Foods.Items[i]
    
    table.insert(elements, {
      label = item.label .. ' - <span style="color:green;">$' .. item.price .. ' </span>',
      realLabel = item.label,
      value = item.name,
      price = item.price
    })
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'mcdonalds_shop',
    {
      title = 'MCDonalds Food',
      align = 'bottom-right',
      elements = elements
    },
    function(data, menu)
      TriggerEvent("mythic_progbar:client:progress", {
        name = "Cooking..",
        duration = 10000,
        label = "Cooking..",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
        },
        prop = {
            model = "prop_paper_bag_small",
        }
    }, function(status)
        if not status then
          TriggerServerEvent('mcdonalds:buyItem', data.current.value, data.current.price, data.current.realLabel)
        end
      end)
    end,
    function(data, menu)
      menu.close()
    end
  )
end

function OpenDrinkInventory()
  local elements = {}
  for i = 1, #Config.Zones.Drinks.Items, 1 do
    local item = Config.Zones.Drinks.Items[i]
    
    table.insert(elements, {
      label = item.label .. ' - <span style="color:green;">$' .. item.price .. ' </span>',
      realLabel = item.label,
      value = item.name,
      price = item.price
    })
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'mcdonalds_shop',
    {
      title = 'MCDonalds Drinks',
      align = 'bottom-right',
      elements = elements
    },
    function(data, menu)
      TriggerEvent("mythic_progbar:client:progress", {
        name = "Getting the drinks",
        duration = 10000,
        label = "Getting the drinks",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@idle_a",
            anim = "idle_a",
        },
        prop = {
            model = "prop_cs_script_bottle",
        }
    }, function(status)
        if not status then
          TriggerServerEvent('mcdonalds:buyItem', data.current.value, data.current.price, data.current.realLabel)
        end
      end)
    end,
    function(data, menu)
      menu.close()
    end
  )
end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('mcdonalds:getStockItems', function(items)

    print(json.encode(items))

    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {
        label = 'x' .. items[i].count .. ' ' .. items[i].label,
        value = items[i].name
      })
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = 'MCDonalds Stock',
		align    = 'bottom-right',
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = 'Quantity'
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              exports['mythic_notify']:SendAlert('error', 'Invalid quantity')
            else
              menu2.close()
              menu.close()
              OpenVaultMenu()

              TriggerServerEvent('mcdonalds:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end


function OpenPutStocksMenu()
    ESX.TriggerServerCallback('mcdonalds:getPlayerInventory', function(inventory) 
        local elements = {}

        for i = 1, #inventory.items, 1 do
            local item = inventory.items[i]

            --[[if item.count > 0 then
                table.insert(elements, {label = item.label .. ' x' .. item.count, type='item_standard', value = item.name})
            end]]
            if item.count > 0 then
              table.insert(elements, {
                label = item.label .. ' x' .. item.count,
                type = 'item_standard',
                value = item.name
              })
            end
        end

        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'stocks_menu',
            {
                title = 'Inventory',
                align = 'bottom-right',
                elements = elements
            },

            function(data, menu)
                local itemName = data.current.value

                ESX.UI.Menu.Open(
                    'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
                    {
                        title = 'Quantity'
                    },
                    function(data2, menu2)
                        local count = tonumber(data2.value)

                        if count == nil then
                            exports['mythic_notify']:SendAlert('error', 'Invalid quantity')
                        else
                            menu2.close()
                            menu.close()
                            OpenVaultMenu()
                            TriggerServerEvent('mcdonalds:putStockItems', itemName, count)
                        end
                    end,
                    function(data2, menu2)
                        menu2.close()
                    end
                )
            end,
            function(data, menu)
                menu.close()
            end
        )
    end)
end


function drawTxt(text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.32, 0.32)
    SetTextColour(0, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.5)
  end