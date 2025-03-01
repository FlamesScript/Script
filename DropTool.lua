local CoreGui = game:GetService("CoreGui")
local DestroyGui = CoreGui:FindFirstChild("gui")
if DestroyGui then
    DestroyGui:Destroy()
end

task.wait(0.5)
local gui = Instance.new("ScreenGui")
gui.Name = "gui"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local dropButton = Instance.new("TextButton")
dropButton.Text = "Drop"
dropButton.Position = UDim2.new(0.9, 0, 0.4, 0)
dropButton.Size = UDim2.new(0, 100, 0, 30)
dropButton.BackgroundColor3 = Color3.new(0, 0, 0)
dropButton.TextColor3 = Color3.new(1, 1, 1)
dropButton.Parent = gui

local function createLine(size, position, color)
    local line = Instance.new("Frame")
    line.Size = size
    line.Position = position
    line.BackgroundColor3 = color
    line.Parent = gui
    return line
end

createLine(UDim2.new(0, 100, 0, 2), UDim2.new(0.9, 0, 0.4, -2), Color3.new(0.5, 0.5, 0.5), gui)
createLine(UDim2.new(0, 100, 0, 2), UDim2.new(0.9, 0, 0.4, 30), Color3.new(0.5, 0.5, 0.5), gui)
createLine(UDim2.new(0, 2, 0, 30), UDim2.new(0.9, -2, 0.4, 0), Color3.new(0.5, 0.5, 0.5), gui)
createLine(UDim2.new(0, 2, 0, 30), UDim2.new(0.9, 100, 0.4, 0), Color3.new(0.5, 0.5, 0.5), gui)

local function onDropButtonClicked(character)
    local character = game.Players.LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            if tool.CanBeDropped == true then
                tool:Activate()
                tool.Parent = workspace
             else
           print("Tool Can't Be Dropped")
            end
        end
    end
end

dropButton.MouseButton1Click:Connect(onDropButtonClicked)
