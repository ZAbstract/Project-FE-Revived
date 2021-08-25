local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local WallJump = require(script:WaitForChild("WallJump"))
local WallSlide = require(script:WaitForChild("WallSlide"))
local Slide = require(script:WaitForChild("Slide"))

local SlideAnim = Instance.new("Animation")
SlideAnim.AnimationId = Slide.GetAnimSequence()

local WallAnimTrack = Humanoid:LoadAnimation(script:WaitForChild("WallGripAnim"))
local SlideAnimTrack = Humanoid:LoadAnimation(SlideAnim)

local LastJump = tick()
local SlideTime = 0.5

local SlideKeybind = Enum.KeyCode.Q

local CheckStates = {
	Enum.HumanoidStateType.Dead,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.Swimming
}

local BLANK_VECTOR3 = Vector3.new()

function OnHumanoidTouched(Hit)
	local CurrentState = Humanoid:GetState()
	if (CurrentState == Enum.HumanoidStateType.Jumping or CurrentState == Enum.HumanoidStateType.Freefall) then
		local CurrentCF = HumanoidRootPart.CFrame
		local WallRay = workspace:Raycast(CurrentCF.Position, CurrentCF.LookVector * 2)
		
		if WallRay and WallRay.Instance and WallRay.Instance == Hit then
			if WallRay.Instance:FindFirstChild("_Wall") and not WallRay.Instance:FindFirstChild("_WallSlide") then
				if not WallJump.IsActive and not WallSlide.IsActive and tick() > LastJump + 0.15 then
					WallAnimTrack:Play()
					WallJump:AttachPlayer(WallRay)
					
					local Begin = tick()
					local Jumped = false

					spawn(function()
						UserInputService.JumpRequest:Wait()
						if Begin < tick() + 0.75 then
							Jumped = true
						end
					end)

					repeat
						RunService.Heartbeat:Wait()
					until Jumped or tick() > Begin + 0.75
					
					WallAnimTrack:Stop()
					WallJump:DetachPlayer(WallRay, Jumped)
					LastJump = tick()
				end
			elseif WallRay.Instance:FindFirstChild("_WallSlide") and not WallRay.Instance:FindFirstChild("_Wall") and tick() > LastJump + 0.1 then
				if not WallSlide.IsActive and not WallJump.IsActive then
					local Speed = Hit._WallSlide:FindFirstChild("Speed")
					if Speed and (Speed:IsA("NumberValue") or Speed:IsA("IntValue")) then
						WallSlide:AttachPlayer(Hit, Speed.Value, WallRay)
						
						spawn(function()
							local Jumped = false
							UserInputService.JumpRequest:Wait()
							if WallSlide.IsActive then
								Jumped = true

								local CurrentCF = HumanoidRootPart.CFrame
								local BackRay = workspace:Raycast(CurrentCF.Position, CurrentCF.LookVector * -2, WallSlide.GetBlacklistParams())

								WallAnimTrack:Stop()
								WallSlide:DetachPlayer(BackRay, Jumped)
								print("Jumped")
								LastJump = tick()
							end
						end)
					end
				end
			end
		end
	end
end

function HandleSlideAction(Name, State, Obj)
	local CurrentState = Humanoid:GetState()
	if (CurrentState == Enum.HumanoidStateType.Freefall or CurrentState == Enum.HumanoidStateType.Jumping) then
		return
	end
	if State == Enum.UserInputState.Begin and not Slide.IsActive and not WallJump.IsActive and Humanoid:GetState() ~= unpack(CheckStates) then
		if Humanoid.MoveDirection == BLANK_VECTOR3 then
			return
		end
		SlideAnimTrack:Play()
		Slide:Activate()
		task.delay(SlideTime, StopSliding)
	elseif State == Enum.UserInputState.End and Slide.IsActive then
		SlideAnimTrack:Stop()
		Slide:Deactivate()
	end
end

function StopSliding()
	SlideAnimTrack:Stop()	
	Slide:Deactivate()
end

ContextActionService:BindAction("SlideFunc", HandleSlideAction, true, SlideKeybind)

Humanoid.Touched:Connect(OnHumanoidTouched)
Humanoid.Jumping:Connect(StopSliding)

--[[
Humanoid.PlatformStanding:Connect(StopSliding)
Humanoid.FreeFalling:Connect(StopSliding)
Humanoid.FallingDown:Connect(StopSliding)
Humanoid.Climbing:Connect(StopSliding)
Humanoid.Swimming:Connect(StopSliding)
Humanoid.Seated:Connect(StopSliding)
Humanoid.Died:Connect(StopSliding)
]]

Humanoid.StateChanged:Connect(function(OldState, NewState)
	if NewState == Enum.HumanoidStateType.Jumping and Humanoid.Jump then
		HumanoidRootPart.Velocity = Vector3.new(HumanoidRootPart.Velocity.X, Humanoid.JumpPower * 1.1, HumanoidRootPart.Velocity.Z)
	end
end)
