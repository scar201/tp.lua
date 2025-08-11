-- Admin Script for Solara - Bring Players & Spawn Cars
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Car Models (you can change these IDs to any car you want)
local carIds = {
    "rbxassetid://1234567890", -- Replace with actual car model IDs
    "rbxassetid://9876543210", -- You can add more car IDs here
}

-- Function to bring all players (Server-side compatible)
local function bringAllPlayers()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Your character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local brought = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Try to teleport via RemoteEvent first (if exists)
            pcall(function()
                local remotes = ReplicatedStorage:GetChildren()
                for _, remote in pairs(remotes) do
                    if remote:IsA("RemoteEvent") and (remote.Name:lower():find("teleport") or remote.Name:lower():find("tp")) then
                        remote:FireServer(player, myPos)
                    end
                end
            end)
            
            -- Direct teleport as backup
            pcall(function()
                local offset = Vector3.new(
                    math.random(-8, 8),
                    2,
                    math.random(-8, 8)
                )
                player.Character.HumanoidRootPart.CFrame = CFrame.new(myPos + offset)
            end)
            
            brought = brought + 1
        end
    end
    
    print("✅ Brought " .. brought .. " players!")
    
    -- Notify all players
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Admin Action";
            Text = "All players brought together!";
            Duration = 3;
        })
    end)
end

-- Function to spawn cars
local function spawnCars()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Your character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local spawned = 0
    
    -- Try to find existing cars in workspace to clone
    local existingCars = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:lower():find("car") or obj.Name:lower():find("vehicle") or obj:FindFirstChild("VehicleSeat")) then
            table.insert(existingCars, obj)
        end
    end
    
    -- Spawn cars around the player
    for i = 1, 5 do -- Spawn 5 cars
        local carToSpawn = nil
        
        if #existingCars > 0 then
            -- Clone existing car
            carToSpawn = existingCars[math.random(1, #existingCars)]:Clone()
        else
            -- Create a simple car if none found
            carToSpawn = Instance.new("Model")
            carToSpawn.Name = "SpawnedCar"
            
            local body = Instance.new("Part")
            body.Name = "Body"
            body.Size = Vector3.new(8, 2, 16)
            body.Material = Enum.Material.Metal
            body.BrickColor = BrickColor.Random()
            body.Parent = carToSpawn
            
            local seat = Instance.new("VehicleSeat")
            seat.Size = Vector3.new(2, 1, 2)
            seat.Position = body.Position + Vector3.new(0, 1.5, 0)
            seat.Parent = carToSpawn
            
            -- Add wheels
            for j = 1, 4 do
                local wheel = Instance.new("Part")
                wheel.Name = "Wheel" .. j
                wheel.Shape = Enum.PartType.Cylinder
                wheel.Size = Vector3.new(1, 3, 3)
                wheel.Material = Enum.Material.Rubber
                wheel.BrickColor = BrickColor.new("Really black")
                wheel.Parent = carToSpawn
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = body
                weld.Part1 = wheel
                weld.Parent = body
            end
        end
        
        if carToSpawn then
            -- Position car around player
            local angle = (i - 1) * (360 / 5) * math.pi / 180
            local spawnPos = myPos + Vector3.new(
                math.cos(angle) * 15,
                5,
                math.sin(angle) * 15
            )
            
            carToSpawn:SetPrimaryPartCFrame(CFrame.new(spawnPos))
            carToSpawn.Parent = Workspace
            spawned = spawned + 1
        end
    end
    
    print("✅ Spawned " .. spawned .. " cars!")
    
    -- Notify all players
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Admin Action";
            Text = spawned .. " cars spawned!";
            Duration = 3;
        })
    end)
end

-- Key bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.B then
        bringAllPlayers()
    elseif input.KeyCode == Enum.KeyCode.Z then
        spawnCars()
    end
end)

-- Success messages
print("🎯 Admin Script Loaded Successfully!")
print("📍 Press B to bring all players")
print("🚗 Press Z to spawn cars")
print("⚡ Script ready for use!")

-- Show notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Admin Script Ready!";
        Text = "B = Bring Players | Z = Spawn Cars";
        Duration = 5;
    })
end)
