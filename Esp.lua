getgenv().ESP_Settings = {
    Enabled = true,
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
        task.wait(0.5) -- Wait for character to load
        CreateESP(plr)
    end)
end

-- Apply ESP to all players
for _, v in pairs(Players:GetPlayers()) do  
    if v ~= LocalPlayer then  
        ApplyESP(v)
    end  
end  

Players.PlayerAdded:Connect(ApplyESP)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Objects[plr] then
        ESP_Objects[plr].Box:Remove()
        ESP_Objects[plr] = nil
    end
end)
