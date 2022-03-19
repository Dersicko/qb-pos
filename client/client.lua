local QBCore = exports['qb-core']:GetCoreObject()
local showMenu = false
local onDuty = false
local PlayerJob = nil

local function compare(a,b)
    if a.header ~= nil and b.header ~= nil then
        return a.header < b.header
    else
        return a.txt < b.txt
    end
end

local function ShowIfNoEmployees(job)
    local job = job
    local retval = false
    local calc = nil
    QBCore.Functions.TriggerCallback('qb-pos:server:GetOnDuty', function(numEmployees)
        if numEmployees == 0 then
            retval =  true
        end
        calc = true
    end, job)
    while calc == nil do
        Wait(1)
    end
    return retval
end

local function ShowIfEmployees(job)
    local job = job
    local retval = true
    local calc = nil
    QBCore.Functions.TriggerCallback('qb-pos:server:GetOnDuty', function(numEmployees)
        if numEmployees == 0 then
            retval =  false
        end
        calc = true
    end, job)
    while calc == nil do
        Wait(1)
    end
    return retval
end

local function CheckManager()
    return PlayerJob.isboss
end

local function ShowIfDirtyMoney(job)
    local job = job
    local retval = false
    local calc = nil
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(data)
        if data then
            retval = true
        end
        calc = true
    end, "markedbills")
    while calc == nil do
        Wait(1)
    end
    return retval
end

local function PrepareFood(foodItem)
    local playerJob = QBCore.Functions.GetPlayerData().job.name
    if Config.POSJobs[playerJob].Items[foodItem] ~= nil then
        progresstext = Config.POSJobs[playerJob].WorkAreas[Config.POSJobs[playerJob].Items[foodItem].workarea].progressText .. " " .. QBCore.Shared.Items[foodItem].label
        progresstime = Config.POSJobs[playerJob].WorkAreas[Config.POSJobs[playerJob].Items[foodItem].workarea].progressTime
        animDict = Config.POSJobs[playerJob].WorkAreas[Config.POSJobs[playerJob].Items[foodItem].workarea].animDict
        anim = Config.POSJobs[playerJob].WorkAreas[Config.POSJobs[playerJob].Items[foodItem].workarea].anim
    end
    QBCore.Functions.Progressbar('making_food', progresstext, progresstime, false, false, {
		disableMovement = true, --
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {
		animDict = animDict,
		anim = anim,
		flags = 8,
	}, {}, {}, function()  
		TriggerServerEvent('qb-pos:server:prepareFood', playerJob, Config.POSJobs[playerJob].Items[foodItem].workarea, foodItem, Config.POSJobs[playerJob].Items[foodItem].quantity)
		StopAnimTask(PlayerPedId(), animDict, anim, 1.0)
	end, function() -- Cancel
		TriggerEvent('inventory:client:busy:status', false)
		QBCore.Functions.Notify('Cancelled!', 'error')
	end)
end

AddEventHandler("onResourceStart", function(resourceName)
	if ("qb-pos" == resourceName) then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        onDuty = PlayerJob.onduty
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
	if ("qb-pos" == resourceName) then
        showMenu = false
        onDuty = false
        PlayerJob = nil
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = QBCore.Functions.GetPlayerData().job.onduty
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    for k,v in pairs(Config.POSJobs) do
        PlayerJob = QBCore.Functions.GetPlayerData().job
        if k == PlayerJob.name then
            onDuty = false
            if PlayerJob.onduty then
                TriggerServerEvent("QBCore:ToggleDuty")
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    for k,v in pairs(Config.POSJobs) do
        if PlayerJob.name == k and PlayerJob.onduty then
            TriggerServerEvent("QBCore:ToggleDuty")
            break
        end
    end
end)


RegisterNetEvent('qb-pos:client:toggleDuty', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    QBCore.Functions.TriggerCallback('qb-pos:server:GetOnDuty', function(onDutyCount)
        if onDutyCount ~= nil then
            if not PlayerJob.onduty and onDutyCount >= Config.POSJobs[PlayerJob.name].MaxEmployees then
                QBCore.Functions.Notify('There are too many employees clocked in currently.', 'error')
            else
                onDuty = not PlayerJob.onduty
                TriggerServerEvent("QBCore:ToggleDuty")
            end    
        end
    end, PlayerJob.name)
end)

RegisterNetEvent('qb-pos:client:petting', function(data)
    local animalString = 'Giving a good pet'
    if Config.POSJobs[data.params.job].AnimalSayings ~= nil then
        animalString = Config.POSJobs[data.params.job].AnimalSayings[math.random(#Config.POSJobs[data.params.job].AnimalSayings)]
    end
    QBCore.Functions.RequestAnimDict("creatures@rottweiler@tricks@")
    TaskPlayAnim(PlayerPedId(), 'creatures@rottweiler@tricks@', 'petting_franklin' , 3.0, 3.0, -1, 1, 0, false, false, false)
    QBCore.Functions.Progressbar("pet_the_kitty", animalString, 2000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "creatures@rottweiler@tricks@", "petting_franklin", 1.0)
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "creatures@rottweiler@tricks@", "petting_franklin", 1.0)
    end)
    TriggerServerEvent('hud:server:RelieveStress', 5)
end)

RegisterNetEvent('qb-pos:client:openRestaurant', function(data)
    local data = data
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = PlayerJob.onduty
    if onDuty then
        TriggerEvent('qb-pos:client:openPOS', data.params.job)
    else
        QBCore.Functions.Notify('You need to clock in.', 'error')
    end
end)

RegisterNetEvent('qb-pos:client:openPOS', function(job)
    local job = job
    QBCore.Functions.TriggerCallback('qb-pos:server:GetBusinessItems', function(data)
        local data = data
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'pos', data = data })
    end, job)
