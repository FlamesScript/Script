local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "Flames Hub | Universal AimBot ",
    Icon = 0, 
    LoadingTitle = "Flames Hub | Universal AimBot ",
    LoadingSubtitle = "Loading...",
    Theme = "Default", 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Big Hub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local Tab = Window:CreateTab("AimBot", 4483362458) 

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
    TeamCheck = true, -- Toggle for team-based check
    RainbowFOV_C = false -- Rainbow FOV toggle
}

local localPlayer = Players.LocalPlayer
local currentTarget = nil
local hue = 0 -- Hue for rainbow effect

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
    if not target or not target.Parent then return false end

    local character = target.Parent
    local humanoid = character:FindFirstChild("Humanoid")
    local enemyPlayer = Players:GetPlayerFromCharacter(character)

    if humanoid and humanoid.Health > 0 and enemyPlayer then
        if SETTINGS.TeamCheck then
            if enemyPlayer.Team and localPlayer.Team and enemyPlayer.TeamColor == localPlayer.TeamColor then
                return false -- Ignore teammates
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

-- Aim Lock Connection (Main Loop)
getgenv().AimLockConnection = RunService.RenderStepped:Connect(function()
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    fovCircle.Position = center
    fovCircle.Radius = SETTINGS.FovCircleSize

    if not SETTINGS.AimLockOn then
        currentTarget = nil
        fovCircle.Color = Color3.fromRGB(255, 255, 255) -- Default white when AimLock is off
        return
    end

    -- Update rainbow effect without interfering with aim lock
    if SETTINGS.RainbowFOV_C then
        hue = (hue + 3) % 360 -- Adjust speed (higher = faster transition)
        fovCircle.Color = Color3.fromHSV(hue / 360, 1, 1) -- Rainbow color
    end

    -- Aim lock logic (this should always run)
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
    end
end)

local Aimbot = Tab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = getgenv().SETTINGS.AimLockOn,
    Flag = "Aimbot",
    Callback = function(Value)
        getgenv().SETTINGS.AimLockOn = Value
        fovCircle.Visible = getgenv().SETTINGS.AimLockOn
    end,
})

local TargetDropdown = Tab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head"},
    CurrentOption = {"Head"}, -- Default to Torso
    MultipleOptions = false,
    Flag = "TargetPart",
    Callback = function(Options)
        getgenv().SETTINGS.TargetPart = Options
    end,
})

local FOVSlider = Tab:CreateSlider({
    Name = "FOV Size",
    Range = {0, 300},
    Increment = 1, -- Set increment to 5
    Suffix = "", -- Remove suffix
    CurrentValue = getgenv().SETTINGS.FovCircleSize,
    Flag = "FOVSize",
    Callback = function(Value)
     getgenv().SETTINGS.FovCircleSize = Value
        fovCircle.Radius = Value
    end,
})

local RainbowFOV = Tab:CreateToggle({
    Name = "RainbowFOV",
    CurrentValue = false,
    Flag = "RainbowFOV",
    Callback = function(Value)
        getgenv().SETTINGS.RainbowFOV_C = Value
    end,
})


getgenv().ESP_Settings = {
    Enabled = false, -- Starts disabled until toggled
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 0, 0), -- Default Enemy Color
    FriendlyColor = Color3.fromRGB(0, 255, 0), -- Friendly Team Color
    NeutralColor = Color3.fromRGB(255, 255, 255), -- Neutral Color
    BoxThickness = 1.5,
    BoxTransparency = 1,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}

