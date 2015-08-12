-- Command start open the window
addCommandHandler( "resources",
	function ( thePlayer )
		account = exports.server:getPlayerAccountID(thePlayer)
		if (account) then
			data = exports.DENmysql:querySingle("SELECT * FROM developer WHERE userid=?",account)
			if (data) or ( exports.CSGstaff:isPlayerStaff( thePlayer ) ) and ( exports.CSGstaff:isPlayerDeveloper( thePlayer ) ) then
				local resourceTable = {}
				for k, i in ipairs( getResources() ) do
					resourceTable[k] = { getResourceName( i ), getResourceState ( i ) }
				end
				triggerClientEvent( thePlayer, "onOpenResourcesWindow", thePlayer, resourceTable )
			else
				return
			end
		end
	end
)

-- Resource event
addEvent ( "onUpdateResourceState", true )
addEventHandler ( "onUpdateResourceState", root,
	function ( theType, theResource, theRow )
		if ( getResourceFromName( theResource ) ) then
			if ( theType == "start" ) then
				if ( startResource ( getResourceFromName( theResource ),true ) ) then
					outputChatBox( "You started "..theResource, source, 0, 225, 0 )
					triggerClientEvent( source, "setResourceColor", source, theRow, 0, 225, 0 )
				elseif ( getResourceState ( getResourceFromName( theResource ) ) == "running" ) or ( getResourceState ( getResourceFromName( theResource ) ) == "starting" ) then
					outputChatBox( theResource.." is already running or starting!", source, 0, 225, 0 )
				else
					outputChatBox( theResource.." failed to start, reason: "..getResourceLoadFailureReason ( getResourceFromName( theResource ) ), source, 225, 0, 0 )
				end
			elseif ( theType == "restart" ) then
				if ( restartResource ( getResourceFromName( theResource ) ) ) then
					outputChatBox( "You restarted "..theResource, source, 0, 225, 0 )
				elseif ( getResourceState ( getResourceFromName( theResource ) ) == "starting" ) then
					outputChatBox( theResource.." is already starting!", source, 0, 225, 0 )
				else
					outputChatBox( theResource.. " failed to restart, reason: "..getResourceLoadFailureReason ( getResourceFromName( theResource ) ), source, 225, 0, 0 )
				end
			elseif ( theType == "stop" ) then
				if ( stopResource ( getResourceFromName( theResource ) ) ) then
					outputChatBox( "You stopped "..theResource, source, 0, 225, 0 )
					triggerClientEvent( source, "setResourceColor", source, theRow, 225, 0, 0 )
				elseif ( getResourceState ( getResourceFromName( theResource ) ) == "stopping" ) or ( getResourceState ( getResourceFromName( theResource ) ) == "loaded" ) then
					outputChatBox( theResource.." is already stopping or stopped!", source, 0, 225, 0 )
				else
					outputChatBox( theResource.. " failed to stop, reason: "..getResourceLoadFailureReason ( getResourceFromName( theResource ) ), source, 225, 0, 0 )
				end
			end
		end
	end
)

local resourcesBeingMoved = {}

addEvent ( "onMoveResource", true )
addEventHandler ( "onMoveResource", root,
	function ( theResourceName, newDir )
		--exports.dendxmsg:createNewDxMessage(source,"Feature disabled!",255,0,0)
		--return false
		local theResource = getResourceFromName( theResourceName )
		if ( theResource ) then
			if exports.csgstaff:getPlayerAdminLevel(source) >= 5 and exports.csgstaff:isPlayerDeveloper(source) then
				local resState = getResourceState(theResource)
				local resRunning = resState == 'running'
				if resRunning then 
					resourcesBeingMoved[theResource] = { name = theResourceName, newDir = newDir }
					stopResource(theResource) 
				else
					local newres = renameResource(theResourceName,theResourceName,newDir)
					refreshResources()
				end
				exports.dendxmsg:createNewDxMessage(source,"Resource moved!",0,255,0)
			else
				exports.dendxmsg:createNewDxMessage(source,"You have to be a L5 developer to move resources!",255,0,0)
			end		
		end
	end
)

addEventHandler('onResourceStop',root,
	function (stoppedRes)
		if resourcesBeingMoved[stoppedRes] then
			setTimer( 
				function (res)
					local newres = renameResource(res,resourcesBeingMoved[res].name,resourcesBeingMoved[res].newDir)
					refreshResources()
					setTimer(startResource,500,1,newres)
					resourcesBeingMoved[res] = false
				end, 250,1,stoppedRes)
		end
	end
)