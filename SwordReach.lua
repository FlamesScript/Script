-- Stop previous execution if script runs again
if getgenv().configs then
    getgenv().configs.Run = false
    task.wait() -- Wait briefly to stop old loop

    -- Disconnect previous connections
    if getgenv().configs.connections then
        for _, v in pairs(getgenv().configs.connections) do
            v:Disconnect()
        end
    end

    -- Fire and destroy Disable event
    if getgenv().configs.Disable then
        getgenv().configs.Disable:Fire()
        getgenv().configs.Disable:Destroy()
    end

    -- Clear the configs table
    table.clear(getgenv().configs)
end

-- Initialize configurations
getgenv().configs = {
    reach = 8.00,
    hit_distance = 8.00,
    auto_swing = false,
    auto_equip = true,
    multi = 5,
    CircleT = 0.5,
    DeathCheck = true,
    Run = true, -- Used to control loop execution
    connections = {},
    Disable = Instance.new("BindableEvent")
}

local WS = workspace

-- Remove old circle if it exists
local oldCircle = WS:FindFirstChild("Circle")
if oldCircle then oldCircle:Destroy() end

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
    circle.Size = Vector3.new(getgenv().configs.reach, getgenv().configs.reach, getgenv().configs.reach)
    circle.Parent = WS
    return circle
end

local function updateCircle(circle, handle)
    if handle then
        circle.Size = Vector3.new(getgenv().configs.reach, getgenv().configs.reach, getgenv().configs.reach)
        circle.CFrame = handle.CFrame
        circle.Transparency = getgenv().configs.CircleT -- Visible when equipped
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
local Ignorelist = OverlapParams.new()
Ignorelist.FilterType = Enum.RaycastFilterType.Include
local EquippedTool = nil

-- Helper Functions
local function getchar(plr)
    return plr and plr.Character
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
            for _ = 1, getgenv().configs.multi do
                firetouchinterest(TouchPart, ToTouch, 1)
                firetouchinterest(TouchPart, ToTouch, 0)
            end
        end
    end
end

-- Auto Swing Functionality
local function StartAutoSwing(Tool)
    while EquippedTool == Tool and getgenv().configs.Run do
        if Tool:IsDescendantOf(workspace) and Tool.Parent == lp.Character then
            Tool:Activate()
        else
            break
        end
        task.wait()
    end
end

-- Character Added Event
table.insert(getgenv().configs.connections, lp.CharacterAdded:Connect(function()
    task.wait()
    EquippedTool = nil
end))

-- Main Loop (Updated)
while getgenv().configs.Run do
    local char = getchar(lp)
    if char and IsAlive(gethumanoid(char)) then
        local Tool = char:FindFirstChildWhichIsA("Tool")
        if Tool and Tool ~= EquippedTool then
            EquippedTool = Tool
            if getgenv().configs.auto_swing then
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
                    TouchPart.Size + Vector3.new(getgenv().configs.reach, getgenv().configs.reach, getgenv().configs.reach),
                    Ignorelist
                )
                for _, v in ipairs(InstancesInBox) do
                    local Character = v:FindFirstAncestorWhichIsA("Model")
                    if table.find(Characters, Character) then
                        local distance = (char.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude
                        if distance <= getgenv().configs.hit_distance then
                            if getgenv().configs.DeathCheck then
                                if IsAlive(gethumanoid(Character)) then
                                    if getgenv().configs.auto_equip and not EquippedTool then
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
    RunService.Heartbeat:Wait()
end
