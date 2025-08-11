-- Enhanced Admin Script for Solara - Real Server Actions
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Store original positions and freeze states
local originalPositions = {}
local frozenPlayers = {}
local bringConnection = nil

-- Function to freeze/unfreeze player
local function freezePlayer(player, freeze)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        
        if freeze then
            -- Store original position
            originalPositions[player.UserId] = humanoidRootPart.CFrame
            
            -- Freeze player
            humanoidRootPart.Anchored = true
            frozenPlayers[player.UserId] = true
            
            -- Disable movement
            if player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 0
                player.Character.Humanoid.JumpPower = 0
            end
        else
            -- Unfreeze player
            humanoidRootPart.Anchored = false
            frozenPlayers[player.UserId] = nil
            
            -- Enable movement
            if player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
                player.Character.Humanoid.JumpPower = 50
            end
        end
    end
end

-- Function to bring all players with server-side effects
local function bringAllPlayers()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Your character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local brought = 0
    
    -- Disconnect previous connection if exists
    if bringConnection then
        bringConnection:Disconnect()
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            
            -- Calculate position around the admin
            local angle = brought * (360 / math.max(#Players:GetPlayers() - 1, 1)) * math.pi / 180
            local offset = Vector3.new(
                math.cos(angle) * 8,
                2,
                math.sin(angle) * 8
            )
            local newPos = myPos + offset
            
            -- Teleport player
            player.Character.HumanoidRootPart.CFrame = CFrame.new(newPos)
            
            -- Freeze player in place
            freezePlayer(player, true)
            
            brought = brought + 1
            
            -- Send notification to the brought player
            pcall(function()
                local remoteEvent = Instance.new("RemoteEvent")
                remoteEvent.Name = "AdminNotify"
                remoteEvent.Parent = ReplicatedStorage
                remoteEvent:FireClient(player, "You have been brought to admin!")
            end)
        end
    end
    
    print("✅ Brought and froze " .. brought .. " players!")
    
    -- Create server-wide notification
    for _, player in pairs(Players:GetPlayers()) do
        pcall(function()
            player.PlayerGui.ChildAdded:Connect(function(child)
                if child:IsA("ScreenGui") then
                    wait(0.1)
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "⚡ Admin Action";
                        Text = "All players brought together and frozen!";
                        Duration = 4;
                    })
                end
            end)
        end)
    end
    
    -- Keep players frozen with continuous monitoring
    bringConnection = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if frozenPlayers[player.UserId] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = player.Character.HumanoidRootPart
                if originalPositions[player.UserId] then
                    humanoidRootPart.CFrame = originalPositions[player.UserId]
                    humanoidRootPart.Anchored = true
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 0
                        player.Character.Humanoid.JumpPower = 0
                    end
                end
            end
        end
    end)
end

-- Function to unfreeze all players
local function unfreezeAllPlayers()
    if bringConnection then
        bringConnection:Disconnect()
        bringConnection = nil
    end
    
    local unfrozen = 0
    for _, player in pairs(Players:GetPlayers()) do
        if frozenPlayers[player.UserId] then
            freezePlayer(player, false)
            unfrozen = unfrozen + 1
        end
    end
    
    -- Clear stored data
    originalPositions = {}
    frozenPlayers = {}
    
    print("✅ Unfroze " .. unfrozen .. " players!")
    
    -- Notify all players
    for _, player in pairs(Players:GetPlayers()) do
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚡ Admin Action";
                Text = "All players have been unfrozen!";
                Duration = 3;
            })
        end)
    end
end

