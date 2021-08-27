--Old code does not work now. This will be rescripted soon.

local Gui = script.Parent

local DeviceInfo = Gui:WaitForChild("DeviceInfo")
local MapSearch = Gui:WaitForChild("MapSearch")
local Personalization = Gui:WaitForChild("Personalization")
local SearchFrame = Gui:WaitForChild("SearchFrame")
local SettingsButtons = Gui:WaitForChild("SettingsButtons")
local SearchTextbox = Gui:WaitForChild("SearchTextbox")

local CurrentTab = nil
local PreferenceFrames = {["DeviceInfo"] = DeviceInfo, ["MapSearch"] = MapSearch, ["Personalization"] = Personalization}

function ViewTab(Tab)
	CurrentTab = Tab
	for _, Frame in ipairs(SettingsButtons:GetChildren()) do
		Frame.BackgroundColor3 = Color3.fromRGB(64, 70, 70)
	end
	for _, Frame in pairs(PreferenceFrames) do
		Frame.Visible = false
	end
	SettingsButtons[Tab].BackgroundColor3 = Color3.fromRGB(127, 140, 141)
	if PreferenceFrames[Tab] ~= nil then
		PreferenceFrames[Tab].Visible = true
	end
end

for _, Frame in ipairs(SettingsButtons:GetChildren()) do
	local ClickBtn = Frame:FindFirstChild("ClickBtn")
	if ClickBtn then
		ClickBtn.MouseButton1Click:Connect(function()
			ViewTab(Frame.Name)
		end)
	end
end

ViewTab("Personalization")
