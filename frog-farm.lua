-- My Frog Pond Auto-Farm v2.1 (January 2026 - Delta Executor)
-- For YOUR OWN game testing only - DO NOT use in public games!
-- Features: Auto Buy • Auto Sell • Auto Breed • Auto Collect • Speed/Noclip • Nice UI

if getgenv().FrogPondFarm then return end
getgenv().FrogPondFarm = true

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ================= CONFIG - YOU MUST UPDATE THESE FROM REMOTE SPY =================
local REMOTES = RS:WaitForChild("Remotes") -- change if different

local BUY_REMOTE     = REMOTES:FindFirstChild("PurchaseTadpole") or REMOTES:FindFirstChild("BuyTadpole")
local SELL_REMOTE    = REMOTES:FindFirstChild("SellFrog")
local BREED_REMOTE   = REMOTES:FindFirstChild("Breed") or REMOTES:FindFirstChild("BreedFrogs")

local POND           = workspace:FindFirstChild("Ponds") 
                    and workspace.Ponds:FindFirstChild(lp.Name)
                    or workspace:FindFirstChild(lp.Name .. "Pond")

local TADPOLE_TYPE   = "Basic"    -- ← from spy (usually string)
local BUY_COUNT      = 5
local MAX_FROGS      = 35
local MIN_FOR_BREED  = 2
-- ================================================================================

-- Toggles
getgenv().toggles = {
    AutoBuy     = false,
    AutoSell    = false,
    AutoBreed   = false,
    AutoCollect = false,
    Noclip      = false,
    Speed       = 50
}

-- Anti-kick
hookfunction(lp.Kick, function() warn("Kick blocked lol") end)

-- Noclip connection
local noclip
local function updateNoclip()
    if getgenv().toggles.Noclip then
        if not noclip then
            noclip = Run.Stepped:Connect(function()
                if lp.Character then
                    for _, p in pairs(lp.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclip then noclip:Disconnect(); noclip = nil end
    end
end

-- Main farming loop
spawn(function()
    while getgenv().FrogPondFarm do
        task.wait(0.25)

        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = getgenv().toggles.Speed end
        end

        updateNoclip()

        if POND and BREED_REMOTE and getgenv().toggles.AutoBreed then
            local frogs = {}
            for _, v in pairs(POND:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("frog") then
                    table.insert(frogs, v)
                end
            end

            -- Breed if possible
            if #frogs >= MIN_FOR_BREED then
                pcall(function()
                    BREED_REMOTE:FireServer(frogs[1], frogs[2]) -- ← adjust args from spy!
                end)
            end

            -- Manage space
            if #frogs > MAX_FROGS and SELL_REMOTE then
                pcall(function() SELL_REMOTE:FireServer(frogs[1]) end)
            end
        end

        if getgenv().toggles.AutoBuy and BUY_REMOTE then
            pcall(function()
                BUY_REMOTE:FireServer(TADPOLE_TYPE, BUY_COUNT)
            end)
        end

        if getgenv().toggles.AutoSell and SELL_REMOTE and POND then
            for _, v in pairs(POND:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("frog") then
                    pcall(function() SELL_REMOTE:FireServer(v) end)
                    task.wait(0.12)
                end
            end
        end

        if getgenv().toggles.AutoCollect then
            for _, v in pairs(workspace:GetChildren()) do
                if (v.Name:find("Ribble") or v.Name:find("Coin")) and v:IsA("BasePart") then
                    if lp.Character and lp.Character.PrimaryPart then
                        lp.Character.PrimaryPart.CFrame = v.CFrame * CFrame.new(0, 4, 0)
                    end
                    task.wait(0.08)
                end
            end
        end
    end
end)

-- =================== UI ===================
local function createGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FrogFarmUI"
    sg.Parent = game:GetService("CoreGui")
    sg.ResetOnSpawn = false

    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 240, 0, 380)
    f.Position = UDim2.new(0.5, -120, 0.5, -190)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true

    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
    title.Text = "🐸 My Frog Pond Farm v2.1"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22

    local y = 50
    local function toggleBtn(name)
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(1,-20,0,36)
        b.Position = UDim2.new(0,10,0,y)
        b.BackgroundColor3 = Color3.fromRGB(35,35,50)
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = name .. ": OFF"
        b.Font = Enum.Font.Gotham
        b.TextSize = 16

        b.MouseButton1Click:Connect(function()
            getgenv().toggles[name] = not getgenv().toggles[name]
            b.Text = name .. ": " .. (getgenv().toggles[name] and "ON" or "OFF")
            b.BackgroundColor3 = getgenv().toggles[name] and Color3.fromRGB(0,180,0) or Color3.fromRGB(35,35,50)
        end)

        y = y + 42
        return b
    end

    toggleBtn("AutoBuy")
    toggleBtn("AutoSell")
    toggleBtn("AutoBreed")
    toggleBtn("AutoCollect")
    toggleBtn("Noclip")

    -- Speed
    local speed = Instance.new("TextBox", f)
    speed.Size = UDim2.new(1,-20,0,36)
    speed.Position = UDim2.new(0,10,0,y)
    speed.BackgroundColor3 = Color3.fromRGB(35,35,50)
    speed.TextColor3 = Color3.new(1,1,1)
    speed.Text = "Speed: " .. getgenv().toggles.Speed
    speed.TextSize = 16
    speed.FocusLost:Connect(function()
        local n = tonumber(speed.Text:match("%d+"))
        if n then getgenv().toggles.Speed = n end
    end)

    -- Close button
    local close = Instance.new("TextButton", f)
    close.Size = UDim2.new(1,0,0,40)
    close.Position = UDim2.new(0,0,1,-40)
    close.BackgroundColor3 = Color3.fromRGB(180,40,40)
    close.Text = "Close UI"
    close.TextColor3 = Color3.new(1,1,1)
    close.TextSize = 18
    close.MouseButton1Click:Connect(function() sg:Destroy() end)

    return sg
end

getgenv().openFrogUI = createGUI

print("=======================================")
print("🐸 My Frog Pond Auto-Farm v2.1 loaded!")
print("→ Run:   getgenv().openFrogUI()   to open menu")
print("→ First: Use Remote Spy to find correct remote names!")
print("=======================================")