local function CreateESP(plr)
    if ESP_Objects[plr] then return end -- Prevent duplicates

    local box = Drawing.new("Quad")
    box.Visible = false
    box.Thickness = getgenv().ESP_Settings.BoxThickness
    box.Color = getgenv().ESP_Settings.BoxColor -- Default color
    box.Filled = false
    box.Transparency = getgenv().ESP_Settings.BoxTransparency

    ESP_Objects[plr] = { Box = box }

    local function UpdateESP()
        while getgenv().ESP_Settings.Enabled do
            RunService.RenderStepped:Wait()

            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local HumPos, OnScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)

                if OnScreen then
                    local head = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local distanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    local function SetBox(box)
                        box.PointA = Vector2.new(HumPos.X + distanceY, HumPos.Y - distanceY * 2)
                        box.PointB = Vector2.new(HumPos.X - distanceY, HumPos.Y - distanceY * 2)
                        box.PointC = Vector2.new(HumPos.X - distanceY, HumPos.Y + distanceY * 2)
                        box.PointD = Vector2.new(HumPos.X + distanceY, HumPos.Y + distanceY * 2)
                    end

                    SetBox(box)

                    -- Fix TeamCheck logic using TeamColor
                    if getgenv().ESP_Settings.TeamCheck then
                        if plr.Team and LocalPlayer.Team then  -- Check if both the player and local player have teams
                            if plr.TeamColor == LocalPlayer.TeamColor then
                                box.Color = getgenv().ESP_Settings.FriendlyColor  -- Same team
                            else
                                box.Color = getgenv().ESP_Settings.BoxColor  -- Enemy team
                            end
                        else
                            box.Color = getgenv().ESP_Settings.NeutralColor  -- No team (Baseplate game scenario)
                        end
                    else
                        box.Color = getgenv().ESP_Settings.NeutralColor  -- No team (Always neutral if TeamCheck is off)
                    end
                    
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
                ESP_Objects[plr] = nil
                break
            end
        end
    end

    coroutine.wrap(UpdateESP)()
end

local function ApplyESP(plr)
    if plr.Character then
        CreateESP(plr)
    end
    plr.CharacterAdded:Connect(function()
        CreateESP(plr)
    end)
end

local function ToggleESP(state)
    getgenv().ESP_Settings.Enabled = state

    if state then
        -- Enable ESP: Apply ESP to all players
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                ApplyESP(v)
            end
        end
    else
        -- Disable ESP: Remove all ESP objects and stop updating
        for plr, data in pairs(ESP_Objects) do
            if data.Box then
                data.Box.Visible = false
                data.Box:Remove() -- Remove the drawing object
            end
        end
        ESP_Objects = {} -- Clear the table so ESP does not persist
    end
end

-- Apply ESP to all players (only if enabled)
Players.PlayerAdded:Connect(function(plr)
    if getgenv().ESP_Settings.Enabled then
        ApplyESP(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Objects[plr] then
        ESP_Objects[plr].Box:Remove()
        ESP_Objects[plr] = nil
    end
end)

local Esp = Tab:CreateToggle({
    Name = "Esp",
    CurrentValue = false,
    Flag = "Esp",
    Callback = function(Value)
        ToggleESP(Value)
    end,
})

local Tab = Window:CreateTab("Player", 4483362458) 

local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- Function to get the humanoid from the character, ensuring it's available
local function getHumanoid()
    -- Wait until the character exists
    local chr = lplr.Character
    if not chr then
        return nil
    end
    
    -- Wait until the humanoid exists
    local hum = chr:FindFirstChildOfClass("Humanoid")
    repeat
        wait()
        hum = chr:FindFirstChildOfClass("Humanoid")
    until hum

    return hum
end

-- Update humanoid when character is reset
local function updateHumanoid()
    local hum = getHumanoid()
    
    -- Wait until humanoid is found
    while not hum do
        lplr.CharacterAdded:Wait()
        hum = getHumanoid()
        wait()
    end

    return hum
end

-- Initial humanoid setup
local hum = updateHumanoid()

-- Slider for WalkSpeed
local SpeedSlider = Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0, 300},
    Increment = 1,
    Suffix = "", 
    CurrentValue = hum.WalkSpeed,
    Flag = "SpeedSlider",
    Callback = function(Value)
        hum = updateHumanoid()  -- Ensure you get the current humanoid after reset
        if hum then
            hum.WalkSpeed = Value
        end
    end,
})

-- Slider for JumpPower
local JumpSlider = Tab:CreateSlider({
    Name = "JumpPower",
    Range = {0, 300},
    Increment = 1, 
    Suffix = "",
    CurrentValue = hum.JumpPower,
    Flag = "JumpSlider",
    Callback = function(Value)
        hum = updateHumanoid()  -- Ensure you get the current humanoid after reset
        if hum then
            hum.JumpPower = Value
        end
    end,
})

local cam = workspace:FindFirstChildOfClass("Camera") 

local v_FOVSlider = Tab:CreateSlider({
    Name = "FOV",
    Range = {0, 300},
    Increment = 1, -- Set increment to 5
    Suffix = "", -- Remove suffix
    CurrentValue = cam.FieldOfView ,
    Flag = "v_FOVSlider",
    Callback = function(Value)
    cam.FieldOfView = Value
end,
})
