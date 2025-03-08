if getgenv().AimLockConnection then
    getgenv().AimLockConnection:Disconnect()
    getgenv().AimLockConnection = nil
end

if getgenv().FovCircle then
    getgenv().FovCircle:Remove()
    getgenv().FovCircle = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

getgenv().SETTINGS = {
    AimLockOn = false,
    TargetPart = "Head",
    FovCircleSize = 70,
    TeamCheck = false  -- Toggle for team-based check
}

local localPlayer = Players.LocalPlayer
local currentTarget = nil

-- Create FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = SETTINGS.AimLockOn
fovCircle.Radius = SETTINGS.FovCircleSize
fovCircle.NumSides = 60
fovCircle.Thickness = 1
fovCircle.Transparency = 1
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
getgenv().FovCircle = fovCircle

-- Function to check if a target is valid
local function isValidTarget(target)
    if not target or not target.Parent then
        return false
    end

    local character = target.Parent
    local humanoid = character:FindFirstChild("Humanoid")
    local enemyPlayer = Players:GetPlayerFromCharacter(character)

    if humanoid and humanoid.Health > 0 and enemyPlayer then
        -- Check if both the player and local player are in a team
        if SETTINGS.TeamCheck then
            if enemyPlayer.Team and localPlayer.Team then
                if enemyPlayer.TeamColor == localPlayer.TeamColor then
                    return false -- Ignore teammates
                end
            end
        end
        return true
    end
    return false
end

-- Function to get the closest target
local function getClosestTarget()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closestTarget = nil
    local closestScreenDist = fovCircle.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(SETTINGS.TargetPart)
            if targetPart and isValidTarget(targetPart) then
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPart.Position)

                if onScreen then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local screenDist = (screenPos - center).Magnitude

                    if screenDist < fovCircle.Radius and screenDist < closestScreenDist then
                        closestTarget = targetPart
                        closestScreenDist = screenDist
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Aim Lock Connection
getgenv().AimLockConnection = RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = SETTINGS.FovCircleSize

    if not SETTINGS.AimLockOn then
        currentTarget = nil
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        return
    end

    if currentTarget then
        if not isValidTarget(currentTarget) then
            currentTarget = nil
        else
            local screenPoint, onScreen = camera:WorldToViewportPoint(currentTarget.Position)
            if not onScreen or (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude > fovCircle.Radius then
                currentTarget = nil
            end
        end
    end

    if not currentTarget then
        currentTarget = getClosestTarget()
    end

    if currentTarget then
        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
        fovCircle.Color = Color3.fromRGB(255, 0, 0)
    else
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
    end
end)
