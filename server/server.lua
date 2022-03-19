local QBCore = exports['qb-core']:GetCoreObject()

local function GetCurrentEmployees(job)
    local job = job
    local players, amount = QBCore.Functions.GetPlayersOnDuty(job)
    return amount
end

local function GetStashItems(stashId)
	local items = {}
	local result = exports.oxmysql:scalarSync('SELECT items FROM stashitems WHERE stash = ?', {stashId})
	if result then
		local stashItems = json.decode(result)
		if stashItems then
			for k, item in pairs(stashItems) do
				local itemInfo = QBCore.Shared.Items[item.name:lower()]
				if itemInfo then
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"],
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						caliber = itemInfo["caliber"],
						slot = item.slot,
					}
				end
			end
		end
	end
	return items
end

local function organizeStash(job)
    local orgStash = {}
    local StashItems = GetStashItems(job .. "Stash")
    for k,v in pairs(StashItems) do
        if orgStash[v.name] ~= nil then
            orgStash[v.name].amount += v.amount
        else
            orgStash[v.name] = v
        end
    end
    return orgStash
end

QBCore.Functions.CreateCallback('qb-pos:server:GetBusinessItems', function(source, cb, job, fullList)
    local job = job
    local data = {}
    local items = {}
    local business = exports.oxmysql:singleSync('SELECT * FROM businesses WHERE name = ?', { job })
    if business ~= nil then
        data.businessid = business.id
        data.businessname = business.name
        local playerData = QBCore.Functions.GetPlayer(source).PlayerData
        data.entrantcitizenid = playerData.citizenid
        data.entrantlastname = playerData.charinfo.lastname
        data.entrantfirstname = playerData.charinfo.firstname
        local businessitems = exports.oxmysql:executeSync('SELECT * FROM business_items WHERE businessid = ?', { business.id })
        if businessitems[1] ~= nil then
            if not fullList then
                local orgStash = organizeStash(job)
                for k,v in pairs(businessitems) do
                    if orgStash[v.name] ~= nil then
                        items[#items+1] = {
                            id = v.id,
                            hash = v.name,
                            name = QBCore.Shared.Items[v.name].label,
                            image = QBCore.Shared.Items[v.name].image,
                            price = v.price,
                            quantity = orgStash[v.name].amount
                        }
                    end
                end
            else
                for k,v in pairs(businessitems) do
                    if orgStash[v.name] ~= nil then
                        items[#items+1] = {
                            id = v.id,
                            hash = v.name,
                            name = QBCore.Shared.Items[v.name].label,
                            image = QBCore.Shared.Items[v.name].image,
                            price = v.price,
                            quantity = orgStash[v.name].amount
                        }
                    end
                end
            end
        end
        data.items = items
    end
    cb(data)
end)

QBCore.Functions.CreateCallback('qb-pos:server:GetOnDuty', function(source, cb, job)
    local job = job
    local numEmployees = GetCurrentEmployees(job)
    cb(numEmployees)
end)

QBCore.Functions.CreateCallback('qb-pos:server:checkIngredients', function(source, cb, items) 
    for indexNum, itemInfo in pairs(items) do
        if QBCore.Functions.GetPlayer(source).Functions.GetItemByName(itemInfo.hash) == nil then
            cb(false)
        end
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('qb-pos:server:gatherDashboardData', function(source, cb)
    local src = source
    local data = {}
    local player = QBCore.Functions.GetPlayer(src)
    local business = exports.oxmysql:singleSync('SELECT * FROM businesses WHERE name = ?', { player.PlayerData.job.name })
    if business ~= nil then
        data.transactions = exports.oxmysql:executeSync('SELECT * FROM business_transactions WHERE businessid = ? AND date > ?', { business.id, os.date("%Y-%m-%d %H:%M:%S", os.time() - (28 * 24 * 60 * 60)) })
    end
    cb(data)
end)

RegisterNetEvent('qb-pos:server:prepareFood', function(business, workarea, craftItem, quantity)
    local player = QBCore.Functions.GetPlayer(source)
	if quantity == nil then
        quantity = 1
    end
    if Config.POSJobs[business].Items[craftItem].ingredients ~= nil then
        for k,v in pairs(Config.POSJobs[business].Items[craftItem].ingredients) do
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[v.hash], "remove", v.quantity)
            player.Functions.RemoveItem(v.hash, v.quantity)
        end
    end
    player.Functions.AddItem(craftItem, quantity, false, {quality = 100})
    local item = QBCore.Shared.Items[craftItem]
    item.quantity = quantity
	TriggerClientEvent('inventory:client:ItemBox', source, item, "add")
end)