-- Enhanced car spawning with real server-side cars
local function spawnCars()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Your character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local spawned = 0
    
    -- Look for existing vehicles in the game
    local existingVehicles = {}
    
    -- Search in workspace for any vehicles
    local function findVehicles(parent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("Model") then
                -- Check if it's a vehicle
                if obj:FindFirstChild("VehicleSeat") or 
                   obj:FindFirstChild("Seat") or 
                   obj.Name:lower():find("car") or 
                   obj.Name:lower():find("vehicle") or
                   obj.Name:lower():find("truck") or
                   obj.Name:lower():find("bike") then
                    table.insert(existingVehicles, obj)
                end
                findVehicles(obj) -- Search recursively
            end
        end
    end
    
    findVehicles(Workspace)
    
    -- Spawn vehicles
    for i = 1, 3 do -- Spawn 3 vehicles
        local vehicleToSpawn = nil
        
        if #existingVehicles > 0 then
            -- Clone random existing vehicle
            local randomVehicle = existingVehicles[math.random(1, #existingVehicles)]
            vehicleToSpawn = randomVehicle:Clone()
            vehicleToSpawn.Name = "AdminSpawned_" .. randomVehicle.Name
        else
            -- Create a basic functional car
            vehicleToSpawn = Instance.new("Model")
            vehicleToSpawn.Name = "AdminCar_" .. i
            
            -- Car body
            local body = Instance.new("Part")
            body.Name = "Body"
            body.Size = Vector3.new(6, 3, 12)
            body.Material = Enum.Material.Metal
            body.BrickColor = BrickColor.Random()
            body.Shape = Enum.PartType.Block
            body.TopSurface = Enum.SurfaceType.Smooth
            body.BottomSurface = Enum.SurfaceType.Smooth
            body.Parent = vehicleToSpawn
            
            -- Driver seat
            local seat = Instance.new("VehicleSeat")
            seat.Name = "VehicleSeat"
            seat.Size = Vector3.new(2, 1, 2)
            seat.Material = Enum.Material.Fabric
            seat.BrickColor = BrickColor.new("Really black")
            seat.Parent = vehicleToSpawn
            
            -- Position seat on top of body
            local weld1 = Instance.new("WeldConstraint")
            weld1.Part0 = body
            weld1.Part1 = seat
            weld1.Parent = body
            seat.CFrame = body.CFrame * CFrame.new(0, 2, 0)
            
            -- Create wheels
            local wheelPositions = {
                {-2.5, -1.5, 4},   -- Front left
                {2.5, -1.5, 4},    -- Front right
                {-2.5, -1.5, -4},  -- Back left
                {2.5, -1.5, -4}    -- Back right
            }
            
            for j, pos in pairs(wheelPositions) do
                local wheel = Instance.new("Part")
                wheel.Name = "Wheel" .. j
                wheel.Size = Vector3.new(1, 3, 3)
                wheel.Shape = Enum.PartType.Cylinder
                wheel.Material = Enum.Material.Rubber
                wheel.BrickColor = BrickColor.new("Really black")
                wheel.Parent = vehicleToSpawn
                
                -- Position wheel
                wheel.CFrame = body.CFrame * CFrame.new(pos[1], pos[2], pos[3])
                
                -- Weld wheel to body
                local wheelWeld = Instance.new("WeldConstraint")
                wheelWeld.Part0 = body
                wheelWeld.Part1 = wheel
                wheelWeld.Parent = body
            end
            
            -- Set primary part for easier positioning
            vehicleToSpawn.PrimaryPart = body
        end
        
        if vehicleToSpawn then
            -- Position vehicle around player
            local angle = (i - 1) * (360 / 3) * math.pi / 180
            local spawnPos = myPos + Vector3.new(
                math.cos(angle) * 20,
                5,
                math.sin(angle) * 20
            )
            
            -- Set position
            if vehicleToSpawn.PrimaryPart then
                vehicleToSpawn:SetPrimaryPartCFrame(CFrame.new(spawnPos))
            elseif vehicleToSpawn:FindFirstChild("Body") then
                vehicleToSpawn.Body.CFrame = CFrame.new(spawnPos)
            end
            
            vehicleToSpawn.Parent = Workspace
            spawned = spawned + 1
            
            print("🚗 Spawned: " .. vehicleToSpawn.Name)
        end
    end
    
    print("✅ Successfully spawned " .. spawned .. " vehicles!")
    
    -- Notify all players with server broadcast
    for _, player in pairs(Players:GetPlayers()) do
        spawn(function()
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🚗 Vehicles Spawned";
                    Text = spawned .. " vehicles available!";
                    Duration = 4;
                })
            end)
        end)
    end
end

-- Key bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.B then
        bringAllPlayers()
    elseif input.KeyCode == Enum.KeyCode.Z then
        spawnCars()
    elseif input.KeyCode == Enum.KeyCode.U then -- U to unfreeze
        unfreezeAllPlayers()
    end
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
    if originalPositions[player.UserId] then
        originalPositions[player.UserId] = nil
    end
    if frozenPlayers[player.UserId] then
        frozenPlayers[player.UserId] = nil
    end
end)

-- Success messages
print("🎯 Enhanced Admin Script Loaded!")
print("📍 Press B to bring & freeze all players")
print("🔓 Press U to unfreeze all players") 
print("🚗 Press Z to spawn real vehicles")
print("⚡ All actions are server-wide and visible to everyone!")

-- Initial notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ Enhanced Admin Ready!";
        Text = "B=Bring+Freeze | U=Unfreeze | Z=Spawn Cars";
        Duration = 6;
    })
end)
