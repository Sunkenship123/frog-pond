-- v4

if getgenv().FrogPondFarmFull then return end
getgenv().FrogPondFarmFull = true

print("My Frog Pond Full Script v3.0 loading...")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ================= CONFIG - CHANGE THESE AFTER USING REMOTE SPY =================
local REMOTES_FOLDER = RS:FindFirstChild("Remotes") or RS

local BUY_REMOTE     = REMOTES_FOLDER:FindFirstChild("PurchaseTadpole") 
                    or REMOTES_FOLDER:FindFirstChild("BuyTadpole")
local SELL_REMOTE    = REMOTES_FOLDER:FindFirstChild("SellFrog")
local BREED_REMOTE   = REMOTES_FOLDER:FindFirstChild("Breed") 
                    or REMOTES_FOLDER:FindFirstChild("BreedFrogs")

local POND_FOLDER    = workspace:FindFirstChild("Ponds") 
                    and workspace.Ponds:FindFirstChild(lp.Name)
                    or workspace:FindFirstChild(lp.Name .. "Pond")

local TADPOLE_TYPE   = "Basic"      -- usually "Basic", "Common", etc.
local BUY_AMOUNT     = 5
local MAX_FROGS      = 35
local MIN_FOR_BREED  = 2

-- Toggles (controlled by UI)
getgenv().toggles = {
    AutoBuy     = false,
    AutoSell    = false,
    AutoBreed   = false,
    AutoCollect = false,
    Noclip      = false,
    Speed       = 50
}

-- Anti-kick (very basic)
hookfunction(lp.Kick, function(self, reason)
    warn("Kick attempt blocked! Reason: " .. tostring(reason))
end)

-- Noclip handler
local noclipConnection
local function toggleNoclip(state)
    if state then
        if not noclipConnection then
            noclipConnection = Run.Stepped:Connect(function()
                if lp.Character then
                    for _, part in pairs(lp.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- ================= MAIN FARMING LOOP =================
spawn(function()
    while getgenv().FrogPondFarmFull do
        task.wait(0.25)
        
        -- Update speed & noclip every tick
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = getgenv().toggles.Speed
        end
        
        toggleNoclip(getgenv().toggles.Noclip)
        
        -- Auto Buy Tadpoles
        if getgenv().toggles.AutoBuy and BUY_REMOTE then
            pcall(function()
                BUY_REMOTE:FireServer(TADPOLE_TYPE, BUY_AMOUNT)
            end)
            task.wait(0.8) -- prevent rate limit
        end
        
        -- Auto Sell Frogs
        if getgenv().toggles.AutoSell and SELL_REMOTE and POND_FOLDER then
            for _, obj in pairs(POND_FOLDER:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("frog") then
                    pcall(function()
                        SELL_REMOTE:FireServer(obj)
                    end)
                    task.wait(0.12)
                end
            end
        end
        
        -- Auto Breed
        if getgenv().toggles.AutoBreed and BREED_REMOTE and POND_FOLDER then
            local frogs = {}
            for _, obj in pairs(POND_FOLDER:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("frog") then
                    table.insert(frogs, obj)
                end
            end
            
            if #frogs >= MIN_FOR_BREED then
                pcall(function()
                    BREED_REMOTE:FireServer(frogs[1], frogs[2])
                    print("Bred frogs:", frogs[1].Name, "x", frogs[2].Name)
                end)
                task.wait(1.5)
            end
            
            -- Sell excess if too many
            if #frogs > MAX_FROGS and SELL_REMOTE then
                pcall(function()
                    SELL_REMOTE:FireServer(frogs[1])
                end)
                print("Sold excess frog for space")
            end
        end
        
        -- Auto Collect Ribbles / Coins
        if getgenv().toggles.AutoCollect then
            for _, item in pairs(workspace:GetChildren()) do
                if (item.Name:find("Ribble") or item.Name:find("Coin") or item.Name:find("Drop")) 
                    and item:IsA("BasePart") then
                    if lp.Character and lp.Character.PrimaryPart then
                        lp.Character.PrimaryPart.CFrame = item.CFrame + Vector3.new(0, 4, 0)
                        task.wait(0.07)
                    end
                end
            end
        end
    end
end)

-- ================= UI - Auto Opens =================
local function createUI()
    print("[UI] Creating interface...")
    
    -- Remove old UI if exists
    pcall(function()
        if game.CoreGui:FindFirstChild("FrogFarmUI") then 
            game.CoreGui.FrogFarmUI:Destroy() 
        end
        if lp.PlayerGui:FindFirstChild("FrogFarmUI") then 
            lp.PlayerGui.FrogFarmUI:Destroy() 
        end
    end)
    
    local parent = gethui and gethui() or game.CoreGui or lp:WaitForChild("PlayerGui")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "FrogFarmUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = parent
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 260, 0, 420)
    frame.Position = UDim2.new(0.5, -130, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.ZIndex = 999
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    title.Text = "🐸 My Frog Pond Farm v3.0"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.ZIndex = 1000
    
    local y = 60
    local function toggleButton(name)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, -20, 0, 42)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = name .. ": OFF"
        btn.TextSize = 18
        btn.ZIndex = 1000
        
        btn.MouseButton1Click:Connect(function()
            getgenv().toggles[name] = not getgenv().toggles[name]
            btn.Text = name .. ": " .. (getgenv().toggles[name] and "ON" or "OFF")
            btn.BackgroundColor3 = getgenv().toggles[name] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 60)
            
            if name == "Noclip" then
                toggleNoclip(getgenv().toggles[name])
            end
        end)
        
        y = y + 48
        return btn
    end
    
    toggleButton("AutoBuy")
    toggleButton("AutoSell")
    toggleButton("AutoBreed")
    toggleButton("AutoCollect")
    toggleButton("Noclip")
    
    -- Speed input
    local speedBox = Instance.new("TextBox", frame)
    speedBox.Size = UDim2.new(1, -20, 0, 42)
    speedBox.Position = UDim2.new(0, 10, 0, y)
    speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    speedBox.TextColor3 = Color3.new(1,1,1)
    speedBox.Text = "Speed: 50"
    speedBox.TextSize = 18
    speedBox.ZIndex = 1000
    
    speedBox.FocusLost:Connect(function()
        local num = tonumber(speedBox.Text:match("%d+"))
        if num then
            getgenv().toggles.Speed = num
            print("Speed set to " .. num)
        end
    end)
    
    y = y + 48
    
    -- Close button
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(1, 0, 0, 50)
    close.Position = UDim2.new(0, 0, 1, -50)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "Close UI"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextSize = 20
    close.ZIndex = 1000
    
    close.MouseButton1Click:Connect(function()
        sg:Destroy()
        print("UI closed")
    end)
    
    print("[UI] Interface created - should be visible now")
end

getgenv().openFrogUI = createUI

-- Auto open UI after delay
spawn(function()
    task.wait(3)
    createUI()
    print("Auto-opened UI! Toggle features in the window.")
end)

print("Script loaded. UI opening in 3 seconds...")
print("Remember to update remote names using Remote Spy!")
