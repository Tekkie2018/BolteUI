--Neuron , a World of Warcraft® user interface addon.


local NEURON = Neuron
local CDB

NEURON.NeuronExitBar = NEURON:NewModule("ExitBar", "AceEvent-3.0", "AceHook-3.0")
local NeuronExitBar = NEURON.NeuronExitBar


local EXITBTN = setmetatable({}, { __index = CreateFrame("CheckButton") })

local exitbarsCDB
local exitbtnsCDB

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local gDef = {
	snapTo = false,
	snapToFrame = false,
	snapToPoint = false,
	point = "BOTTOM",
	x = 0,
	y = 305,
}

local configData = {
	stored = false,
}

local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = true,
}


-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronExitBar:OnInitialize()

	CDB = NeuronCDB

	exitbarsCDB = CDB.exitbars
	exitbtnsCDB = CDB.exitbtns

	----------------------------------------------------------------
	EXITBTN.SetData = NeuronExitBar.SetData
	EXITBTN.LoadData = NeuronExitBar.LoadData
	EXITBTN.SaveData = NeuronExitBar.SaveData
	EXITBTN.SetAux = NeuronExitBar.SetAux
	EXITBTN.LoadAux = NeuronExitBar.LoadAux
	EXITBTN.SetObjectVisibility = NeuronExitBar.SetObjectVisibility
	EXITBTN.SetDefaults = NeuronExitBar.SetDefaults
	EXITBTN.GetDefaults = NeuronExitBar.GetDefaults
	EXITBTN.SetType = NeuronExitBar.SetType
	EXITBTN.GetSkinned = NeuronExitBar.GetSkinned
	EXITBTN.SetSkinned = NeuronExitBar.SetSkinned
	----------------------------------------------------------------

	NEURON:RegisterBarClass("exitbar", "VehicleExitBar", L["Vehicle Exit Bar"], "Vehicle Exit Button", exitbarsCDB, exitbarsCDB, NeuronExitBar, exitbtnsCDB, "CheckButton", "NeuronActionButtonTemplate", { __index = EXITBTN }, 1, gDef, nil, false)

	NEURON:RegisterGUIOptions("exitbar", { AUTOHIDE = true,
		SHOWGRID = false,
		SNAPTO = true,
		UPCLICKS = true,
		DOWNCLICKS = true,
		HIDDEN = true,
		LOCKBAR = true,
		TOOLTIPS = true,
		BINDTEXT = true,
		RANGEIND = true,
		CDTEXT = true,
		CDALPHA = true }, false, 65)

	if (CDB.exitbarFirstRun) then

		local bar = NEURON.NeuronBar:CreateNewBar("exitbar", 1, true)
		local object = NEURON.NeuronButton:CreateNewObject("exitbar", 1)

		NEURON.NeuronBar:AddObjectToList(bar, object)

		CDB.exitbarFirstRun = false

	else

		for id,data in pairs(exitbarsCDB) do
			if (data ~= nil) then
				NEURON.NeuronBar:CreateNewBar("exitbar", id)
			end
		end

		for id,data in pairs(exitbtnsCDB) do
			if (data ~= nil) then
				NEURON.NeuronButton:CreateNewObject("exitbar", id)
			end
		end
	end

end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronExitBar:OnEnable()

	NeuronExitBar:DisableDefault()

end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronExitBar:OnDisable()

end


------------------------------------------------------------------------------


-------------------------------------------------------------------------------

function NeuronExitBar:DisableDefault()

	local disableExitButton = false

	for i,v in ipairs(NEURON.NeuronExitBar) do

		if (v["bar"]) then --only disable if a specific button has an associated bar
			disableExitButton = true
		end
	end


	if disableExitButton then
		------Hiding the default blizzard
		MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
		MainMenuBarVehicleLeaveButton:SetPoint("BOTTOM", 0, -250)
	end

end


function NeuronExitBar:GetSkinned(button)
	--empty
