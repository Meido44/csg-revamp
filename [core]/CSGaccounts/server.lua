-- Database connection
db = exports.DENmysql:getConnection()

-- Tables
local weaponStringTable = {}
local playerWeaponTable = {}
local forbiddenWeapons = {[18] = true, [36] = true, [37] = true, [38] = true} -- Minigun, RPG, heatseaker, molotov are all forbidden

-- When the player login
addEvent("onServerPlayerLogin")
addEventHandler("onServerPlayerLogin", root,
	function (userID)
		db:query(cacheWeapons, {source}, "SELECT `weapons` FROM `accounts` WHERE `id`=?", userID)
	end
)

function cacheWeapons(qh, plr)
	if (not plr or not isElement(plr) or plr.type ~= "player") then return end
	local weaponTable = qh:poll(0)
	if (weaponTable and #weaponTable == 1) then
		-- Since the weapons column is a JSON string, we need to make it a normal Lua table
		playerWeaponTable[plr] = fromJSON(weaponTable[1].weapons)
		
		-- Call the other functions
		givePlayerWeapons(plr)
		setPlayerWeaponString(plr, weaponTable[1].weapons)
	end
end

function givePlayerWeapons(plr)
	if (not plr or not isElement(plr) or plr.type ~= "player") then return end
	local weaponTable = playerWeaponTable[plr]
	for weapon, ammo in pairs(weaponTable) do
		if (not forbiddenWeapons[tonumber(weapon)] and ammo > 0) then
			giveWeapon(plr, weapon, ammo)
		end
	end
end

function setPlayerWeaponString(plr, weaponString)
	if (not plr or not weaponString or not isElement(plr) or plr.type ~= "player") then return end
	if (weaponTable) then
		weaponStringTable[plr] = weaponString
	end
end

-- Function that checks if the player owns this weapons
function doesPlayerHaveWeapon(thePlayer, theWeapon)
	if (playerWeaponTable[thePlayer]) and(playerWeaponTable[thePlayer][tonumber(theWeapon)]) then
		if (playerWeaponTable[thePlayer][tonumber(theWeapon)] == 1) then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Function that gives the player the weapon
function setPlayerOwnedWeapon(thePlayer, theWeapon, theState)
	if (theState) then theState = 1 else theState = 0 end
	if not (thePlayer) or not (theWeapon) then return false end
	
	if (playerWeaponTable[thePlayer]) and (playerWeaponTable[thePlayer][tonumber(theWeapon)]) then
		if (exports.server:exec("UPDATE `weapons` SET `??`=? WHERE `userid`=?", tonumber(theWeapon), theState, expors.server:getPlayerAccountID(thePlayer))) then
			playerWeaponTable[thePlayer][tonumber(theWeapon)] = theState
			return true
		else
			return false
		end
	else
		return exports.server:exec("UPDATE `weapons` SET `??`=? WHERE `userid`=?", tonumber(theWeapon), theState, exports.server:getPlayerAccountID(thePlayer))
	end
end

-- Function to give player money
function addPlayerMoney(thePlayer, theMoney)
	if (givePlayerMoney(thePlayer, tonumber(theMoney))) and (exports.server:getPlayerAccountID(thePlayer)) then
		exports.DENmysql:exec("UPDATE `accounts` SET `money`=? WHERE `id`=?", (tonumber(theMoney) + getPlayerMoney(thePlayer)), exports.server:getPlayerAccountID(thePlayer))
		return true
	else
		return false
	end
end

-- Function to remove player money
function removePlayerMoney(thePlayer, theMoney)
	if (takePlayerMoney(thePlayer, tonumber(theMoney))) and (exports.server:getPlayerAccountID(thePlayer)) then
		exports.DENmysql:exec("UPDATE `accounts` SET `money`=? WHERE `id`=?", (tonumber(theMoney) + getPlayerMoney(thePlayer)), exports.server:getPlayerAccountID(thePlayer))
		return true
	else
		return false
	end
end

-- Event that changes the element model in the database
addEventHandler("onElementModelChange", root,
	function (oldModel, newModel)
		if (getElementType(source) == "player") and (exports.server:getPlayerAccountID(source)) and (getPlayerTeam(source)) then
			if (getTeamName(getPlayerTeam(source))  == "Criminals") or (getTeamName(getPlayerTeam(source))  == "Unemployed") or (getTeamName(getPlayerTeam(source))  == "Unoccupied") then
				exports.DENmysql:exec("UPDATE `accounts` SET `skin`=? WHERE `id`=?", newModel, exports.server:getPlayerAccountID(thePlayer))
			else
				exports.DENmysql:exec("UPDATE `accounts` SET `jobskin`=? WHERE `id`=?", newModel, exports.server:getPlayerAccountID(thePlayer))
			end
		end
	end
)

-- Function that get the correct weapon string of the player
function getPlayerWeaponString(plr)
	return weaponStringTable[plr]
end

-- Event that syncs the correct weapon string with the server
addEvent("syncPlayerWeaponString", true)
addEventHandler("syncPlayerWeaponString", root,
	function (theString, allow)
		if (allow) then
			if isPedDead(source) then
				local t = fromJSON(theString)
				if #t == 0 then return end
			end
			weaponStringTable[source] = theString
			exports.DENmysql:exec("UPDATE `accounts` SET `weapons`=? WHERE `id`=?", theString, exports.server:getPlayerAccountID(source))
		elseif isPedDead(source) then
			return
		else
			weaponStringTable[source] = theString
			exports.DENmysql:exec("UPDATE `accounts` SET `weapons`=? WHERE `id`=?", theString, exports.server:getPlayerAccountID(source))
		end
	end
)

addEventHandler("onPlayerLogin", root,
	function ()
		triggerClientEvent(source, "startSaveWep", source)
	end
)

-- Function that saves the important playerdata
function savePlayerData(plr)
	if (exports.server:getPlayerAccountID(plr)) and (getElementData(plr, "joinTick")) and (getTickCount() - getElementData(plr, "joinTick") > 5000) then
		
		if (isPedDead(plr)) then
			playerArmor = 0
		else
			playerArmor = getPedArmor(plr)
		end

		local playerMoney = getPlayerMoney(plr)
		local playerHealth = getElementHealth(plr) or 100
		local playerWP = getElementData(plr, "wantedPoints") or 0
		local pX, pY, pZ = getElementPosition(plr)
		local playerInterior = plr.interior or 0
		local playerDimension = plr.dimension or 0
		local playerRotation = getPedRotation(plr) or 0
		local playerOccupation = exports.server:getPlayerOccupation(plr) or "Unemployed"
		local playerTeam = plr.team.name or "Unemployed" -- We set them to the unemployed team to avoid it being set to 0, which becomes problematic
		local playerPlayTime = getElementData(plr, "playTime")
		local playerAccountID = exports.server:getPlayerAccountID(plr)

		exports.DENmysql:exec("UPDATE `accounts` SET `money`=?, `health`=?, `armor`=?, `wanted`=?, `x`=?, `y`=?, `z`=?, `interior`=?, `dimension`=?, `rotation`=?, `occupation`=?, `team`=?, `playtime`=? WHERE `id`=?",
			playerMoney,
			playerHealth,
			playerArmor,
			playerWP,
			pX,
			pY,
			pZ,
			playerInterior,
			playerDimension,
			playerRotation,
			playerOccupation,
			playerTeam,
			playerPlayTime,
			playerAccountID
		)
		return true
	end
	return false
end

-- Triggers that should save playerdata
function doSaveData()
	if (exports.server:isAllowedToSave(source) == true) then
		savePlayerData(source)
	end
end

function quit()
	savePlayerData(source)
	playerWeaponTable[source] = nil
	weaponStringTable[source] = nil
end
addEventHandler("onPlayerQuit", root, quit)
addEventHandler("onPlayerWasted", root, doSaveData)
addEventHandler("onPlayerLogout", root, doSaveData)

-- Ignore anything that tells you to upgade, as it will only break this function
function getPlayerSkin(plr)
	local t = exports.DENmysql:querySingle("SELECT `skin` FROM `accounts` WHERE `username`=?", exports.server:getPlayerAccountName(plr))
	return t[1].skin
end

--[[
setTimer(
	function ()
		for _, plr in pairs(Element.getAllByType("player")) do
			if (exports.server:isPlayerLoggedIn(v)) then
				local userID = exports.server:getPlayerAccountID(plr)
				db:query(recCB, {plr}, "SELECT * FROM `weapons` WHERE `userid`=?", userID)
				db:query(recCB, {plr}, "SELECT * FROM `accounts` WHERE `id`=?", userID)
				db:query(recCBwep, {plr}, "SELECT * FROM `accounts` WHERE `id`=?", userID)
			end
		end
	end, 1000, 1
)
--]]

function forceWeaponSync(p)
	triggerClientEvent(p, "forceWepSync", p)
end
