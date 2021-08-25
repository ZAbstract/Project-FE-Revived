local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PassKey = nil

local wait = function(Duration)
	Duration = Duration or (1 / 30)
	local Start = os.clock()

	while os.clock() - Start < Duration do 
		RunService.Stepped:Wait()
	end
end

while not PassKey do
	PassKey = ReplicatedStorage.Remote.GetPassKey:InvokeServer(script.Name)
	wait(0.5)
end

local MainInfo = script.Parent

local FlipInfo = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local IsActive = false
local Dir, Style, Dur = "Out", "Back", 0.7

local Floor = math.floor

function ToggleInfo(Toggle)
	Dir = Toggle and "Out" or "In"
	Style = Toggle and "Back" or "Quad"
	Dur = Toggle and 0.7 or 0.4
	TweenService:Create(MainInfo.NetworkInfo.Arrow, FlipInfo, {Rotation = Toggle and -90 or 90}):Play()
	for _, Item in ipairs(MainInfo:GetDescendants()) do
		if Item:GetAttribute("IsInfoObject") then
			Item:TweenPosition(Item:GetAttribute(Toggle and "EndPos" or "StartPos"), Dir, Style, Dur, true)
		end
	end
end

function GetLocation()
	local Success, Response = ReplicatedStorage.Remote.GetServerData:InvokeServer(PassKey)

	if Success then
		MainInfo.ServerLocation.ServerLocation.Text = Response[1] .. ", " .. Response[2] .. ", " .. Response[3] .. " (".. Response[4] .. ") " .. "(IP: " .. Response[5] .. ")"
	else
		MainInfo.ServerLocation.ServerLocation.Text = Response
	end
end

function GetPing()
	local Start = os.clock()
	ReplicatedStorage.Remote.GetPing:InvokeServer()

	local Ping = (os.clock() - Start)
	Ping = Ping * 1000
	Ping = Floor(Ping * 1000) / 1000
	MainInfo.Ping.PingText.Text = Ping .. " ms"
end

MainInfo.NetworkInfo.Arrow.Activated:Connect(function()
	IsActive = not IsActive
	ToggleInfo(IsActive)
end)

coroutine.resume(coroutine.create(GetLocation))
coroutine.resume(coroutine.create(function()
	while true do
		GetPing()
		wait(0.5)
	end
end))
