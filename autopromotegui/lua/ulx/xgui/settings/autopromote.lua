------------------------------
// APromoteGUI by Lead4u    //
// Mail: J_G_24@hotmail.com //
// Steam: Lead4u2           //
// Version: 1.0 Beta        //
------------------------------

local panel = xlib.makepanel{ parent=xgui.null }
// AP Settings
local enabled = xlib.makecheckbox{ x=10, y=10, label="Enable", repconvar="rep_ap_enabled", parent=panel, textcolor=color_black }
xlib.makecheckbox{ x=10, y=30, label="Play Sound", repconvar="rep_ap_snd_enabled", parent=panel, textcolor=color_black }
xlib.makecheckbox{ x=25, y=50, label="Global Sound", repconvar="rep_ap_snd_scope", parent=panel, textcolor=color_black }
--xlib.makecheckbox{ x=10, y=70, label="Allow Auto Demote", repconvar="ff", parent=panel, textcolor=color_black }

// AP Group / Hour Setup
local pinfo = xlib.makepanellist{ x=300, y=5, w=285, h=327, parent=panel }	
local box = xlib.maketextbox{ x = 400, y=40, w=150, h = 20, parent=panel}
xlib.makelabel{ x = 333, y = 41, label = "Group Name: ", textcolor= color_white, parent=panel}
local btn = xlib.makebutton {w=100, h=25, x = 400, y = 300, label="Apply Changes", disabled=false, parent=panel}
local num = xlib.makeslider{ parent=panel, label="Hour which to promote to this rank", x = 315, y = 75, decimal = 0, min= -1, max = 500, value= -1, w = 250, h = 20, textcolor= color_white}
local dlist = xlib.makelistview{ x=145, y=5, w=150, h=327, parent=panel }
xlib.makelabel{ x = 310, y = 160, w=250, h=30, wordwrap = true, label = "NOTE: To exclude a rank from auto promotion set its value to -1. ", textcolor= color_white, parent=panel}

	dlist:AddColumn( "Group" )
	dlist:AddColumn( "Hours" )
dlist.Columns[1].DoClick = function() end
dlist.Columns[2].DoClick = function() end
box:SetEditable( false )
pinfo:AddItem( xlib.makelabel{ label="Hourly Settings", textcolor= color_white } )
	
dlist.OnRowSelected = function( self, LineID, Line )
	box:SetValue(Line:GetValue(1))
	
	if(Line:GetValue(2) == "(Excluded)") then
		num:SetValue(-1)
	else
		num:SetValue(Line:GetValue(2))
	end
end

btn.DoClick = function() 
	if (box:GetValue() and num:GetValue()) then	
		RunConsoleCommand("APGroup", box:GetValue(), num:GetValue())
	end
end
		
function doApUpdate( tab )
	dlist:Clear()	
		for k, v in pairs(tab) do
			if( tonumber(v) != -1) then
				dlist:AddLine( k, tonumber(v) )
			end
		end
			dlist:SortByColumn( 2, true )
		for k, v in pairs(tab) do
			if (tonumber(v) <= -1) then
				dlist:AddLine( k, "(Excluded)" )
			end
		end
end	

table.insert( xgui.modules.setting, { name="AutoPromote", panel=panel, icon="gui/silkicons/page_white_wrench", tooltip=nil, access="xgui_svsettings" } )

