local sharedConfig = require 'config.shared'
local clientConfig = require 'config.client'
local interiorShell
DecorationObjects = {}
local properties = {}
local insideProperty = false
local isPropertyRental = false
local interactions
local isConcealing = false
local concealWhitelist = {}
local blips = {}

local function createBlip(apartmentCoords, label)
    local blip = AddBlipForCoord(apartmentCoords.x, apartmentCoords.y, apartmentCoords.z)
    SetBlipSprite(blip, 40)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function prepareKeyMenu()
    local keyholders = lib.callback.await('qbx_properties:callback:requestKeyHolders')
    local options = {
        {
            title = locale('menu.add_keyholder'),
            icon = 'plus',
            arrow = true,
            onSelect = function()
                local insidePlayers = lib.callback.await('qbx_properties:callback:requestPotentialKeyholders')
                local options = {}
                for i = 1, #insidePlayers do
                    options[#options + 1] = {
                        title = insidePlayers[i].name,
                        icon = 'user',
                        arrow = true,
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = insidePlayers[i].name,
                                content = locale('alert.give_keys'),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('qbx_properties:server:addKeyholder', insidePlayers[i].citizenid)
                            end
                        end
                    }
                end
                lib.registerContext({
                    id = 'qbx_properties_insideMenu',
                    title = locale('menu.people_inside'),
                    menu = 'qbx_properties_keyMenu',
                    options = options
                })
                lib.showContext('qbx_properties_insideMenu')
            end
        }
    }
    for i = 1, #keyholders do
        options[#options + 1] = {
            title = keyholders[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = keyholders[i].name,
                    content = locale('alert.want_remove_keys'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:removeKeyholder', keyholders[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_keyMenu',
        title = locale('menu.keyholders'),
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_keyMenu')
end

local function prepareDoorbellMenu()
    local ringers = lib.callback.await('qbx_properties:callback:requestRingers')
    local options = {}
    for i = 1, #ringers do
        options[#options + 1] = {
            title = ringers[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = ringers[i].name,
                    content = locale('alert.want_let_person_in'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:letRingerIn', ringers[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_doorbellMenu',
        title = locale('menu.doorbell_ringers'),
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_doorbellMenu')
end

local function prepareManageMenu()
    local hasAccess = lib.callback.await('qbx_properties:callback:checkAccess')
    if not hasAccess then
        exports.qbx_core:Notify(locale('notify.no_access'), 'error')
        return
    end
    local options = {
        {
            title = locale('menu.manage_keys'),
            icon = 'key',
            arrow = true,
            onSelect = function()
                prepareKeyMenu()
            end
        },
        {
            title = locale('menu.doorbell'),
            icon = 'bell',
            arrow = true,
            onSelect = function()
                prepareDoorbellMenu()
            end
        },
        {
            title = locale('menu.start_decorating'),
            icon = 'shrimp',
            onSelect = function()
                ToggleDecorating()
            end
        },
        {
                title = 'Transfer Ownership',
                icon = 'user-tag',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Transfer Ownership', {
                        { type = 'input', label = 'Citizen ID (leave empty to reset)', placeholder = 'ABC12345' }
                    })
                    if input then
                        local citizenid = input[1] == '' and nil or input[1]
                        TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'owner', citizenid)
                    end
                end
            }
    }
    if isPropertyRental then
        options[#options + 1] = {
            title = 'Stop Renting',
            icon = 'file-invoice-dollar',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Stop Renting',
                    content = 'Are you sure that you want to stop renting this place?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:stopRenting')
                end
            end
        }
    end
    
    lib.registerContext({
        id = 'qbx_properties_manageMenu',
        title = locale('menu.manage_property'),
        options = options
    })
    lib.showContext('qbx_properties_manageMenu')
end

local function checkInteractions()
    local interactOptions = {
        ['stash'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.stash') })
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('qbx_properties:server:openStash')
            end
        end,
        ['exit'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.exit') })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:exitProperty')
            end
            if IsControlJustPressed(0, 47) then
                prepareManageMenu()
            end
        end,
        ['clothing'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.clothing') })
            if IsControlJustPressed(0, 38) then
                exports['illenium-appearance']:startPlayerCustomization(function(appearance)
                    if appearance then
                        TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
                    end
                end, {
                    components = true,
                    componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true, bodyArmor = true, shirts = true, decals = true, jackets = true },
                    props = true,
                    propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true },
                    enableExit = true,
                })
            end
            if IsControlJustPressed(0, 47) then
                TriggerEvent('illenium-appearance:client:openOutfitMenu')
            end
        end,
        ['logout'] = function(coords)
            qbx.drawText3d({ coords = coords, text = locale('drawtext.logout') })
            if IsControlJustPressed(0, 38) then
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
                TriggerServerEvent('qbx_properties:server:logoutProperty')
            end
        end,
    }
    CreateThread(function()
        while insideProperty do
            local sleep = 800
            local playerCoords = GetEntityCoords(cache.ped)
            for i = 1, #interactions do
                if #(playerCoords - interactions[i].coords) < 1.5 and not IsDecorating then
                    sleep = 0
                    interactOptions[interactions[i].type](interactions[i].coords)
                end
            end
            Wait(sleep)
        end
    end)
end

local function hideExterior(name)
    local models = clientConfig.exteriorHashs[name]
    if not models then return end
    CreateThread(function()
        while insideProperty do
            for i = 1, #models, 1 do
                EnableExteriorCullModelThisFrame(models[i])
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('qbx_properties:client:updateInteractions', function(interactionsData, interiorString, isRental)
    DoScreenFadeIn(1000)
    interactions = interactionsData
    insideProperty = true
    isPropertyRental = isRental
    checkInteractions()
    hideExterior(interiorString)
end)

RegisterNetEvent('qbx_properties:client:createInterior', function(interiorHash, interiorCoords)
    lib.requestModel(interiorHash, 2000)
    interiorShell = CreateObjectNoOffset(interiorHash, interiorCoords.x, interiorCoords.y, interiorCoords.z, false, false,
        false)
    FreezeEntityPosition(interiorShell, true)
    SetModelAsNoLongerNeeded(interiorHash)
end)

RegisterNetEvent('qbx_properties:client:loadDecorations', function(decorations)
    for i = 1, #decorations do
        local decoration = decorations[i]
        lib.requestModel(decoration.model, 5000)
        DecorationObjects[decoration.id] = CreateObjectNoOffset(decoration.model, decoration.coords.x,
            decoration.coords.y, decoration.coords.z, false, false, false)
        SetEntityCollision(DecorationObjects[decoration.id], true, true)
        FreezeEntityPosition(DecorationObjects[decoration.id], true)
        SetEntityRotation(DecorationObjects[decoration.id], decoration.rotation.x, decoration.rotation.y,
            decoration.rotation.z, 2, false)
        SetModelAsNoLongerNeeded(decoration.model)
    end
end)

RegisterNetEvent('qbx_properties:client:addDecoration', function(id, hash, coords, rotation)
    lib.requestModel(hash, 5000)
    DecorationObjects[id] = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(DecorationObjects[id], true)
    SetEntityRotation(DecorationObjects[id], rotation.x, rotation.y, rotation.z, 2, false)
    SetModelAsNoLongerNeeded(hash)
end)

RegisterNetEvent('qbx_properties:client:removeDecoration', function(objectId)
    if DoesEntityExist(DecorationObjects[objectId]) then DeleteEntity(DecorationObjects[objectId]) end
    DecorationObjects[objectId] = nil
end)

RegisterNetEvent('qbx_properties:client:unloadProperty', function()
    DoScreenFadeIn(1000)
    insideProperty = false
    if DoesEntityExist(interiorShell) then DeleteEntity(interiorShell) end
    for _, v in pairs(DecorationObjects) do
        if DoesEntityExist(v) then DeleteEntity(v) end
    end
    interiorShell = nil
    DecorationObjects = {}
end)

local function singlePropertyMenu(property, noBackMenu)
    local options = {}
    local isAdmin = lib.callback.await('qbx_properties:callback:isAdmin', false)

    if QBX.PlayerData.citizenid == property.owner or lib.table.contains(json.decode(property.keyholders), QBX.PlayerData.citizenid) then
        options[#options + 1] = {
            title = locale('menu.enter'),
            icon = 'cog',
            arrow = true,
            onSelect = function()
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
            end,
            serverEvent = 'qbx_properties:server:enterProperty',
            args = { id = property.id }
        }
    elseif property.owner == nil then
        if property.rent_interval then
            options[#options + 1] = {
                title = 'Rent',
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = string.format('Renting - %s', property.property_name),
                        content = string.format(
                        'Are you sure you want to rent %s for $%s which will be billed every %sh(s)?',
                            property.property_name, property.price, property.rent_interval),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:rentProperty', property.id)
                    end
                end,
            }
        else
            options[#options + 1] = {
                title = 'Buy',
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = string.format('Buying - %s', property.property_name),
                        content = string.format('Are you sure you want to buy %s for $%s?', property.property_name,
                            property.price),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:buyProperty', property.id)
                    end
                end,
            }
        end
    else
        options[#options + 1] = {
            title = locale('menu.ring_doorbell'),
            icon = 'bell',
            arrow = true,
            serverEvent = 'qbx_properties:server:ringProperty',
            args = { id = property.id }
        }
    end

    -- Admin Options
    if isAdmin then
        options[#options + 1] = {
            title = 'Edit Property',
            icon = 'pen-to-square',
            arrow = true,
            onSelect = function()
                TriggerEvent('qbx_properties:client:editPropertyMenu', property)
            end
        }
        options[#options + 1] = {
            title = 'Transfer Ownership',
            icon = 'user-tag',
            arrow = true,
            onSelect = function()
                local input = lib.inputDialog('Transfer Ownership', {
                    { type = 'input', label = 'Citizen ID (leave empty to reset)', placeholder = 'ABC12345' }
                })
                if input then
                    local citizenid = input[1] == '' and nil or input[1]
                    TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'owner', citizenid)
                end
            end
        }
        options[#options + 1] = {
            title = 'Delete Property',
            icon = 'trash',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Delete Property',
                    content = string.format('Are you sure you want to delete %s? This cannot be undone!',
                        property.property_name),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:deleteProperty', property.id)
                end
            end
        }
    end

    local menu = 'qbx_properties_propertiesMenu'
    ---@diagnostic disable-next-line: cast-local-type
    if noBackMenu then menu = nil end
    lib.registerContext({
        id = 'qbx_properties_propertyMenu',
        title = property.property_name,
        menu = menu,
        options = options
    })
    lib.showContext('qbx_properties_propertyMenu')
end

local function propertyMenu(propertyList, owned)
    local options = {
        {
            title = locale('menu.retrieve_properties'),
            description = locale('menu.show_owned_properties'),
            icon = 'bars',
            onSelect = function()
                propertyMenu(propertyList, true)
            end
        }
    }
    for i = 1, #propertyList do
        if owned and propertyList[i].owner == QBX.PlayerData.citizenid or lib.table.contains(json.decode(propertyList[i].keyholders), QBX.PlayerData.citizenid) then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        elseif not owned then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        end
    end
    lib.registerContext({
        id = 'qbx_properties_propertiesMenu',
        title = locale('menu.properties'),
        options = options
    })
    lib.showContext('qbx_properties_propertiesMenu')
end

function PreparePropertyMenu(propertyCoords)
    local propertyList = lib.callback.await('qbx_properties:callback:requestProperties', false, propertyCoords)
    if #propertyList == 1 then
        singlePropertyMenu(propertyList[1], true)
    else
        propertyMenu(propertyList)
    end
end

CreateThread(function()
    for i = 1, #sharedConfig.apartmentOptions do
        local data = sharedConfig.apartmentOptions[i]

        if not blips[data.enter] then
            blips[data.enter] = createBlip(data.enter, data.label)
        end
    end

    properties = lib.callback.await('qbx_properties:callback:loadProperties')
    while true do
        local sleep = 800
        local playerCoords = GetEntityCoords(cache.ped)
        for i = 1, #properties do
            if #(playerCoords - properties[i].xyz) < 2.6 then
                sleep = 0
                qbx.drawText3d({ coords = properties[i].xyz, text = locale('drawtext.view_property') })
                if IsControlJustPressed(0, 38) then
                    PreparePropertyMenu(properties[i])
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('qbx_properties:client:concealPlayers', function(playerIds)
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    concealWhitelist = playerIds
    if not isConcealing then
        isConcealing = true
        while isConcealing do
            players = GetActivePlayers()
            for i = 1, #players do
                if not lib.table.contains(concealWhitelist, GetPlayerServerId(players[i])) then
                    NetworkConcealPlayer(players[i], true, false)
                end
            end
            Wait(3000)
        end
    end
end)

RegisterNetEvent('qbx_properties:client:revealPlayers', function()
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    isConcealing = false
end)

RegisterNetEvent('qbx_properties:client:addProperty', function(propertyCoords)
    if lib.table.contains(properties, propertyCoords) then return end
    properties[#properties + 1] = propertyCoords
end)

RegisterNetEvent('qbx_properties:client:removeProperty', function(propertyCoords)
    for i = 1, #properties do
        if properties[i] == propertyCoords then
            table.remove(properties, i)
            break
        end
    end
end)

RegisterNetEvent('qbx_properties:client:editPropertyMenu', function(property)
    local sharedConfig = require 'config.shared'
    local interiorValues = {}
    for k in pairs(sharedConfig.interiors) do
        interiorValues[#interiorValues + 1] = k
    end

    lib.registerContext({
        id = 'qbx_properties_editMenu',
        title = 'Edit Property',
        menu = 'qbx_properties_propertyMenu',
        options = {
            {
                title = 'Edit Name',
                icon = 'signature',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Edit Property Name', {
                        { type = 'input', label = 'Property Name', default = property.property_name, required = true, min = 4, max = 32 }
                    })
                    if input then
                        TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'property_name', input
                        [1])
                    end
                end
            },
            {
                title = 'Edit Price',
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Edit Property Price', {
                        { type = 'number', label = 'Price', default = property.price, required = true, min = 1 }
                    })
                    if input then
                        TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'price', input[1])
                    end
                end
            },
            {
                title = 'Edit Rent Interval',
                icon = 'clock',
                arrow = true,
                onSelect = function()
                    local input = lib.inputDialog('Edit Rent Interval', {
                        { type = 'number', label = 'Rent Interval (hours, 0 = sell only)', default = property.rent_interval or 0, min = 0, max = 168 }
                    })
                    if input then
                        local value = input[1] == 0 and nil or input[1]
                        TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'rent_interval', value)
                    end
                end
            },
            {
                title = 'Edit Interior',
                icon = 'house',
                arrow = true,
                onSelect = function()
                    local options = {}
                    for i = 1, #interiorValues do
                        options[#options + 1] = {
                            title = interiorValues[i],
                            icon = 'door-open',
                            onSelect = function()
                                TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'interior',
                                    interiorValues[i])
                            end
                        }
                    end
                    lib.registerContext({
                        id = 'qbx_properties_interiorMenu',
                        title = 'Select Interior',
                        menu = 'qbx_properties_editMenu',
                        options = options
                    })
                    lib.showContext('qbx_properties_interiorMenu')
                end
            },
            -- {
            --     title = 'Move Enter Location',
            --     icon = 'location-dot',
            --     arrow = true,
            --     onSelect = function()
            --         local alert = lib.alertDialog({
            --             header = 'Move Enter Location',
            --             content = 'This will move the property entrance to your current location. Continue?',
            --             centered = true,
            --             cancel = true
            --         })
            --         if alert == 'confirm' then
            --             local coords = GetEntityCoords(cache.ped)
            --             TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'coords', coords)
            --         end
            --     end
            -- },
            {
                title = 'Edit Garage',
                icon = 'warehouse',
                arrow = true,
                onSelect = function()
                    TriggerEvent('qbx_properties:client:editGarageMenu', property)
                end
            },
            
        }
    })
    lib.showContext('qbx_properties_editMenu')
end)

RegisterNetEvent('qbx_properties:client:editGarageMenu', function(property)
    lib.registerContext({
        id = 'qbx_properties_garageMenu',
        title = 'Edit Garage',
        menu = 'qbx_properties_editMenu',
        options = {
            {
                title = 'Add/Move Garage',
                icon = 'plus',
                arrow = true,
                onSelect = function()
                    TriggerServerEvent('qbx_properties:server:startGarageEdit', property.id)
                end
            },
            {
                title = 'Remove Garage',
                icon = 'trash',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Remove Garage',
                        content = 'Are you sure you want to remove the garage from this property?',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:updateProperty', property.id, 'garage', nil)
                    end
                end
            }
        }
    })
    lib.showContext('qbx_properties_garageMenu')
end)