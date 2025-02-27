local player = game.Players.LocalPlayer

local function maintainInfiniteHealth(humanoid)
    -- Set initial health values
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    -- Health change listener
    humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < humanoid.MaxHealth then
            humanoid.Health = math.huge
        end
    end)

    -- Periodic maintenance for MaxHealth
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if humanoid and humanoid.Parent then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        else
            connection:Disconnect() -- Cleanup if humanoid is removed
        end
    end)
end

local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    maintainInfiniteHealth(humanoid)
end

-- Handle initial character and respawns
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end
