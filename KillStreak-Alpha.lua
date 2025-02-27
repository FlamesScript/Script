-- Safely destroy anti-cheat elements if they exist
local function safeDestroy(parent, name)
    local obj = parent:FindFirstChild(name)
    if obj then
        obj:Destroy()
    end
end

safeDestroy(game.Workspace, "DEATHBARRIER")
safeDestroy(game.Workspace, "RAGDOLLBARRIER")
safeDestroy(game:GetService("StarterPlayer").StarterCharacterScripts, "Anticheat")
safeDestroy(game.Players.LocalPlayer.Character, "Anticheat")

-- GUI cleanup
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local existingGUI = PlayerGui:FindFirstChild("FarmGUI")
if existingGUI then
    existingGUI:Destroy()
end

-- GUI creation
local FarmGUI = Instance.new("ScreenGui")
FarmGUI.Name = "FarmGUI"
FarmGUI.ResetOnSpawn = false
FarmGUI.Parent = PlayerGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 100, 0, 50)
Button.Position = UDim2.new(0.9, 0, 0.35, 0)
Button.AnchorPoint = Vector2.new(0, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Text = "AutoFarm"
Button.Font = Enum.Font.FredokaOne
Button.TextSize = 20
Button.Parent = FarmGUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Button

-- Target positions (restored all locations)
local targetPositions = {
    CFrame.new(-83.1948318, 29.2763004, -49.2731819, 0.368083358, 0, 0.929792821, 0, 1, 0, -0.929792821, 0, 0.368083358),
    CFrame.new(78.5890503, 29.2763004, 83.9765396, -0.614975095, 0, -0.788546503, 0, 1, 0, 0.788546503, 0, -0.614975095),
    CFrame.new(-72.358284, 29.2763004, 84.4179688, -0.736565828, 0, 0.676365912, 0, 1, 0, -0.676365912, 0, -0.736565828),
    CFrame.new(166.100998, 46.9050217, -88.5499649, -0.0677970722, 0, -0.997699142, 0, 1, 0, 0.997699142, 0, -0.0677970722),
    CFrame.new(52.9775467, -2.39225841, 247.394348, -0.121719845, 0, -0.992564499, 0, 1, 0, 0.992564499, 0, -0.121719845),
    CFrame.new(-255.25177, 29.3819962, 9.66881752, -0.0954926834, 0, 0.995430052, 0, 1, 0, -0.995430171, 0, -0.0954926684),
    CFrame.new(-210.5383, 345.507446, 15.7142897, 0.677483797, 0, 0.735537708, 0, 1, 0, -0.735537708, 0, 0.677483797),
    CFrame.new(264.51947, 29.3046799, 10.809412, 0.123071566, 0, -0.992397845, 0, 1, 0, 0.992397845, 0, 0.123071566)
}

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tool management functions
local function equipTool(character)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildWhichIsA("Tool")
        if tool and tool.Parent ~= character then
            tool.Parent = character
        end
    end
end

local function activateTool(character)
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then
        tool:Activate()
    end
end

-- Farming control
local farming = false
local farmingThread = nil

Button.MouseButton1Click:Connect(function()
    farming = not farming
    Button.Text = farming and "Stop" or "Start"
    
    if farming then
        farmingThread = task.spawn(function()
            while farming do
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                
                for _, targetCFrame in ipairs(targetPositions) do
                    if not farming then break end
                    
                    -- Update character reference in case of respawn
                    character = player.Character or character
                    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    
                    -- Teleport and execute actions
                    humanoidRootPart.CFrame = targetCFrame
                    equipTool(character)
                    task.wait(0.5)
                    activateTool(character)
                    task.wait(1)
                end
                task.wait()
            end
        end)
    else
        if farmingThread then
            task.cancel(farmingThread)
            farmingThread = nil
        end
    end
end)