end)

RegisterNetEvent('qb-pos:client:openSelfCheckout', function(job)
    local job = job.params.job
    QBCore.Functions.TriggerCallback('qb-pos:server:GetBusinessItems', function(data)
        local data = data
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'selfcheckout', data = data })
    end, job)
end)

RegisterNetEvent('qb-pos:client:syncRegister', function(RegisterConfig, businessName)
    Config.POSJobs[businessName].ActiveOrders = RegisterConfig
end)

RegisterNetEvent('qb-pos:client:openPayment', function(data)
    SetNuiFocus(true, true)
    showMenu = true
    SendNUIMessage({ type = 'openPayment', data = Config.POSJobs[data.params.job].ActiveOrders })
end)

RegisterNetEvent('qb-pos:client:openStash', function(data)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id)
	TriggerEvent("inventory:client:SetCurrentStash", data.id)
end)

RegisterNetEvent('qb-pos:client:sinkWashHands', function()
    QBCore.Functions.Progressbar('washing_hands', 'Washing hands', 5000, false, false, {
        disableMovement = true, --
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_arresting", 
        anim = "a_uncuff", 
        flags = 8,
    }, {}, {}, function()  
		TriggerEvent('QBCore:Notify', "You\'ve washed your hands!", 'success')
    end, function() -- Cancel
        TriggerEvent('inventory:client:busy:status', false)
		TriggerEvent('QBCore:Notify', "Cancelled", 'error')
    end)
end)

RegisterNetEvent('qb-pos:client:sinkWashDirtyMoney', function()
    QBCore.Functions.Progressbar('washing_hands', 'Washing hands', 5000, false, false, {
        disableMovement = true, --
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_arresting", 
        anim = "a_uncuff", 
        flags = 8,
    }, {}, {}, function()  
		TriggerEvent('QBCore:Notify', "You\'ve washed your hands!", 'success')
        TriggerServerEvent('qb-pos:server:washDirtyMoney')
    end, function() -- Cancel
        TriggerEvent('inventory:client:busy:status', false)
		TriggerEvent('QBCore:Notify', "Cancelled", 'error')
    end)
end)

RegisterNetEvent('qb-pos:client:ManagementDashboard', function()
    QBCore.Functions.TriggerCallback('qb-pos:server:gatherDashboardData', function(data)
        if data then
            data.jobtitle = PlayerJob.name
            SetNuiFocus(true, true)
            SendNUIMessage({
                type='manDash',
                data = data
            })
        else
            QBCore.Functions.Notify('Unable to get data', 'error')
        end
    end)
end)

RegisterNetEvent('qb-pos:client:makeItem', function(data)
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = PlayerJob.onduty
	if onDuty then
        local playerJob = QBCore.Functions.GetPlayerData().job.name
        if Config.POSJobs[playerJob].Items[data.item] ~= nil then
			QBCore.Functions.TriggerCallback('qb-pos:server:checkIngredients', function(amount) 
				if amount then
                    PrepareFood(data.item)
                else
                    QBCore.Functions.Notify("You don't have the correct ingredients", 'error')
                end
			end, Config.POSJobs[playerJob].Items[data.item].ingredients)
		end
    else
        QBCore.Functions.Notify("Not clocked in!", 'error')
	end
end)

