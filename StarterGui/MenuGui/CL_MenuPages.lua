local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Gui = script.Parent

local MainBG = Gui["BG#C_T"]
local ConsoleScroll = MainBG["BG_ConsoleScroll#C_F"]
local MapLoadScroll = MainBG["BG_MapLoadScroll#C_F"]
local PreferenceScroll = MainBG["BG_PreferencesScroll#C_F"]
local WelcomePage = MainBG["BG_Welcome#C_F"]
local SideBar = MainBG._SideBar

local Pages = {
	{1, "Preferences", PreferenceScroll}, 
	{2, "Console", ConsoleScroll},
	{3, "MapLoad", MapLoadScroll},
	{4, "Welcome", WelcomePage}
}
local NewPage = nil
local OldPage = Pages[4]

local Dur, Dir, Style = 0.5, "Out", "Back"
local ClickDebounce = false

function UpdPage(Index)
	NewPage = Pages[Index]
	NewPage[3]:TweenPosition(UDim2.new(0, 0, 0, 0), Dir, Style, Dur, true, nil)
	if OldPage then
		if OldPage[3] ~= NewPage[3] then
			OldPage[3]:TweenPosition(UDim2.new(0, 0, 1, 0), Dir, Style, Dur, true, function()
				for _, Page in ipairs(Pages) do
					if Page[3] ~= NewPage[3] then
						Page[3].Position = UDim2.new(0, 0, -1, 0)
					end
				end
				ClickDebounce = false
			end)
		else
			ClickDebounce = false
		end
	end
	OldPage = NewPage
end

PreferenceScroll.OriginalName.Text = "@" .. Player.Name
PreferenceScroll.DisplayName.Text = Player.DisplayName

for _, Page in ipairs(Pages) do
	if Page[3] ~= Pages[1][3] and Page[3] ~= Pages[4][3] then
		Page[3].Position = UDim2.new(0, 0, -1, 0)
	end
	Page[3].Visible = true
end

for _, Button in ipairs(SideBar:GetChildren()) do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Click:Connect(function()
			if Button:GetAttribute("PageIndex") and not ClickDebounce then
				ClickDebounce = true
				UpdPage(Button:GetAttribute("PageIndex"))
			end
		end)
	end
end

Gui.MenuOpened.Event:Connect(function()
	for _, Page in ipairs(Pages) do
		if Page[3] ~= Pages[4][3] then
			Page[3].Position = UDim2.new(0, 0, -1, 0)
		end
		Page[3].Visible = true
	end
	Pages[4][3].Position = UDim2.new(0, 0, 0, 0)
end)