RegisterNetEvent('qb-pos:server:addToRegister', function(data)
    local randomID = math.random(1111,9999)
    if Config.POSJobs[data.entrantData.businessname].ActiveOrders ~= nil then
        Config.POSJobs[data.entrantData.businessname].ActiveOrders[randomID] = { 
            items = data.data,
            entrantData = data.entrantData
        }
    end
    TriggerClientEvent('qb-pos:client:syncRegister', -1, Config.POSJobs[data.entrantData.businessname].ActiveOrders, data.entrantData.businessname)
end)

RegisterNetEvent('qb-pos:server:completeTransaction', function(entrantcitizenid, entrantfirstname, entrantlastname, businessname, businessid, items, price, key)
    local src = source
    local price = tonumber(price)
    local player = QBCore.Functions.GetPlayer(src)
    local canBuy = false
    local selfcheckout = key == nil
    if player ~= nil then
        local orgStash = organizeStash(businessname)
        local hasItems = true
        local total = 0
        if selfcheckout then
            for k,v in pairs(items) do
                if orgStash[k] ~= nil then
                    if orgStash[k].amount < v.ordered then
                        hasItems = false
                        break
                    else
                        total += exports.oxmysql:singleSync('SELECT price FROM business_items WHERE name = ? AND businessid = ?', { k, businessid }).price * v.ordered
                    end
                else
                    hasItems = false
                    break
                end
            end
        else
            for k,v in pairs(items) do
                total += exports.oxmysql:singleSync('SELECT price FROM business_items WHERE name = ? AND businessid = ?', { k, businessid }).price * v.ordered
            end
        end
        if hasItems then
            if player.Functions.GetMoney('cash') >= total then
                canBuy = true
                player.Functions.RemoveMoney('cash', total)
            elseif player.Functions.GetMoney('bank') >= total then
                canBuy = true
                player.Functions.RemoveMoney('bank', total)
            end
            if canBuy then
                TriggerEvent('qb-bossmenu:server:addAccountMoney', businessname, math.floor(total*0.75))
                TriggerEvent('qb-pos:server:receiveCommission', total, businessname)
                if selfcheckout then
                    for k,v in pairs(items) do
                        player.Functions.AddItem(k,v.ordered)
                        local item = QBCore.Shared.Items[k]
                        item.quantity = v.ordered
                        TriggerClientEvent('inventory:client:ItemBox', src, item, "add")
                        orgStash[k].amount -= v.ordered
                        if orgStash[k].amount == 0 then
                            orgStash[k] = nil
                        end
                    end
                    local StashItems = {}
                    for k,v in pairs(orgStash) do
                        StashItems[#StashItems + 1] = v
                    end
                    TriggerEvent('qb-inventory:server:SaveStashItems', businessname .. "Stash", StashItems)
                end
                exports.oxmysql:insert('INSERT INTO business_transactions (entrantcitizenid, entrantfirstname, entrantlastname, payercitizenid, payerfirstname, payerlastname, businessname, businessid, items, price, selfcheckout) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
                    entrantcitizenid, entrantfirstname, entrantlastname, player.PlayerData.citizenid, player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname, businessname, businessid, json.encode(items), price, selfcheckout
                })
                TriggerClientEvent('QBCore:Notify', src, 'You have completed the purchase.', 'success')
            end
            if not selfcheckout then
                Config.POSJobs[businessname].ActiveOrders[tonumber(key)] = nil
                TriggerClientEvent('qb-pos:client:syncRegister', -1, Config.POSJobs[businessname], businessname)
            end
        else
            if not selfcheckout then
                Config.POSJobs[businessname].ActiveOrders[tonumber(key)] = nil
                TriggerClientEvent('qb-pos:client:syncRegister', -1, Config.POSJobs[businessname], businessname)
            end
            TriggerClientEvent('QBCore:Notify', src, 'The items you ordered are no longer available.', 'error')
        end
    end
end)

RegisterNetEvent('qb-pos:server:receiveCommission', function(price, businessname)
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(v)
        if player ~= nil then
            if player.PlayerData.job.name == businessname and player.PlayerData.job.onduty then
				if math.floor(tonumber(price) * Config.POSJobs[businessname].Receipt.commission) > 0 then
					player.Functions.AddItem(Config.POSJobs[businessname].Receipt.receipt, 1, false, {["quality"] = 100, ["worth"] = math.floor(tonumber(price) * Config.POSJobs[businessname].Receipt.commission)})
					TriggerClientEvent('QBCore:Notify', player.PlayerData.source, QBCore.Shared.Items[Config.POSJobs[businessname].Receipt.receipt].label .. ' received', 'success')
					TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[Config.POSJobs[businessname].Receipt.receipt], "add", 1)
				end
            end
        end
    end
end)