RegisterNetEvent('qb-pos:client:accessWorkArea', function(data)
    local playerJob = QBCore.Functions.GetPlayerData().job.name
    local menuItems = { { isMenuHeader = true, header = ' ' .. data.label } }
    if data.params ~= nil then
        for k,v in pairs(Config.POSJobs[playerJob].Items) do
            if v.workarea == data.params.workarea then
                if v.ingredients ~= nil then
                    local textString = 'Ingredients:'
                    for i,j in pairs(v.ingredients) do
                        textString = textString .. '<br> - ' .. QBCore.Shared.Items[j.hash].label
                    end
                    menuItems[#menuItems+1] = {
                        header = QBCore.Shared.Items[k].label, txt = textString, params = { event = 'qb-pos:client:makeItem', args = { item = k } }
                    }
                else
                    menuItems[#menuItems+1] = {
                        header = QBCore.Shared.Items[k].label, txt = '', params = { event = 'qb-pos:client:giveItem', args = { item = k } }
                    }
                end
            end
        end
        table.sort(menuItems, compare)
        exports['qb-menu']:openMenu(menuItems)
    else
        QBCore.Functions.Notify('The work area ' .. data.label .. ' for ' .. data.job .. ' was not set up correctly.')
    end
end)

RegisterNetEvent('qb-pos:client:priceMenu', function()
	QBCore.Functions.TriggerCallback('qb-pos:server:GetBusinessItems', function(data)
        local priceMenu = { { header = " " .. string.upper(PlayerJob.name) .. " PRICE MENU", isMenuHeader = true } }
        for k,v in pairs(data.items) do
            priceMenu[#priceMenu+1] = {
                header = QBCore.Shared.Items[v.hash].label,
                txt = '$' .. v.price,
                params = {
                    event = 'qb-pos:client:setPrice',
                    args = {
                        itemName = v.hash,
                        id = v.id
                    }
                }
            }
        end
        table.sort(priceMenu,compare)
        priceMenu[#priceMenu+1] = {
            header = "< Return",
            params = {
                event = "qb-pos:client:priceMenu",
            }
        },
		exports['qb-menu']:openMenu(priceMenu)
	end, PlayerJob.name)
end)

RegisterNetEvent('qb-pos:client:setPrice', function(item)
	local deposit = exports['qb-input']:ShowInput({
		header = "Set price for " .. item.itemName,
		submitText = "Confirm",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'price',
				text = 'Price'
			}
		}
	})
	if deposit then
		if not deposit.price then return end
		TriggerServerEvent("qb-pos:server:setPrice", tonumber(item.id), tonumber(deposit.price))
	end
    TriggerEvent('qb-pos:client:priceMenu')
end)

RegisterNetEvent('qb-pos:client:giveItem', function(data)
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = PlayerJob.onduty
    if onDuty then
        PrepareFood(data.item)
    else
        QBCore.Functions.Notify('Not clocked in!', 'error')
    end
end)

