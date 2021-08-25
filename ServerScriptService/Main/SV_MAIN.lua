local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local MapScript = require(ServerScriptService.MapResources.MapScript)

local Remote = ReplicatedStorage:WaitForChild("Remote")
local Bindables = ServerStorage:WaitForChild("Bindables")

local PassKey = HttpService:GenerateGUID(false)

local PassKeyRequests = {}

local Playing = false

local WaitingPlayers = {}
local CurrentPlayers = {}

local LiftParts = workspace:WaitForChild("LiftParts")
local MapInterface = workspace:WaitForChild("MapInterface")

local DifficultyTable = {
	[1] = "Easy",
	[2] = "Normal",
	[3] = "Hard",
	[4] = "Insane",
	[5] = "Extreme"
}
local CurrentDifficulty = 2

function GetLocationData()
	local ServerData = HttpService:GetAsync("http://ip-api.com/json/")
	ServerData = HttpService:JSONDecode(ServerData)

	if ServerData.status == "success" then
		local City = ServerData.city
		local RegionName = ServerData.regionName
		local Country = ServerData.country
		local CountryCode = ServerData.countryCode
		local ServerIP = ServerData.query

		return true, {City, RegionName, Country, CountryCode, ServerIP}
	else
		return nil, "Failed to return data successfully"
	end
end

Remote.GetServerData.OnServerInvoke = function(_, ScriptPassKey)
	if ScriptPassKey == PassKey then
		local Success, Response = GetLocationData()
		return Success, Response
	else
		return nil, "You do not have the permissions to do this."
	end
end

Remote.GetPassKey.OnServerInvoke = function(_, ScriptName)
	local AllowedCallScripts = {"CL_MAIN", "CL_BottomMenu", "CL_MenuPages", "CL_Preferences", "CL_NetworkInfo"}
	if PassKeyRequests[ScriptName] == nil and table.find(AllowedCallScripts, ScriptName) then
		PassKeyRequests[ScriptName] = true
		return PassKey
	end
end

Remote.GetPing.OnServerInvoke = function(_)
	return true
end

Remote.AddToWaiting.OnServerEvent:Connect(function(Player)
	table.insert(WaitingPlayers, Player)
end)

Remote.RemoveFromWaiting.OnServerEvent:Connect(function(Player)
	for Index = 1, #WaitingPlayers do
		if WaitingPlayers[Index] == Player then
			table.remove(WaitingPlayers, Index)
		end
	end
end)

Bindables.GetPlayerCount.OnInvoke = function()
	return #CurrentPlayers
end

while RunService.Heartbeat:Wait() do
	if #WaitingPlayers > 0 and not Playing then
		local Maps = ServerStorage.Maps[DifficultyTable[CurrentDifficulty]]:GetChildren()
		local Chosen = Maps[math.random(1, #Maps)]:Clone()
		Chosen.Name = "LoadingMap"
		Chosen.Parent = workspace.CurrentGame

		task.wait(5)
		
		if #WaitingPlayers > 0 then
			Playing = true
			local Settings = Chosen.Settings
			local MapName = Settings.Main:GetAttribute("MapName")
			local Creator = Settings.Main:GetAttribute("Creator")
			local Difficulty = DifficultyTable[Settings.Main:GetAttribute("Difficulty")]
			
			MapInterface.CurrentMap.MainUI.MapName.Text = MapName
			MapInterface.CurrentMap.MainUI.Creators.Text = Creator
			MapInterface.CurrentMap.MainUI.Difficulty.Text = Difficulty
			
			CurrentPlayers = {}
			for _, Player in ipairs(WaitingPlayers) do
				if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
					Player.Character.HumanoidRootPart.CFrame = CFrame.new(Chosen.MapSpawn.Position + Vector3.new(0, 1, 0))
					Remote.UpdateState:FireClient(Player, "ingame")	
					table.insert(CurrentPlayers, Player)
				end
			end
			MapScript.InitiateMap(Chosen)
			Chosen.Name = "Map"
		else
			print("Restarting")
			if Chosen then
				Chosen:Destroy()
			end
		end
	end
end
