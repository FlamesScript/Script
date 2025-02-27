--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

--// Settings
local SETTINGS = {
    AimLockOn = true,      -- Toggle Aim Lock ON/OFF
    MaxRange = 60,        -- Maximum distance to lock on
    MaxRangeOn = false,     -- If false, script locks onto any visible enemy in the circle regardless of range
    TargetPart = "Head",   -- The part to lock on (Head, HumanoidRootPart, etc.)
    FovCircleSize = 70,    -- The size of the FOV circle (adjustable from here)
}

--// Variables
local localPlayer = Players.LocalPlayer
local currentTarget = nil
local existingScript = nil  -- Reference to the previous instance of the script

-- Check if an existing script is running and disable it
if existingScript then
    existingScript:Disconnect()
end

--// Create an FOV Circle (fixed at the center of the screen)
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = SETTINGS.FovCircleSize
fovCircle.NumSides = 60
fovCircle.Thickness = 1
fovCircle.Transparency = 1
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 255, 255) -- Default white

--// Create "Locked On" label
local lockedLabel = Drawing.new("Text")
lockedLabel.Visible = false
lockedLabel.Text = ""
lockedLabel.Color = Color3.fromRGB(255, 0, 0) -- Neon Red
lockedLabel.Size = 15
lockedLabel.Center = true

-- Function to check if a target is valid
local function isValidTarget(target)
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
        local humanoid = target.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            return true
        end
    end
    return false
end

-- Function to get the closest target inside the FOV circle
local function getClosestTarget()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closestTarget = nil
    local closestDistance = SETTINGS.MaxRange
    local closestScreenDist = fovCircle.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(SETTINGS.TargetPart)
            if targetPart and isValidTarget(targetPart) then
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local worldDist = (targetPart.Position - camera.CFrame.Position).Magnitude
                
                if onScreen then
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local screenDist = (screenPos - center).Magnitude

                    -- Check if inside the circle AND closer than the previous closest enemy
                    if screenDist < fovCircle.Radius then
                        if SETTINGS.MaxRangeOn then
                            if worldDist <= SETTINGS.MaxRange and worldDist < closestDistance then
                                closestTarget = targetPart
                                closestDistance = worldDist
                                closestScreenDist = screenDist
                            end
                        else
                            -- Ignore distance limit, just find the closest target inside the FOV circle
                            if screenDist < closestScreenDist then
                                closestTarget = targetPart
                                closestScreenDist = screenDist
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Main loop: update aim lock and UI every frame
existingScript = RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = center -- Keep the circle centered
    lockedLabel.Position = center - Vector2.new(0, fovCircle.Radius + 15) -- Position label above circle

    -- Update FOV circle size based on the SETTINGS value
    fovCircle.Radius = SETTINGS.FovCircleSize

    if not SETTINGS.AimLockOn then
        currentTarget = nil
        fovCircle.Color = Color3.fromRGB(255, 255, 255) -- White
        lockedLabel.Visible = false
        return
    end

    -- Check if the current target is still valid
    if currentTarget then
        if not isValidTarget(currentTarget) then
            currentTarget = nil
        else
            local screenPoint, onScreen = camera:WorldToViewportPoint(currentTarget.Position)
            if not onScreen then
                currentTarget = nil
            else
                local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                if (screenPos - center).Magnitude > fovCircle.Radius then
                    currentTarget = nil
                end
            end
        end
    end

    -- If no target is locked, find the closest one inside the circle
    if not currentTarget then
        currentTarget = getClosestTarget()
    end

    -- Update visuals based on target lock status
    if currentTarget then
        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
        fovCircle.Color = Color3.fromRGB(255, 0, 0) -- Neon Red
        lockedLabel.Visible = true
    else
        fovCircle.Color = Color3.fromRGB(255, 255, 255) -- White when no lock
        lockedLabel.Visible = false
    end
end)
