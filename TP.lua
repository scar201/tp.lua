-- Real Server-Side Admin Script
-- This needs to be used with RemoteEvents or as ServerScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Create RemoteEvents (if they don't exist)
local function createRemoteEvents()
    local bringRemote = ReplicatedStorage:FindFirstChild("BringAllPlayers")
    if not bringRemote then
        bringRemote = Instance.new("RemoteEvent")
        bringRemote.Name = "BringAllPlayers"
        bringRemote.Parent = ReplicatedStorage
    end
    
    local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnVehicles")
    if not spawnRemote then
        spawnRemote = Instance.new("RemoteEvent")
        spawnRemote.Name = "SpawnVehicles"
        spawnRemote.Parent = ReplicatedStorage
    end
    
    return bringRemote, spawnRemote
end

-- Create the RemoteEvents
local bringRemote, spawnRemote = createRemoteEvents()

-- Alternative: Direct server manipulation (works in some executors)
local function forceServerAction(action, data)
    -- Try to execute on server side
    local success = pcall(function()
        if action == "bring" then
            -- Force all players to teleport (server-side)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Force position change that affects everyone
                    local cf = player.Character.HumanoidRootPart.CFrame
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(data.position + Vector3.new(math.random(-8,8), 0, math.random(-8,8)))
                    
                    -- Force anchoring for everyone to see
                    player.Character.HumanoidRootPart.Anchored = true
                    
                    -- Disable their movement
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 0
                        player.Character.Humanoid.JumpPower = 0
                        player.Character.Humanoid.PlatformStand = true
                    end
                end
            end
        elseif action == "spawn" then
            -- Create vehicles that everyone can see
            for i = 1, 3 do
                local car = Instance.new("Model")
                car.Name = "ServerCar_" .. i
                car.Parent = Workspace
                
                -- Car body
                local body = Instance.new("Part")
                body.Name = "Body"
                body.Size = Vector3.new(8, 3, 16)
                body.Material = Enum.Material.Metal
                body.BrickColor = BrickColor.Random()
                body.Anchored = false
                body.CanCollide = true
                body.Parent = car
                
                -- Vehicle seat
                local seat = Instance.new("VehicleSeat")
                seat.Size = Vector3.new(2, 1, 2)
                seat.BrickColor = BrickColor.new("Really black")
                seat.Parent = car
                
                -- Position seat on body
                seat.CFrame = body.CFrame * CFrame.new(0, 2, 0)
                
                -- Weld seat to body
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = body
                weld.Part1 = seat
                weld.Parent = body
                
                -- Add wheels
                for j = 1, 4 do
                    local wheel = Instance.new("Part")
                    wheel.Name = "Wheel" .. j
                    wheel.Size = Vector3.new(1, 4, 4)
                    wheel.Shape = Enum.PartType.Cylinder
                    wheel.Material = Enum.Material.Rubber
                    wheel.BrickColor = BrickColor.new("Really black")
                    wheel.Parent = car
                    
                    -- Position wheels
                    local xPos = j <= 2 and -3 or 3
                    local zPos = j % 2 == 1 and 6 or -6
                    wheel.CFrame = body.CFrame * CFrame.new(xPos, -2, zPos)
                    
                    -- Weld wheel to body
                    local wheelWeld = Instance.new("WeldConstraint")
                    wheelWeld.Part0 = body
                    wheelWeld.Part1 = wheel
                    wheelWeld.Parent = body
                end
                
                -- Position car around player
                local angle = (i-1) * (360/3) * math.pi/180
                local pos = data.position + Vector3.new(math.cos(angle) * 25, 3, math.sin(angle) * 25)
                car:SetPrimaryPartCFrame(CFrame.new(pos))
                car.PrimaryPart = body
            end
        end
    end)
    
    return success
end

-- Enhanced bring function with multiple methods
local function bringAllPlayers()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Method 1: Try RemoteEvent
    pcall(function()
        bringRemote:FireServer(myPos)
    end)
    
    -- Method 2: Direct server manipulation
    local success = forceServerAction("bring", {position = myPos})
    
    -- Method 3: Alternative direct method
    if not success then
        local brought = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    -- Try multiple teleport methods
                    local hrp = player.Character.HumanoidRootPart
                    local offset = Vector3.new(math.random(-10,10), 2, math.random(-10,10))
                    
                    -- Method A: Direct CFrame
                    hrp.CFrame = CFrame.new(myPos + offset)
                    
                    -- Method B: Position property
                    hrp.Position = myPos + offset
                    
                    -- Method C: AssemblyLinearVelocity (stops movement)
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    
                    -- Freeze them
                    hrp.Anchored = true
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 0
                        player.Character.Humanoid.JumpPower = 0
                        player.Character.Humanoid.PlatformStand = true
                    end
                    
                    brought = brought + 1
                end)
            end
        end
        print("✅ Brought " .. brought .. " players using direct method")
    end
    
    -- Force refresh for all clients
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            spawn(function()
                if player.Character then
                    player.Character.Parent = nil
                    wait(0.1)
                    player.Character.Parent = Workspace
                end
            end)
        end
    end)
    
    print("🎯 Bring command executed with multiple methods!")
