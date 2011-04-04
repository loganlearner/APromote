------------------------------
// APromoteGUI by Lead4u    //
// Mail: J_G_24@hotmail.com //
// Steam: Lead4u2           //
// Version: 1.0 Beta        //
------------------------------
require( "glon" )
local glonGroup = {};

local function loadAP()
	if (!file.Exists("autoPromote/data.txt")) then
		for k, v in pairs(ULib.ucl.groups) do
			glonGroup[k] = -1
		end
		file.Write("autoPromote/data.txt", glon.encode(glonGroup))
	else 
		glonGroup = glon.decode(file.Read( "autoPromote/data.txt" ))
	end
	ULib.replicatedWritableCvar("ap_enabled","rep_ap_enabled",GetConVarNumber( "ap_enabled" ),false,true,"xgui_svsettings")
	ULib.replicatedWritableCvar("ap_voice_enabled","rep_ap_voice_enabled",GetConVarNumber( "ap_voice_enabled" ),false,true,"xgui_svsettings")
	ULib.replicatedWritableCvar("ap_voice_scope","rep_ap_voice_scope",GetConVarNumber( "ap_voice_scope" ),false,true,"xgui_svsettings")
end
hook.Add( "InitPostEntity", "loadAPGUI", loadAP )

local function PlayRankSound( ply )
	if ( GetConVarNumber( "ap_voice_enabled" ) == 1) then
		if ( GetConVarNumber( "ap_voice_scope" ) == 1 ) then
			for k, v in pairs(player.GetAll()) do
				v:SendLua("surface.PlaySound( \"/garrysmod/save_load1.wav\" )")
			end
		elseif ( GetConVarNumber( "ap_voice_scope" ) == 0) then
			ply:SendLua("surface.PlaySound( \"/garrysmod/save_load1.wav\" )")
		end
	end
end
	
local function isValidCommand( command, compare )
	for k, v in pairs( compare ) do
		if ( command[1] == k ) then
			if ( type( command[2] == "number")) then
				return true;
			end
		end
	end	
	return false;
end

concommand.Add("APGroup", function( ply, cmd, args )
	if (ply:IsSuperAdmin() and isValidCommand( args, glonGroup )) then
		glonGroup[args[1]] = tonumber(args[2])
		ULib.clientRPC( nil, "doApUpdate", glonGroup )
		file.Write("autoPromote/data.txt", glon.encode(glonGroup))
	end
end)

local function doApUpdate()
	//for added groups
	timer.Create("ysoghetto",2,1,function()
		for k, v in pairs(ULib.ucl.groups) do
			if ( glonGroup[k] == nil and k != "user") then
				print("Added " .. k .. " to AutoPromote.")
				glonGroup[k] = -1
			end
		end
		for k, v in pairs(glonGroup) do
			if ( k != nil and !ULib.ucl.groups[k]) or k == "user" then
				print("Removed " .. k .. " from AutoPromote.")
				glonGroup[k] = nil
			end
		end
		ULib.clientRPC( nil , "doApUpdate", glonGroup )
	end)
end
 
hook.Add( "UCLChanged", "doApUpdateSV", doApUpdate )

local function checkPlayer( ply ) 
local plyhours = tonumber(math.floor((ply:GetUTime() + CurTime() - ply:GetUTimeStart())/60/60))
local Rank = ""
local Hours = 0

if(	ply:IsBot( ) or !ply:IsValid() ) then return end
	for k, v in pairs(glonGroup) do 
		if ( plyhours >= tonumber(v) and tonumber(v) >= Hours) then
			if (tonumber(v) >= 0) then
				Rank = k
				Hours = tonumber(v)
			end
		end
	end
	if (!ply:IsUserGroup(Rank) and Rank != "") then
		if (tonumber(glonGroup[ply:GetNWString("usergroup")]) != -1) then
			RunConsoleCommand("ulx", "adduser" , ply:Nick() , Rank)
			PlayRankSound( ply );
			return;
		end
	else
		print( ply:Nick().." is already at the correct ".. tostring(Rank))
	end
end

timer.Create("doAPUpdateTimer",10,0, function()
if( GetConVarNumber( "ap_enabled" ) != 1) then print("no") return end
	for k, v in pairs(player.GetAll()) do
		ULib.queueFunctionCall(	checkPlayer, v) 
	end
end)
