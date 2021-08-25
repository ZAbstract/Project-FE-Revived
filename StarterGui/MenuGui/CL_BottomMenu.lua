local TweenService = game:GetService("TweenService")

local Gui = script.Parent
local BottomBar = Gui.BottomFrame
local MainFrame = Gui["BG#C_T"]

local FadeInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local IsActive = false
local Debounce = false

function ToggleMainMenu(Toggle)
	if Toggle then
		Gui.MenuOpened:Fire()
	end
	BottomBar.ToggleMenu.UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, Toggle and 0 or 1)
	})
	TweenService:Create(BottomBar.ToggleMenu.Selected, FadeInfo, {BackgroundTransparency = Toggle and 0 or 1}):Play()
	MainFrame:TweenPosition(
		Toggle and MainFrame:GetAttribute("EndPos") or MainFrame:GetAttribute("StartPos"),
		"Out",
		"Back",
		1,
		true,
		function()
			Debounce = false
		end
	)
end

BottomBar.ToggleMenu.ImageBTN.MouseButton1Click:Connect(function()
	if not Debounce then
		Debounce = true
		IsActive = not IsActive
		ToggleMainMenu(IsActive)
	end
end)