RegisterNUICallback('closePOS', function()
    showMenu = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('SendRegister', function(data, cb)
    TriggerServerEvent('qb-pos:server:addToRegister', data)
    cb(true)
end)

RegisterNUICallback('AcceptTransaction', function(data, cb)
    local key = tostring(data.key)
    TriggerServerEvent('qb-pos:server:completeTransaction', 
        data.entrantData[key].entrantData.entrantcitizenid,
        data.entrantData[key].entrantData.entrantfirstname,
        data.entrantData[key].entrantData.entrantlastname,
        data.entrantData[key].entrantData.businessname,
        data.entrantData[key].entrantData.businessid,
        data.data,
        data.total,
        key
    )
    cb(true)
end)

RegisterNUICallback('SelfCheckout', function(data, cb)
    TriggerServerEvent('qb-pos:server:completeTransaction', 
        data.entrantData.entrantcitizenid, 
        data.entrantData.entrantfirstname,
        data.entrantData.entrantlastname,
        data.entrantData.businessname,
        data.entrantData.businessid,
        data.data,
        data.total
    )
    cb(true)
end)

RegisterNUICallback('EmptyCart', function()
    QBCore.Functions.Notify('There are no items associated with this purchase.', 'error')
end)

CreateThread(function()
    for k,v in pairs(Config.POSJobs) do
        if Config.POSJobs[k].Locations ~= nil then
            for i,j in pairs(Config.POSJobs[k].Locations) do
                QBCore.Functions.CreateBlip(vector3(j.coords.x, j.coords.y, j.coords.z), j.blip, 2, 0.6, j.color, true, j.label)
            end
        end
        if Config.POSJobs[k].Registers ~= nil then
            for i,j in pairs(Config.POSJobs[k].Registers) do
                exports['qb-target']:AddCircleZone(k .. "Register" .. i, j.coords, j.radius, { name=k .. "Register" .. i, debugPoly=false, useZ=true, },
                    { options = { 
                        { type = "client", event = "qb-pos:client:openRestaurant", icon = "fas fa-credit-card", label = "Charge Customer", job = k, params = { job = k, }, position = 1 },
                        { type = "client", event = "qb-pos:client:openPayment", icon = "fas fa-cash-register", label = "Make Payment", params = { job = k, }, position = 2, canInteract = function() return ShowIfEmployees(k) end },
                        { type = "client", event = "qb-pos:client:openSelfCheckout", icon = 'fas fa-cash-register', label = "Self Checkout", params = { job = k, }, position = 3, canInteract = function() return ShowIfNoEmployees(k) end }
                    },
                    distance = 1.5
                })
            end
        end
        if Config.POSJobs[k].Stash ~= nil then
            for i,j in pairs(Config.POSJobs[k].Stash) do
                exports['qb-target']:AddCircleZone(k .. "Stash", j.coords, j.radius, { name=k .. "Stash", debugPoly=false, useZ = true, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:openStash', icon = "fas fa-box-open", label = 'Open Stash', job = k, id = k .. "Stash", position = 1 }, 
                    },
                    distance = 1.5
                })
            end
        end
        if Config.POSJobs[k].Trays ~= nil then
            for i,j in pairs(Config.POSJobs[k].Trays) do
                exports['qb-target']:AddCircleZone(k .. "Tray" .. i, j.coords, j.radius, { name=k .. "Tray" .. i, debugPoly=false, useZ = true, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:openStash', icon = j.icon, label = 'Open Tray', id = k .. "Tray" .. i, position = 1 }, 
                    },
                    distance = 1.5
                })
            end
        end
        if Config.POSJobs[k].Sinks ~= nil then
            for i,j in pairs(Config.POSJobs[k].Sinks) do
                exports['qb-target']:AddCircleZone(k .. "Sink" .. i, j.coords, j.radius, { name=k .. "Sink" .. i, debugPoly=false, useZ = true, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:sinkWashHands', icon = 'fas fa-hand-holding-water', label = 'Wash Hands', job = k, position = 1 },
                        { type = "client", event = 'qb-pos:client:sinkWashDirtyMoney', icon = 'fas fa-donate', label = 'Wash Dirty Money', job = k, position = 2, canInteract = function() return ShowIfDirtyMoney(k) end }, 
                    },
                    distance = 1.5
                })
            end
        end
        if Config.POSJobs[k].WorkAreas ~= nil then
            for i,j in pairs(Config.POSJobs[k].WorkAreas) do
                exports['qb-target']:AddBoxZone(k .. i, j.coords, j.width, j.height, 
                    { name=k .. i, heading = j.heading, debugPoly=false, minZ = j.coords.z - 1.0, maxZ = j.coords.z + 1.0, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:accessWorkArea', icon = j.icon, label = j.label, job = k, params = { workarea = i } }, 
                    },
                    distance = 2.0
                })
            end
        end
        if Config.POSJobs[k].TimeClocks ~= nil then
            for i,j in pairs(Config.POSJobs[k].TimeClocks) do
                exports['qb-target']:AddBoxZone(k .. 'timeclock' .. i, j.coords, j.width, j.height, 
                    { name=k .. 'timeclock' .. i, heading = j.heading, debugPoly=false, minZ = j.coords.z - 1.0, maxZ = j.coords.z + 1.0, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:toggleDuty', icon = j.icon, label = j.label, job = k, position = 1 }, 
                        { type = 'client', event = 'qb-pos:client:priceMenu', icon = 'fas fa-folder-open', label = 'Menu Management', job = k, canInteract = function() return CheckManager() end, position = 2 },
                        { type = 'client', event = 'fivem-appearance:outfitsMenu', icon = 'fas fa-tshirt', label = 'Clothing', job = k, position = 3},
                    },
                    distance = 2.0
                })
            end
        end
        if Config.POSJobs[k].Perimeter ~= nil then
            for i,j in pairs(Config.POSJobs[k].Perimeter) do
                Config.POSJobs[k].Perimeter[i].ZoneObject = PolyZone:Create(Config.POSJobs[k].Perimeter[i].zone, {
                    name= k .. 'Perimeter' .. i,
                    minZ = Config.POSJobs[k].Perimeter[i].minZ,
                    maxZ = Config.POSJobs[k].Perimeter[i].maxZ
                  })
            end
        end
        if Config.POSJobs[k].Fridge ~= nil then
            for i,j in pairs(Config.POSJobs[k].Fridge) do
                exports['qb-target']:AddBoxZone(k .. 'fridge' .. i, j.coords, j.width, j.height, 
                    { name=k .. 'fridge' .. i, heading = j.heading, debugPoly=false, minZ = j.coords.z - 1.0, maxZ = j.coords.z + 1.0, }, 
                    { options = { 
                        { type = "client", event = 'qb-pos:client:openStash', icon = j.icon, label = 'Open Fridge', id = k .. "Fridge" .. i, position = 1 }, 
                    },
                    distance = 2.0
                })
            end
        end
        if Config.POSJobs[k].Animals ~= nil then
            if Config.POSJobs[k].Animals.models ~= nil then
                for i,j in pairs(Config.POSJobs[k].Animals.models) do
                    if i == 1 then
                        exports['qb-target']:SpawnPed({
                            [1] = {
                                model = Config.POSJobs[k].Animals.hash,
                                coords = j.coords,
                                minusOne = true,
                                freeze = false,
                                invincible = true,
                                blockevents = true,
                                spawnNow = true,
                                target = {
                                    options = {
                                        {
                                            type ="client",
                                            event = "qb-pos:client:petting",
                                            icon = Config.POSJobs[k].Animals.icon,
                                            label = Config.POSJobs[k].Animals.label,
                                            animdict = Config.POSJobs[k].Animals.animDict,
                                            anim = Config.POSJobs[k].Animals.anim,
                                            params = { job = k },
                                        },
                                    },
                                    distance = 1.0,
                                },
                                currentpednumer = 0,
                            }
                        })
                    else
                        local hash = GetHashKey(Config.POSJobs[k].Animals.hash)
                        QBCore.Functions.LoadModel(hash)
                        if j.sitting  == true then
                            ped = CreatePed(28, hash, j.coords.x, j.coords.y, j.coords.z - 0.9, j.coords.w, false, true)
                            QBCore.Functions.RequestAnimDict(Config.POSJobs[k].Animals.animDict)
                            TaskPlayAnim(ped, Config.POSJobs[k].Animals.animDict, Config.POSJobs[k].Animals.anim,8.0, -8, -1, 1, 0, false, false, false)
                            SetPedCanBeTargetted(ped, false)
                            SetEntityAsMissionEntity(ped, true,true)
                            SetBlockingOfNonTemporaryEvents(ped, true)
                        else
                            ped = CreatePed(28, hash, j.coords.x, j.coords.y, j.coords.z - 1.0, j.coords.w, false, true)
                            SetPedCanBeTargetted(ped, false)
                            SetEntityAsMissionEntity(ped, true,true)
                            TaskWanderStandard(ped, 0, 0)
                            SetBlockingOfNonTemporaryEvents(ped, true)
                        end
                    end
                end
            end
        end
    end
    exports['qb-target']:AddCircleZone('receiptTurnIn', vector3(241.67, 226.11, 106.92), 0.5, 
        { name='receiptTurnIn', debugPoly=false, useZ = true, }, 
        { options = { 
            { type = "server", event = 'qb-pos:server:turnInCommissions', icon = 'fas fa-receipt', label = 'Turn in Receipts', }, 
        },
        distance = 2.0
    })
end)

CreateThread(function()
    while true do
        local clockedIn = false
        PlayerJob = QBCore.Functions.GetPlayerData().job
        if PlayerJob ~= nil then
            onDuty = PlayerJob.onduty
            if Config.POSJobs[PlayerJob.name] ~= nil then
                if PlayerJob.onduty then
                    if Config.POSJobs[PlayerJob.name].Perimeter ~= nil then
                        for k,v in pairs(Config.POSJobs[PlayerJob.name].Perimeter) do
                            if v.ZoneObject ~= nil then
                                if v.ZoneObject:isPointInside(GetEntityCoords(PlayerPedId())) then
                                    clockedIn = true
                                end
                            end
                        end
                        if clockedIn ~= true then
                            TriggerEvent("qb-pos:client:toggleDuty")
                        end
                    end
                end
            end
        end
        Wait(5000)
    end
end)