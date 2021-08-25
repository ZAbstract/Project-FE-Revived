local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")

local Remote = ReplicatedStorage:WaitForChild("Remote")

local PassKey = nil
local CurrentGameState = "lobby"
local CurrentMap = nil

while not PassKey do
	PassKey = Remote.GetPassKey:InvokeServer(script.Name)
	task.wait(0.5)
end

local WaitingRegion = workspace.LiftParts.WaitingRegion

function GetTouchingParts(Obj)
	local Connection = Obj.Touched:Connect(function() end)
	local Parts = Obj:GetTouchingParts()
	Connection:Disconnect()
	return Parts
end

function IsInLift()
	local Parts = GetTouchingParts(WaitingRegion)
	local Found = false

	for _, Part in ipairs(Parts) do
		if Part == HumanoidRootPart then
			Found = true
			break
		end
	end
	return Found
end

function UpdateCurrentState(State)
	CurrentGameState = State
end

coroutine.wrap(function()
	local Success
	while not Success do
		Success = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false)
		task.wait()
	end
end)()

task.spawn(function()
	RunService.Heartbeat:Connect(function(Step, _)
		if IsInLift() and CurrentGameState == "lobby" then
			UpdateCurrentState("waiting")
			print("Waiting for lift")
			Remote.AddToWaiting:FireServer()
		elseif not IsInLift() and CurrentGameState == "waiting" then
			UpdateCurrentState("lobby")
			print("Exited lift")
			Remote.RemoveFromWaiting:FireServer()
		end
	end)
end)

workspace.CurrentGame.ChildAdded:Connect(function(Child)
	if Child:IsA("Model") and Child.Name == "LoadingMap" then
		CurrentMap = Child
	end
end)

Remote.UpdateState.OnClientEvent:Connect(UpdateCurrentState)
