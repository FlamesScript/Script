-- Configuration Variables
local reach = 8.00
local hit_distance = reach
local auto_swing = false
local auto_equip = true
local multi = 5
local CircleT = 0.5

-- Disable previous connections if they exist
local connections = getgenv().configs and getgenv().configs.connections
if connections then
    local Disable = configs.Disable
    for _, v in pairs(connections) do
        v:Disconnect()
    end
    Disable:Fire()
    Disable:Destroy()
    table.clear(configs)
end

-- Initialize new configurations
local Disable = Instance.new("BindableEvent")
getgenv().configs = {
    connections = {},
    Disable = Disable,
    Size = Vector3.new(reach, reach, reach),
    DeathCheck = true,
    AutoSwing = auto_swing,
    AutoEquip = auto_equip,
}

local WS = workspace

-- Remove old circle if it exists
local Destroy = WS:FindFirstChild("Circle")
if Destroy then
    Destroy:Destroy()
end

-- Create Circle Function
local function createCircle()
    local circle = Instance.new("Part")
    circle.Name = "Circle"
    circle.Anchored = true
    circle.CanCollide = false
    circle.CanTouch = true
    circle.CanQuery = true
    circle.Color = Color3.fromRGB(255, 0, 0)
    circle.Material = Enum.Material.ForceField
    circle.Shape = Enum.PartType.Ball
    circle.CastShadow = false
    circle.Transparency = 1  -- Hidden by default
    circle.Size = Vector3.new(reach, reach, reach)
    circle.Parent = workspace
    return circle
end

local function updateCircle(circle, handle)
    if handle then
        circle.Size = Vector3.new(reach, reach, reach)
        circle.CFrame = handle.CFrame
        circle.Transparency = CircleT -- Visible when equipped
    else
        circle.Transparency = 1 -- Hidden when not equipped
    end
end

local circle = createCircle()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Variables
local Run = true
local Ignorelist = OverlapParams.new()
Ignorelist.FilterType = Enum.RaycastFilterType.Include
local EquippedTool = nil

-- Helper Functions
local function getchar(plr)
    local plr = plr or lp
    return plr.Character
end

local function gethumanoid(plr)
    local char = plr:IsA("Model") and plr or getchar(plr)
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function IsAlive(Humanoid)
    return Humanoid and Humanoid.Health > 0
end

local function GetTouchInterest(Tool)
    return Tool and Tool:FindFirstChildWhichIsA("TouchTransmitter", true)
end

local function GetCharacters(LocalPlayerChar)
    local Characters = {}
    for _, v in ipairs(Players:GetPlayers()) do
        local char = getchar(v)
        if char and char ~= LocalPlayerChar then
            table.insert(Characters, char)
        end
    end
    return Characters
end

-- Helper Function to Check for ForceField
local function HasFF(character)
    return character:FindFirstChildOfClass("ForceField") ~= nil
end

-- Attack Function
local function Attack(Tool, TouchPart, ToTouch)
    -- Proceed with the attack if the character doesn't have a ForceField
    if not HasFF(ToTouch.Parent) then
        if Tool:IsDescendantOf(workspace) then
            Tool:Activate()
            for v = 1, multi do
                firetouchinterest(TouchPart, ToTouch, 1)
                firetouchinterest(TouchPart, ToTouch, 0)
            end
        end
    end
end

-- Auto Swing Functionality
local function StartAutoSwing(Tool)
    while EquippedTool == Tool and Run do
        if Tool:IsDescendantOf(workspace) and Tool.Parent == lp.Character then
            Tool:Activate()
        else
            break
        end
        task.wait()
    end
end

-- Character Added Event
lp.CharacterAdded:Connect(function()
    task.wait()
    EquippedTool = nil
end)

-- Main Loop (Updated)
while Run do
    local char = getchar()
    if char and IsAlive(gethumanoid(char)) then
        local Tool = char:FindFirstChildWhichIsA("Tool")
        if Tool and Tool ~= EquippedTool then
            EquippedTool = Tool
            if getgenv().configs.AutoSwing then
                task.spawn(StartAutoSwing, Tool)
            end
        elseif not Tool and EquippedTool then
            EquippedTool = nil
        end

        updateCircle(circle, EquippedTool and EquippedTool:FindFirstChild("Handle"))

        if EquippedTool then
            local TouchInterest = GetTouchInterest(EquippedTool)
            if TouchInterest then
                local TouchPart = TouchInterest.Parent
                local Characters = GetCharacters(char)
                Ignorelist.FilterDescendantsInstances = Characters
                local InstancesInBox = workspace:GetPartBoundsInBox(
                    TouchPart.CFrame,
                    TouchPart.Size + getgenv().configs.Size,
                    Ignorelist
                )
                for _, v in ipairs(InstancesInBox) do
                    local Character = v:FindFirstAncestorWhichIsA("Model")
                    if table.find(Characters, Character) then
                        local distance = (char.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude
                        if distance <= hit_distance then
                            -- Skip the LocalPlayer and check if the target has FF
                            if Character ~= lp and HasFF(Character) then
                                -- Skip the hit if the other player has FF
                            else
                                -- Proceed with attack if no FF
                                if getgenv().configs.DeathCheck then
                                    if IsAlive(gethumanoid(Character)) then
                                        if getgenv().configs.AutoEquip and not EquippedTool then
                                            EquippedTool = Tool
                                            Tool.Parent = char
                                        end
                                        Attack(EquippedTool, TouchPart, v)
                                    end
                                else
                                    Attack(EquippedTool, TouchPart, v)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    RunService.Heartbeat:Wait()
end
