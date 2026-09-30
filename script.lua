if game.PlaceId == 10449761463 or game.Workspace:FindFirstChild("Live") then -- Hoặc check theo tên game tùy ý

    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "catHub | tsb version beta test v0.1",
        LoadingTitle = "Snowy Hub Interface",
        LoadingSubtitle = "by cat & ✧",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "cat-hub",
            FileName = "Config"
        },
        Discord = {
            Enabled = true,
            Invite = "cat",
            RememberJoins = true
        },
        KeySystem = false,
    })

    local TSBTab = Window:CreateTab("TSB Auto Farm", 4483362458)

    local FarmSection = TSBTab:CreateSection("Auto Kill Farm Settings")
    local StatsSection = TSBTab:CreateSection("Live Statistics")
    local AxisSection = TSBTab:CreateSection("Position Offset Adjustments")


    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local lp = Players.LocalPlayer
    local isMobile = UIS.TouchEnabled

    local autoFarmEnabled = false
    local autoUltimateEnabled = false
    local autoEmoteEnabled = false
    local antiStuckEnabled = true
    local currentTarget = nil
    local farmConnection = nil
    local attackThread = nil

    local farmOffsetX, farmOffsetY, farmOffsetZ = 0, 0, 3.5


    local startTime = tick()
    local startKills = 0
    local leaderstats = lp:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Kills") then 
        startKills = leaderstats.Kills.Value 
    end

    local KPM_Label = StatsSection:CreateLabel("Kills Per Minute: 0.00")
    local Target_Label = StatsSection:CreateLabel("Current Target: None")

    task.spawn(function()
        while task.wait(1) do
            local currentKills = (leaderstats and leaderstats:FindFirstChild("Kills") and leaderstats.Kills.Value) or 0
            local elapsed = (tick() - startTime) / 60
            local kpm = (currentKills - startKills) / math.max(0.01, elapsed)
            KPM_Label:Set(string.format("Kills Per Minute: %.2f", kpm))
        end
    end)

    local function comm(args)
        local char = lp.Character
        if char and char:FindFirstChild("Communicate") then
            pcall(function() char.Communicate:FireServer(unpack(args)) end)
        end
    end

    local function getChar(plr)
        local live = workspace:FindFirstChild("Live")
        return (live and live:FindFirstChild(plr.Name)) or plr.Character
    end

    local function isAlive(plr)
        local c = getChar(plr)
        local h = c and c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end

    local function getTarget()
        local low, best = math.huge, nil
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and isAlive(p) then
                local char = getChar(p)
                local tHrp = char and char:FindFirstChild("HumanoidRootPart")
                local h = char.Humanoid.Health
                
                if tHrp and myHrp then
                    if h < low then 
                        low = h
                        best = p 
                    end
                end
            end
        end
        return best
    end

    local function fireHotbar()
        pcall(function()
            local hotbar = lp.PlayerGui:FindFirstChild("Hotbar")
            local backpack = hotbar and hotbar:FindFirstChild("Backpack")
            local hb = backpack and backpack:FindFirstChild("Hotbar")
            if not hb then return end

            local events = {"MouseButton1Click", "MouseButton1Down", "MouseButton1Up", "Activated"}

            for i = 1, 4 do
                local slot = hb:FindFirstChild(tostring(i))
                local btn = slot and slot:FindFirstChild("Base")
                if btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                    for _, eventName in ipairs(events) do
                        if firesignal then
                            firesignal(btn[eventName])
                        elseif getconnections then
                            for _, connection in pairs(getconnections(btn[eventName])) do
                                if connection.Fire then connection:Fire() end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function stopFarm()
        if farmConnection then farmConnection:Disconnect(); farmConnection = nil end
        if attackThread then task.cancel(attackThread); attackThread = nil end
        currentTarget = nil
        Target_Label:Set("Current Target: None")
    end

    local function startFarm()
        stopFarm()
        
        farmConnection = RunService.Heartbeat:Connect(function()
            if not autoFarmEnabled then return end
            
            if not currentTarget or not isAlive(currentTarget) then 
                currentTarget = getTarget() 
                if currentTarget then
                    Target_Label:Set("Current Target: " .. currentTarget.Name)
                end
            end
            
            if currentTarget then
                local tChar = getChar(currentTarget)
                local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                
                if tHrp and myHrp then
                    myHrp.CFrame = tHrp.CFrame * CFrame.new(farmOffsetX, farmOffsetY, farmOffsetZ)
                    
                    if antiStuckEnabled and myHrp.AssemblyLinearVelocity.Magnitude > 100 then
                        myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)

        attackThread = task.spawn(function()
            while autoFarmEnabled do
                if currentTarget and isAlive(currentTarget) then
                    comm(isMobile and {{Goal = "LeftClick", Mobile = true}} or {{Goal = "LeftClick"}})
                    comm({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}})
                    
                    if autoUltimateEnabled then 
                        comm({{MoveDirection = Vector3.zero, Key = Enum.KeyCode.G, Goal = "KeyPress"}}) 
                    end
                    if autoEmoteEnabled then 
                        comm({{Goal = "Emote Spin"}}) 
                    end
                    
                    fireHotbar()
                end
                task.wait(0.08)
            end
        end)
    end


    FarmSection:CreateToggle({
        Name = "Auto Kill Farm (Lowest HP)",
        CurrentValue = false,
        Flag = "AutoFarmToggle",
        Callback = function(v)
            autoFarmEnabled = v
            if v then 
                startFarm() 
                Rayfield:Notify({Title = "Auto Farm", Content = "Đã bật hệ thống săn mục tiêu!", Duration = 3})
            else 
                stopFarm() 
                Rayfield:Notify({Title = "Auto Farm", Content = "Đã tắt hệ thống săn mục tiêu.", Duration = 3})
            end
        end,
    })

    FarmSection:CreateToggle({
        Name = "Auto Ultimate",
        CurrentValue = false,
        Flag = "AutoUltToggle",
        Callback = function(v)
            autoUltimateEnabled = v 
        end,
    })

    FarmSection:CreateToggle({
        Name = "Auto Claim Emote (Spin)",
        CurrentValue = false,
        Flag = "AutoEmoteToggle",
        Callback = function(v)
            autoEmoteEnabled = v 
        end,
    })

    FarmSection:CreateToggle({
        Name = "Anti-Stuck Protection",
        CurrentValue = true,
        Flag = "AntiStuckToggle",
        Callback = function(v)
            antiStuckEnabled = v
        end,
    })

    AxisSection:CreateSlider({
        Name = "Offset X (Ngang)",
        Range = {-15, 15},
        Increment = 1,
        Suffix = "Studs",
        CurrentValue = 0,
        Flag = "OffsetX",
        Callback = function(v)
            farmOffsetX = v
        end,
    })

    AxisSection:CreateSlider({
        Name = "Offset Y (Dọc)",
        Range = {-15, 15},
        Increment = 1,
        Suffix = "Studs",
        CurrentValue = 0,
        Flag = "OffsetY",
        Callback = function(v)
            farmOffsetY = v
        end,
    })

    AxisSection:CreateSlider({
        Name = "Offset Z (Trước/Sau)",
        Range = {-15, 15},
        Increment = 1,
        Suffix = "Studs",
        CurrentValue = 3.5,
        Flag = "OffsetZ",
        Callback = function(v)
            farmOffsetZ = v
        end,
    })
    
    Rayfield:LoadConfiguration()
end