-- Bring All Players Script - Solara
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Function to bring all players to you
local function bringAll()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Your character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local brought = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport player to you with random offset
            local offset = Vector3.new(
                math.random(-5, 5),
                2,
                math.random(-5, 5)
            )
            
            player.Character.HumanoidRootPart.CFrame = CFrame.new(myPos + offset)
            brought = brought + 1
        end
    end
    
    print("✅ Brought " .. brought .. " players to you!")
end

-- Press B to bring all players
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
        bringAll()
    end
end)

print("🎯 Bring All Players Loaded!")
print("📍 Press B to bring all players to you")