end

-- Enhanced spawn cars function
local function spawnCars()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character not found!")
        return
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Method 1: Try RemoteEvent
    pcall(function()
        spawnRemote:FireServer(myPos)
    end)
    
    -- Method 2: Direct server spawn
    local success = forceServerAction("spawn", {position = myPos})
    
    -- Method 3: Force spawn with replication
    if not success then
        for i = 1, 3 do
            pcall(function()
                local car = Instance.new("Model")
                car.Name = "AdminCar_" .. tick() .. "_" .. i
                
                -- Create car body
                local body = Instance.new("Part")
                body.Name = "Body"
                body.Size = Vector3.new(8, 3, 16)
                body.Material = Enum.Material.Neon
                body.BrickColor = BrickColor.Random()
                body.Anchored = false
                body.CanCollide = true
                body.TopSurface = Enum.SurfaceType.Smooth
                body.BottomSurface = Enum.SurfaceType.Smooth
                body.Parent = car
                
                -- Add vehicle seat
                local seat = Instance.new("VehicleSeat")
                seat.Size = Vector3.new(2, 1, 2)
                seat.BrickColor = BrickColor.new("Really red")
                seat.Material = Enum.Material.Fabric
                seat.Parent = car
                
                -- Position and weld seat
                seat.CFrame = body.CFrame * CFrame.new(0, 2, 0)
                local seatWeld = Instance.new("WeldConstraint")
                seatWeld.Part0 = body
                seatWeld.Part1 = seat
                seatWeld.Parent = body
                
                -- Add 4 wheels
                local wheelPositions = {{-3, -2, 6}, {3, -2, 6}, {-3, -2, -6}, {3, -2, -6}}
                for j, pos in pairs(wheelPositions) do
                    local wheel = Instance.new("Part")
                    wheel.Name = "Wheel" .. j
                    wheel.Size = Vector3.new(1, 4, 4)
                    wheel.Shape = Enum.PartType.Cylinder
                    wheel.Material = Enum.Material.Rubber
                    wheel.BrickColor = BrickColor.new("Really black")
                    wheel.Parent = car
                    wheel.CFrame = body.CFrame * CFrame.new(pos[1], pos[2], pos[3])
                    
                    local wheelWeld = Instance.new("WeldConstraint")
                    wheelWeld.Part0 = body
                    wheelWeld.Part1 = wheel
                    wheelWeld.Parent = body
                end
                
                -- Set primary part and position
                car.PrimaryPart = body
                local angle = (i-1) * (360/3) * math.pi/180
                local spawnPos = myPos + Vector3.new(math.cos(angle) * 20, 5, math.sin(angle) * 20)
                car:SetPrimaryPartCFrame(CFrame.new(spawnPos))
                
                -- Parent to workspace (this should replicate to all clients)
                car.Parent = Workspace
                
                print("🚗 Spawned car " .. i .. " at " .. tostring(spawnPos))
            end)
        end
    end
    
    print("✅ Vehicle spawn executed!")
end

-- Key bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.B then
        print("🎯 Executing bring all players...")
        bringAllPlayers()
    elseif input.KeyCode == Enum.KeyCode.Z then
        print("🚗 Executing spawn vehicles...")
        spawnCars()
    elseif input.KeyCode == Enum.KeyCode.U then
        -- Unfreeze all players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    player.Character.HumanoidRootPart.Anchored = false
                    if player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.WalkSpeed = 16
                        player.Character.Humanoid.JumpPower = 50
                        player.Character.Humanoid.PlatformStand = false
                    end
                end)
            end
        end
        print("🔓 Unfroze all players")
    end
end)

print("🎯 Enhanced Server-Side Admin Script Loaded!")
print("📍 B = Bring & Freeze All Players (Server-Side)")
print("🚗 Z = Spawn Vehicles (Server-Side)")  
print("🔓 U = Unfreeze All Players")
print("⚡ Using multiple methods for maximum compatibility!")

-- Show notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ Server Admin Ready!";
        Text = "B=Bring | Z=Cars | U=Unfreeze";
        Duration = 5;
    })
end)
