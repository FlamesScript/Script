local InfiniteJump = true
getgenv().InfiniteJumpEnabled = InfiniteJump

local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

local function onJumpRequest()
    if getgenv().InfiniteJumpEnabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

UserInputService.JumpRequest:Connect(onJumpRequest)
