﻿---------------------------------------------------------------------
-- Project: irc
-- Author: MCvarial
-- Contact: mcvarial@gmail.com
-- Version: 1.0.2
-- Date: 31.10.2012
---------------------------------------------------------------------

------------------------------------
-- IRC Commands
------------------------------------

addEvent("onIRCResourceStart")
addEventHandler("onIRCResourceStart",root,
	function ()
		function say (server,channel,user,command,...)
			local message = table.concat({...}," ")
			if message == "" then ircNotice(user,"syntax is !s <message>") return end
			outputChatBox("[IRC] "..ircGetUserNick(user)..": "..message,root,255,168,0)
			outputIRC("[IRC] "..ircGetUserNick(user)..": "..message)
		end
		addIRCCommandHandler("!say",say)
		addIRCCommandHandler("!s",say)
		addIRCCommandHandler("!m",say)

		addIRCCommandHandler("!pm",
			function (server,channel,user,command,name,...)
				local message = table.concat({...}," ")
				if not name then ircNotice(user,"syntax is !pm <name> <message>") return end
				if message == "" then ircNotice(user,"syntax is !pm <name> <message>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					outputChatBox("[IRC] PM from "..ircGetUserNick(user)..": "..message,player,255,168,0)
					ircNotice(user,"Your pm has been send to "..getPlayerName(player))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)
		
		addIRCCommandHandler("!ts",
			function (server,channel,user,command,name,...)
				local message = table.concat({...}," ")
				if not name then ircNotice(user,"syntax is !ts <name> <message>") return end
				if message == "" then ircNotice(user,"syntax is !ts <name> <message>") return end
				local team = getTeamFromPartialName(name)
				if team then
					for i,player in ipairs (getPlayersInTeam(team)) do
						outputChatBox("[IRC] Team message from "..ircGetUserNick(user)..": "..message,player,255,168,0)
					end
					ircNotice(user,"Your team message has been send to "..getTeamName(team))
				else
					ircNotice(user,"'"..name.."' no such team")
				end
			end
		)

		addIRCCommandHandler("!kick",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !kick <name> <reason>") return end
				local reason = table.concat({...}," ") or ""
				local player = getPlayerFromPartialName(name)
				if player then
					local nick = getPlayerName(player)
					kickPlayer(player,reason)
					outputChatBox("[IRC] "..nick.." was kicked from the game by "..ircGetUserNick(user).." ("..reason..")",root,255,100,100)
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!ban",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !ban <name> [reason] (time)") return end
				local reason = table.concat({...}," ") or ""
				local player = getPlayerFromPartialName(name)
				if player then
					addBan(getPlayerIP(player),nil,getPlayerSerial(player),ircGetUserNick(user),reason,getTimeFromString(reason)/1000)
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!mute",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !mute <name> [reason] [time]") return end
				local reason = table.concat({...}," ")
				local player = getPlayerFromPartialName(name)
				if player then
					setPlayerMuted(player,true,reason,ircGetUserNick(user))
					if reason then
						outputChatBox("[IRC] "..getPlayerName(player).." has been muted by "..ircGetUserNick(user).." ("..reason..")",root,255,0,0)
					else
						outputChatBox("[IRC] "..getPlayerName(player).." has been muted by "..ircGetUserNick(user),root,255,0,0)
					end
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)
		
		addIRCCommandHandler("!mutes",
			function (server,channel,user,command)
				local results = executeSQLSelect("ircmutes","player,admin,reason,duration")
				if type(results) == "table" then
					if #results == 0 then
						outputIRC("12* There are no muted players")
					else
						for i,result in ipairs (results) do
							outputIRC("12* "..tostring(result.player).." by "..tostring(result.admin).." for: "..tostring(result.reason).." during: "..tostring(getTimeString(result.duration)))
						end
					end
				else
					outputIRC("12* No mutes")
				end
			end
		)
			
		addIRCCommandHandler("!kill",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !kill <name> [reason]") return end
				local reason = table.concat({...}," ") or ""
				local player = getPlayerFromPartialName(name)
				if player then
					killPed(player)
					outputChatBox("[IRC] "..getPlayerName(player).." was killed by "..ircGetUserNick(user).." ("..reason..")",root,255,0,0)
					ircSay(channel,"12* "..getPlayerName(player).." was killed by "..ircGetUserNick(user).." ("..reason..")")
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!unmute",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !unmute <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					setPlayerMuted(player,false)
					outputChatBox("[IRC] "..getPlayerName(player).." was unmuted by "..ircGetUserNick(user),root,255,0,0)
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!freeze",
			function (server,channel,user,command,name,...)
				if not name then ircNotice(user,"syntax is !freeze <name> [reason]") return end
				local reason = table.concat({...}," ")
				local t = split(reason,40)
				local time
				if #t > 1 then
					time = "("..t[#t]
				end
				local player = getPlayerFromPartialName(name)
				if player then
					if isPedInVehicle(player) then
						setElementFrozen(getPedOccupiedVehicle(player),true)
						setTimer(setElementFrozen,time,1,getPedOccupiedVehicle(player),false)
					end
					setElementFrozen(player,true)
					setTimer(setElementFrozen,time,1,player,false)
					outputChatBox("[IRC] "..getPlayerName(player).." was frozen by "..ircGetUserNick(user).." ("..reason..")",root,255,0,0)
					ircSay(channel,"12* "..getPlayerName(player).." was frozen by "..ircGetUserNick(user).." ("..reason..")")
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!unfreeze",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !unfreeze <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					if isPedInVehicle(player) then
						setElementFrozen(getPedOccupiedVehicle(player),false)
					end
					setElementFrozen(player,false)
					outputChatBox("[IRC] "..getPlayerName(player).." was unfrozen by "..ircGetUserNick(user),root,255,0,0)
					ircSay(channel,"12* "..getPlayerName(player).." was unfrozen by "..ircGetUserNick(user))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!slap",
			function (server,channel,user,command,name,hp,...)
				if not name then ircNotice(user,"syntax is !slap <name> <hp> (<reason>)") return end
				if not hp then ircNotice(user,"syntax is !slap <name> <hp> (<reason>)") return end
				local reason = table.concat({...}," ") or ""
				local player = getPlayerFromPartialName(name)
				if player then
					setElementVelocity((getPedOccupiedVehicle(player) or player),0,0,hp*0.01)
					setElementHealth((getPedOccupiedVehicle(player) or player),(getElementHealth((getPedOccupiedVehicle(player) or player)) - hp))
					outputChatBox("[IRC] "..getPlayerName(player).." was slapped by "..ircGetUserNick(user).." ("..reason..")("..hp.."HP)",root,255,0,0)
					ircSay(channel,"12* "..getPlayerName(player).." was slapped by "..ircGetUserNick(user).." ("..reason..")("..hp.."HP)")
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!getip",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !getip <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					ircNotice(user,getPlayerName(player).."'s IP: "..getPlayerIP(player))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!getserial",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !getserial <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					ircNotice(user,getPlayerName(player).."'s Serial: "..getPlayerSerial(player))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!unbanserial",
			function (server,channel,user,command,serial)
				if not serial then ircNotice(user,"syntax is !unban <serial>") return end
				for i,ban in ipairs (getBans()) do
					if getBanNick(ban) == name then
						removeBan(ban)
					end
				end
			end
		)
		
		addIRCCommandHandler("!unbanaccount",
			function (server,channel,user,command,account)
				if not name then ircNotice(user,"syntax is !unban <account>") return end
				for i,ban in ipairs (getBans()) do
					if getBanNick(ban) == name then
						removeBan(ban)
					end
				end
			end
		)

		addIRCCommandHandler("!banserial",
			function (server,channel,user,command,serial,...)
				if not ip then ircNotice(user,"syntax is !ban <serial> (<reason>)") return end
				local reason = table.concat({...}," ") or ""
				addBan(ip,nil,nil,ircGetUserNick(user),reason,getTimeFromString(reason)/1000)
			end
		)
		
		addIRCCommandHandler("!banaccount",
			function (server,channel,user,command,account,...)
				if not ip then ircNotice(user,"syntax is !ban <account> (<reason>)") return end
				local reason = table.concat({...}," ") or ""
				addBan(ip,nil,nil,ircGetUserNick(user),reason,getTimeFromString(reason)/1000)
			end
		)

		addIRCCommandHandler("!bans",
			function (server,channel)
				ircSay(channel,"There are "..#getBans().." bans on the server!")
			end
		)

		addIRCCommandHandler("!uptime",
			function (server,channel,user,command,...)
				ircNotice(user,"Hi "..ircGetUserNick(user)..", my uptime is: "..getTimeString(getTickCount()))
			end
		)

		addIRCCommandHandler("!players",
			function (server,channel)
				if getPlayerCount() == 0 then
					ircSay(channel,"There are no players ingame")
				else
					local players = getElementsByType("player")
					for i,player in ipairs (players) do
						players[i] = getPlayerName(player)
					end
					ircSay(channel,"There are "..getPlayerCount().." players ingame!")
				end
			end
		)

		addIRCCommandHandler("!run",
			function (server,channel,user,command,...)
				local str = table.concat({...}," ")
				if str == "" then ircNotice(user,"syntax is !run <string>") return end
				runString(str,root,ircGetUserNick(user))
			end
		)

		addIRCCommandHandler("!crun",
			function (server,channel,user,command,...)
				local t = {...}
				local str = table.concat(t," ")
				if str == "" then ircNotice(user,"syntax is !crun (<name>) <string>") return end
				local player = getPlayerFromPartialName(tostring(t[1]))
				if player then
					table.remove(t,1)
					str = table.concat(t," ")
					triggerClientEvent(player,"doCrun",resourceRoot,str,true)
				else
					if #getElementsByType("player") == 0 then
						ircNotice(user,"No player ingame!")
						return
					end
					for i,player in ipairs (getElementsByType("player")) do
						if i == 1 then
							triggerClientEvent(player,"doCrun",resourceRoot,str,true)
						else
							triggerClientEvent(player,"doCrun",resourceRoot,str,false)
						end
					end
				end
			end
		)

		addIRCCommandHandler("!resources",
			function (server,channel,user,command)
				local resources = getResources()
				for i,resource in ipairs (resources) do
					if getResourceState(resource) == "running" then
						resources[i] = "03"..getResourceName(resource).."01"
					elseif getResourceState(resource) == "failed to load" then
						resources[i] = "04"..getResourceName(resource).." ("..getResourceLoadFailureReason(resource)..")01"
					else
						resources[i] = "07"..getResourceName(resource).."01"
					end
				end
				ircSay(user,"07Resources: "..table.concat(resources,", "))
			end
		)

		addIRCCommandHandler("!state",
			function (server,channel,user,command,resName)
				if not resName then ircNotice(user,"syntax is !state <resourcename>") return end
				local resource = getResourceFromPartialName(resName)
				if resource then
					local realResName = getResourceName(resource)
					local state = getResourceState(resource)
					if state then
						ircNotice(user,"Resource "..realResName.."'s state is: "..state)
					else
						ircNotice(user,"Retrieving resource "..realResName.."'s state went wrong!")
					end
				else
					ircNotice(user,"Resource '"..resName.."' not found!")
				end
			end
		)
		
		addIRCCommandHandler("!start",
			function (server,channel,user,command,resName)
				if not resName then ircNotice(user,"syntax is !start <resourcename>") return end
				local resource = getResourceFromPartialName(resName)
				if resource then
					if not startResource(resource) then
						ircNotice(user,"Failed to start '"..getResourceName(resource).."'")
					end
				else
					ircNotice(user,"Resource '"..resName.."' not found!")
				end
			end
		)

		addIRCCommandHandler("!restart",
			function (server,channel,user,command,resName)
				if not resName then ircNotice(user,"syntax is !restart <resourcename>") return end
				local resource = getResourceFromPartialName(resName)
				if resource then
					if not restartResource(resource) then
						ircNotice(user,"Failed to restart '"..getResourceName(resource).."'")
					end
				else
					ircNotice(user,"Resource '"..resName.."' not found!")
				end
			end
		)

		addIRCCommandHandler("!stop",
			function (server,channel,user,command,resName)
				if not resName then ircNotice(user,"syntax is !stop <resourcename>") return end
				local resource = getResourceFromPartialName(resName)
				if resource then
					if not stopResource(resource) then
						ircNotice(user,"Failed to stop '"..getResourceName(resource).."'")
					end
				else
					ircNotice(user,"Resource '"..resName.."' not found!")
				end
			end
		)
		function outputCommands (server,channel,user,command)
			local cmds = {}
			for i,cmd in ipairs (ircGetCommands()) do
				if ircIsCommandEchoChannelOnly(cmd) then
					if ircIsEchoChannel(channel) then
						if (tonumber(ircGetCommandLevel(cmd) or 6)) <= (tonumber(ircGetUserLevel(user,channel)) or 0) then
							table.insert(cmds,cmd)
						end
					end
				else
					if ircGetCommandLevel(cmd) <= ircGetUserLevel(user,channel) then
						table.insert(cmds,cmd)
					end
				end
			end
			ircNotice(user,ircGetUserNick(user)..", you can use these commands: "..table.concat(cmds,", "))
		end
		addIRCCommandHandler("!commands",outputCommands)
		addIRCCommandHandler("!cmds",outputCommands)

		addIRCCommandHandler("!account",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !account <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local account = exports.server:getPlayerAccountName(player) or getAccountName(getPlayerAccount(player)) or "Guest Account/Not logged in"
					ircNotice(user,getPlayerName(player).."'s account name: "..account)
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!money",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !money <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					ircNotice(user,getPlayerName(player).."'s money: "..tostring(getPlayerMoney(player)))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!health",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !health <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					ircNotice(user,getPlayerName(player).."'s health: "..math.floor(tostring(getElementHealth(player))))
				else
					ircNotice(user,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!wantedlevel",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !wantedlevel <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					outputIRC(getPlayerName(player).."'s wanted level: "..tostring(getPlayerWantedLevel(player)))
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!team",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !team <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local team = getPlayerTeam(player)
					if team then
						outputIRC(getPlayerName(player).."'s team: "..getTeamName(team))
					else
						outputIRC(getPlayerName(player).." is in no team")
					end
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!ping",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !ping <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					outputIRC(getPlayerName(player).."'s ping: "..getPlayerPing(player))
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)

		--[[addIRCCommandHandler("!changemap",
			function (server,channel,user,command,...)
				local map = table.concat({...}," ")
				if not map then ircNotice(user,"syntax is !changemap <name>") return end
				local maps = {}
				for i,resource in ipairs (getResources()) do
					if getResourceInfo(resource,"type") == "map" then
						if string.find(string.lower(getResourceName(resource)),string.lower(map)) then
							table.insert(maps,resource)
						elseif string.find(string.lower(getResourceInfo(resource,"name")),string.lower(map)) then
							table.insert(maps,resource)
						end
					end
				end
				if #maps == 0 then
					ircNotice(user,"No maps found!")
				elseif #maps == 1 then
					exports.mapmanager:changeGamemodeMap(maps[1])
				else
					for i,resource in ipairs (maps) do
						maps[i] = getResourceName(resource)
					end
					ircNotice(user,"Found "..#maps.." matches: "..table.concat(maps,", "))
				end
			end
		)

		addIRCCommandHandler("!map",
			function (server,channel,user,command,...)
				ircSay(channel,"12* Current Map: 01"..tostring(getMapName()))
			end
		)
		--]]
		addIRCCommandHandler("!modules",
			function (server,channel,user,command)
				ircSay(user,"07Loaded modules: "..table.concat(getLoadedModules(),", "))
			end
		)
		
		addIRCCommandHandler("!shutdown",
			function (server,channel,user,command,...)
				local reason = table.concat({...}," ")
				if not reason then reason = "Shutdown from irc" end
				shutdown(reason)
			end
		)

		addIRCCommandHandler("!password",
			function (server,channel,user,command,...)
				local newpass = table.concat({...}," ")
				if newpass ~= "" then
					if setServerPassword(newpass) then
						ircNotice(user,"New server pass: "..tostring(getServerPassword()))
					end
				else
					ircNotice(user,"Current server pass: "..tostring(getServerPassword()).." use !password <newpass> to change it")
				end
			end
		)

		addIRCCommandHandler("!gravity",
			function (server,channel,user,command,...)
				local newgravity = table.concat({...}," ")
				if tonumber(newgravity) then
					if setGravity(tonumber(newgravity)) then
						ircNotice(user,"New gravity: "..tostring(getGravity()))
					end
				else
					ircNotice(user,"Current gravity: "..tostring(getWeather()).." use !gravity <new gravity> to change it")
				end
			end
		)

		addIRCCommandHandler("!weather",
			function (server,channel,user,command,...)
				local newweather = table.concat({...}," ")
				if newweather then
					if setWeather(tonumber(newweather)) then
						ircNotice(user,"New weather: "..tostring(getWeather()))
					end
				else
					ircNotice(user,"Current weather: "..tostring(getWeather()).." use !weather <new weather> to change it")
				end
			end
		)

		addIRCCommandHandler("!server",
			function (server,channel,user,command,...)
				if localIP then
					ircSay(channel,"Server: "..tostring(getServerName()).." IP: "..tostring(localIP).." Port: "..tostring(getServerPort()))
				else
					ircSay(channel,"Server: "..tostring(getServerName()).." Port: "..tostring(getServerPort()))
				end
			end
		)

		addIRCCommandHandler("!zone",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !zone <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local x,y,z = getElementPosition(player)
					if not x then return end
					local zone = getZoneName(x,y,z,false)
					local city = getZoneName(x,y,z,true)
					ircSay(channel,tostring(getPlayerName(player)).."'s zone: "..tostring(zone).." ("..tostring(city)..")")
				else
					ircSay(channel,"'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!refreshall",
			function (server,channel,user,command,name)
				if refreshResources then
					if refreshResources(true) then
						ircSay(channel,"Refreshing all resources...")
					end
				else
					ircSay(channel,"!refreshall only available from 1.1 onwards")
				end
			end
		)

		addIRCCommandHandler("!refresh",
			function (server,channel,user,command,name)
				if refreshResources then
					if refreshResources(false) then
						ircSay(channel,"Refreshing new resources...")
					end
				else
					ircSay(channel,"!refresh only available from 1.1 onwards")
				end
			end
		)
		
		addIRCCommandHandler("!sup",
			function (server,channel,user,command,...)
				local message = table.concat({...}," ")
				if message == "" then ircNotice(user,"syntax is !sup <message>") return end
				
				local ircName = ircGetUserNick(user)
				triggerEvent ( "OnEchoSupportChat", root, ircName, message )
				outputIRC("(SUPPORT)[IRC] "..ircName..": "..message)
			end
		)
		
		addIRCCommandHandler("!occupation",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !occupation <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local occupation = getElementData( player, "Occupation" )
					local rank = getElementData( player, "Rank" )
					local message = table.concat({occupation,rank}," - ")
					if occupation or rank then
						outputIRC(getPlayerName(player).."'s occupation info: "..message)
					else
						outputIRC(getPlayerName(player).." has no occupation.")
					end
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)		
		
		addIRCCommandHandler("!group",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !group <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local group = getElementData( player, "Group" )
					if group then
						outputIRC(getPlayerName(player).."'s group: "..group)
					else
						outputIRC(getPlayerName(player).." has no group.")
					end
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)			
		
		addIRCCommandHandler("!score",
			function (server,channel,user,command,name)
				if not name then ircNotice(user,"syntax is !score <name>") return end
				local player = getPlayerFromPartialName(name)
				if player then
					local score = getElementData( player, "playerScore" )
					if score then
						outputIRC(getPlayerName(player).."'s score: "..score)
					else
						outputIRC(getPlayerName(player).." has no score?")
					end
				else
					outputIRC("'"..name.."' no such player")
				end
			end
		)

		addIRCCommandHandler("!staff",
			function (server,channel,user,command,name)
				local admins = {}
				if getResourceState(getResourceFromName("CSGstaff")) == "running" then
					admins = exports.CSGstaff:getOnlineAdmins() or {}
				end
				if #admins > 0 then
					ircSay(channel,"Online staff: "..table.concat(admins,", "))
				else
					ircSay(channel,"No staff current online!")
				end
			end
		)
		
	end
)