end

function NeuronExitBar:SetSkinned(button)

	if (SKIN) then

		local bar = button.bar

		if (bar) then

			local btnData = {
				Icon = button.icontexture,
				Normal = button.normaltexture,

			}

			SKIN:Group("Neuron", bar.gdata.name):AddButton(button, btnData)

		end

	end
end

function NeuronExitBar:SaveData(button)

	-- empty

end

function NeuronExitBar:LoadData(button, spec, state)

	local id = button.id

	button.CDB = exitbtnsCDB

	if (button.CDB) then

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].config) then
			button.CDB[id].config = CopyTable(configData)
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id]) then
			button.CDB[id] = {}
		end

		if (not button.CDB[id].keys) then
			button.CDB[id].keys = CopyTable(keyData)
		end

		if (not button.CDB[id].data) then
			button.CDB[id].data = {}
		end

		NEURON:UpdateData(button.CDB[id].config, configData)
		NEURON:UpdateData(button.CDB[id].keys, keyData)

		button.config = button.CDB [id].config

		if (CDB.perCharBinds) then
			button.keys = button.CDB[id].keys
		else
			button.keys = button.CDB[id].keys
		end

		button.data = button.CDB[id].data
	end
end

function NeuronExitBar:SetObjectVisibility(button, show)

	if CanExitVehicle() or show then --set alpha instead of :Show or :Hide, to avoid taint and to allow the button to appear in combat

		button:SetAlpha(1)
		NeuronExitBar:SetExitButtonIcon(button)

	elseif not NEURON.ButtonEditMode and not NEURON.BarEditMode and not NEURON.BindingMode then
		button:SetAlpha(0)
	end

end

function NeuronExitBar:SetAux(button)

	-- empty

end


function NeuronExitBar:LoadAux(button)

	-- empty

end

function NeuronExitBar:SetDefaults(button)

	-- empty

end

function NeuronExitBar:GetDefaults(button)

	--empty

end

function NeuronExitBar:SetData(button, bar)
	NEURON.NeuronButton:SetData(button, bar)
end


function NeuronExitBar:SetExitButtonIcon(button)

	local texture

	if UnitOnTaxi("player") then
		texture = NEURON.SpecialActions.taxi
	else
		texture = NEURON.SpecialActions.vehicle
	end

	button.iconframeicon:SetTexture(texture)
end

function NeuronExitBar:SetType(button, save)

	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	button:RegisterEvent("UPDATE_POSSESS_BAR");
	button:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
	button:RegisterEvent("UNIT_ENTERED_VEHICLE")
	button:RegisterEvent("UNIT_EXITED_VEHICLE")
	button:RegisterEvent("VEHICLE_UPDATE")

	button:SetScript("OnEvent", function(self, event, ...) NeuronExitBar:OnEvent(self, event, ...) end)
	button:SetScript("OnClick", function(self) NeuronExitBar:OnClick(self) end)
	button:SetScript("OnEnter", function(self) NeuronExitBar:OnEnter(self) end)
	button:SetScript("OnLeave", GameTooltip_Hide)

	local objects = NEURON:GetParentKeys(button)

	for k,v in pairs(objects) do
		local name = (v):gsub(button:GetName(), "")
		button[name:lower()] = _G[v]
	end

	NeuronExitBar:SetExitButtonIcon(button)

	button:SetFrameLevel(4)
	button.iconframe:SetFrameLevel(2)
	button.iconframecooldown:SetFrameLevel(3)

	button:SetSkinned(button)

	NeuronExitBar:SetObjectVisibility(button)
end


function NeuronExitBar:OnEvent(button, event, ...)

	NeuronExitBar:SetObjectVisibility(button)

end


function NeuronExitBar:OnEnter(button)
	if ( UnitOnTaxi("player") ) then

		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:ClearLines()
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

function NeuronExitBar:OnClick(button)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();
	else
		VehicleExit();
	end
end
