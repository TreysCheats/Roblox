repeat wait() until game:IsLoaded() and workspace.dungeonProgress.Value == 'inProgress'


--< defines >--

local reload = game:GetService('ReplicatedStorage').remotes.reloadInvy

local lPlr = game.Players.LocalPlayer
local status = lPlr.PlayerGui.playerStatus.Frame
local stats = { ['level'] = '?', ['gold'] = '?', ['xp'] = '?', ['name'] = '?'}

if not _G.settings.hideStats then
	stats['level']	= lPlr.leaderstats.Level.Value
	stats['gold']	= status.moneyMain.TextLabel.Text
	stats['xp']		= '(' .. status.xpFrame.xp.Text .. ')'
end
if not _G.settings.hideName then
	stats['name']	= lPlr.Name
end

local loot = {}
local prefix = {
	['common'] 		= ':white_circle: ',
	['uncommon']	= ':green_circle: ',
	['rare']		= ':blue_circle: ',
	['epic']		= ':purple_circle: ',
	['legendary']	= ':yellow_circle: ',
	['mythical']	= ':red_circle: ',
}


--< functions >--

function validTime(time)
	local minutes 	= math.round((time - time % 60) / 60)
	local seconds	= math.round(time - minutes * 60)
	local str = ''
	
	str = (minutes < 10) and str .. '0' .. minutes .. ':' or str .. minutes .. ':'
	str = (seconds < 10) and str .. '0' .. seconds or str .. seconds
	
	return { minutes, seconds, str }
end

function getItemTable(t, i)
	local inv = reload:InvokeServer()
	return inv[t ~= 'ability' and t .. 's' or 'abilities'][t .. '_' .. i]
end
function addItem(item)
	if item.physicalDamage or item.physicalPower then
		local weapon 	= item.physicalDamage
		local phy		= weapon and item.physicalDamage or item.physicalPower
		local spe		= item.spellPower
	
		local class 	= (phy > spe) and ' [Warrior]' or ' [Mage]'
		
		local name = prefix[item.rarity] .. item.name .. class
		if item.rarity == 'epic' then
			for _,v in pairs(_G.collectables) do
				if string.sub(item.name, 1, #_) == _ then
					name = name .. ' (COLLECT)'
				end
			end
		end
		
		local value
		local s = weapon and 'Physical Damage: ' or 'Physical Power: '
		value = '```' .. s .. phy .. '\nSpell Power: ' .. spe .. '\nRequired Level: ' .. item.levelReq .. '\nUpgrades: ' .. item.maxUpgrades .. '```'
		
		table.insert(loot, { ['name'] = name, ['value'] = value })
	else
		if string.find(item.description, 'Mage') or string.find(item.description, 'Spell') then
			table.insert(loot, { ['name'] = prefix[item.rarity] .. item.name .. ' [Mage]', ['value'] = '```Required Level: ' .. item.levelReq .. '```' })
		else
			table.insert(loot, { ['name'] = prefix[item.rarity] .. item.name .. ' [Warrior]', ['value'] = '```Required Level: ' .. item.levelReq .. '```' })
		end
	end
end
function doRequest()
	local msg = {
		['embeds'] = {
			{
				['title']		= 'Ez Quest | ' .. game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name .. ' | ' .. validTime(os.time() - workspace.start.startTime.Value)[3],
				['color'] 		= 8421504,
				['fields']		= {
					loot[1],
					loot[2],
					loot[3]
				},
				['footer'] 		= {
					['text'] = '⭐ LVL: ' .. stats['level'] .. ' | EXP: ' .. stats['xp'] .. ' | Gold: ' .. stats['gold'] .. ' ⭐\n'
					.. stats['name']
				},
				['timestamp']	= DateTime.now():ToIsoDate()
			}
		}
	}
	
	request({
		Url = _G.settings.webhook,
		Method = 'POST',
		Headers = { ['content-type'] = 'application/json' },
		Body = game:GetService('HttpService'):JSONEncode(msg)
	})
end


--< main >--

local num = 1
if workspace.hardcore.Value == true then num += 1 end
if lPlr.extraItemGamepass.Value == true then num += 1 end

lPlr.PlayerGui:WaitForChild('inventory').mainBackground.innerBackground.rightSideFrame.ScrollingFrame.ChildAdded:Connect(function(c)
	local type 	= c:WaitForChild('itemType')
	local id 	= type:WaitForChild('uniqueItemNum')
	local tab	= getItemTable(type.Value, id.Value)
	
	addItem(tab)
	if #loot == num then
		doRequest()
	end
end)
