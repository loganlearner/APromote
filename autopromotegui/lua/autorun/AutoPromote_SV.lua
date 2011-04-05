------------------------------
// APromoteGUI by Lead4u    //
// Mail: J_G_24@hotmail.com //
// Steam: Lead4u2           //
// Version: 1.0 Beta        //
------------------------------
require( "glon" )
local glonGroup = {};
local set = {};
local grp = {};
glonGroup["set"] = set
glonGroup["grp"] = grp

local function loadAP()
	if (!file.Exists("autoPromote/data.txt")) then
		for k, v in pairs(ULib.ucl.groups) do
			glonGroup["grp"][k] = -1
		end
		glonGroup["set"]["ap_enabled"] = 1
		glonGroup["set"]["ap_snd_enabled"] = 1
		glonGroup["set"]["ap_snd_scope"] = 1
		file.Write("autoPromote/data.txt", glon.encode(glonGroup))
	else 
		glonGroup = glon.decode(file.Read( "autoPromote/data.txt" ))
	end
	ULib.replicatedWritableCvar("ap_enabled","rep_ap_enabled", glonGroup["set"]["ap_enabled"],false,false,"xgui_svsettings")
	ULib.replicatedWritableCvar("ap_snd_enabled","rep_ap_snd_enabled",glonGroup["set"]["ap_snd_enabled"] ,false,false,"xgui_svsettings")
	ULib.replicatedWritableCvar("ap_snd_scope","rep_ap_snd_scope",glonGroup["set"]["ap_snd_scope"] ,false,false,"xgui_svsettings")
end
hook.Add( "InitPostEntity", "loadAPGUI", loadAP )

function cVarChange( sv_cvar, cl_cvar, ply, old_val, new_val )
	if ( sv_cvar =="ap_enabled" or sv_cvar=="ap_snd_enabled" or sv_cvar=="ap_snd_scope" ) then
		glonGroup["set"][sv_cvar] = new_val
		file.Write("autoPromote/data.txt", glon.encode(glonGroup))
	end
end
hook.Add( "ULibReplicatedCvarChanged", "APGroupCVAR", cVarChange )

local function PlayRankSound( ply )
	if ( GetConVarNumber( "ap_snd_enabled" ) == 1) then
		if ( GetConVarNumber( "ap_snd_scope" ) == 1 ) then
			for k, v in pairs(player.GetAll()) do
				v:SendLua("surface.PlaySound( \"/garrysmod/save_load1.wav\" )")
			end
		elseif ( GetConVarNumber( "ap_snd_scope" ) == 0) then
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
	if (ply:IsSuperAdmin() and isValidCommand( args, glonGroup["grp"] )) then
		glonGroup["grp"][args[1]] = tonumber(args[2])
		ULib.clientRPC( nil, "doApUpdate", glonGroup["grp"])
		file.Write("autoPromote/data.txt", glon.encode(glonGroup))
	end
end)

local function doApUpdate()
	//for added groups
	timer.Create("ysoghetto",2,1,function()
		for k, v in pairs(ULib.ucl.groups) do
			if ( glonGroup["grp"][k] == nil and k != "user") then
				print("Added " .. k .. " to AutoPromote.")
				glonGroup["grp"][k] = -1
			end
		end
		for k, v in pairs(glonGroup["grp"]) do
			if ( k != nil and !ULib.ucl.groups[k]) or k == "user" then
				print("Removed " .. k .. " from AutoPromote.")
				glonGroup["grp"][k] = nil
			end
		end
		ULib.clientRPC( nil , "doApUpdate", glonGroup["grp"] )
	end)
end
 
hook.Add( "UCLChanged", "doApUpdateSV", doApUpdate )

local function checkPlayer( ply ) 
local plyhours = tonumber(math.floor((ply:GetUTime() + CurTime() - ply:GetUTimeStart())/60/60))
local Rank = ""
local Hours = 0

if(	ply:IsBot( ) or !ply:IsValid() ) then return end
	for k, v in pairs(glonGroup["grp"]) do 
		if ( plyhours >= tonumber(v) and tonumber(v) >= Hours) then
			if (tonumber(v) >= 0) then
				Rank = k
				Hours = tonumber(v)
			end
		end
	end
	if (!ply:IsUserGroup(Rank) and Rank != "") then
		if (tonumber(glonGroup["grp"][ply:GetNWString("usergroup")]) != -1) then
			RunConsoleCommand("ulx", "adduser" , ply:Nick() , Rank)
			PlayRankSound( ply );
			return;
		end
	end
end

timer.Create("doAPUpdateTimer",10,0, function()
if( GetConVarNumber( "ap_enabled" ) != 1) then return end
	for k, v in pairs(player.GetAll()) do
		ULib.queueFunctionCall(	checkPlayer, v) 
	end
end)