RegisterNetEvent('qb-pos:server:turnInCommissions', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
	local pay = 0
	local tickets = nil
	local totaltickets = 0
	local tradeable = false
	local tickettypes = {}
    for k,v in pairs(Config.POSJobs) do
        if Config.POSJobs[k].Receipt ~= nil then
            tickettypes[#tickettypes + 1] = Config.POSJobs[k].Receipt.receipt
        end
    end
	for _, v in ipairs(tickettypes) do
		if player.Functions.GetItemsByName(v)[1] ~= nil then
			tradeable = true
			tickets = player.Functions.GetItemsByName(v)
			for _,ve in pairs(tickets) do
				pay = pay + ve.info.worth
			end
			for i=1, #tickets, 1 do
				totaltickets = totaltickets + 1
				player.Functions.RemoveItem(v, 1)
			end
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[v], "remove", #tickets)
		end
	end
	if tradeable then 
		player.Functions.AddMoney('bank', pay, 'receipts')
		TriggerClientEvent('QBCore:Notify', src, "Tickets: "..totaltickets.." Total: $"..pay, 'success')
	else
		TriggerClientEvent('QBCore:Notify', src, "No tickets to trade", 'error')
	end
end)

RegisterNetEvent("qb-pos:server:setPrice", function(id, price)
    local price = tonumber(price)
    local id = tonumber(id)
    exports.oxmysql:execute('UPDATE business_items SET price = ? WHERE id = ?', { tonumber(price), tonumber(id) })
end)

RegisterNetEvent('qb-pos:server:washDirtyMoney', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local items = {}
    local purchasedItems = {}
    local total = 0
    local markedbills = player.Functions.GetItemByName("markedbills")
    if markedbills ~= nil then
        local worth = tonumber(markedbills.info.worth)
        local business = exports.oxmysql:singleSync('SELECT * FROM businesses WHERE name = ?', { player.PlayerData.job.name })
        if business ~= nil then
            local businessitems = exports.oxmysql:executeSync('SELECT * FROM business_items WHERE businessid = ?', { business.id })
            if businessitems[1] ~= nil then
                for k,v in pairs(businessitems) do
                    items[#items+1] = {
                        id = v.id,
                        hash = v.name,
                        name = QBCore.Shared.Items[v.name].label,
                        image = QBCore.Shared.Items[v.name].image,
                        price = v.price
                    }
                end
            end
        end
        while total < worth do
            local randomItem = items[math.random(#items)]
            if purchasedItems[randomItem.hash] ~= nil then
                purchasedItems[randomItem.hash].ordered += 1
            else
                purchasedItems[randomItem.hash] = {
                    ordered = 1,
                    price = randomItem.price,
                    image = 'nui://qb-inventory/html/images/' .. randomItem.image,
                    label = randomItem.name
                }
            end
            total += randomItem.price
        end
        local randomPurchaser = exports.oxmysql:singleSync('SELECT * FROM players ORDER BY RAND () LIMIT 1')
        if randomPurchaser ~= nil then
            local charinfo = json.decode(randomPurchaser.charinfo)
            exports.oxmysql:execute('INSERT INTO business_transactions (entrantcitizenid, entrantfirstname, entrantlastname, payercitizenid, payerfirstname, payerlastname, businessname, businessid, items, price, selfcheckout) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
                {
                    player.PlayerData.citizenid,
                    player.PlayerData.charinfo.firstname,
                    player.PlayerData.charinfo.lastname,
                    randomPurchaser.citizenid,
                    charinfo.firstname,
                    charinfo.lastname,
                    player.PlayerData.job.name,
                    business.id,
                    json.encode(purchasedItems),
                    worth,
                    false
                }
            )
            player.Functions.RemoveItem('markedbills', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "remove")
            TriggerEvent('qb-bossmenu:server:addAccountMoney', player.PlayerData.job.name, worth)
        end
    end
end)

CreateThread(function()
    for k,v in pairs(Config.POSJobs) do
        if Config.POSJobs[k].Items ~= nil then
            for i,j in pairs(Config.POSJobs[k].Items) do
                if j.food then
                    QBCore.Functions.CreateUseableItem(i, function(source, item) if QBCore.Functions.GetPlayer(source).Functions.RemoveItem(item.name, 1, item.slot) then TriggerClientEvent("consumables:client:Eat", source, item.name) end end)
                elseif j.drink then
                    QBCore.Functions.CreateUseableItem(i, function(source, item) if QBCore.Functions.GetPlayer(source).Functions.RemoveItem(item.name, 1, item.slot) then TriggerClientEvent("consumables:client:Drink", source, item.name) end end)
                end
            end
        end
    end
end)

QBCore.Commands.Add('manDash', 'Management Dashboard', {}, false, function(source)
    TriggerClientEvent('qb-pos:client:ManagementDashboard', source)
end)