-- My Frog Pond Auto-Farm v2.4 (Jan 11 2026) - FIXED UI VISIBILITY + AUTO-OPEN
if getgenv().FrogPondFarm then return end
getgenv().FrogPondFarm = true

print("[DEBUG] Script started loading...")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local lp = Players.LocalPlayer

-- CONFIG (placeholders - update with real names via remote spy!)
local REMOTES = RS:FindFirstChild("Remotes") or RS
local BUY_REMOTE = REMOTES:FindFirstChild("PurchaseTadpole") or REMOTES:FindFirstChild("BuyTadpole")
local SELL_REMOTE = REMOTES:FindFirstChild("SellFrog")
local BREED_REMOTE = REMOTES:FindFirstChild("Breed") or REMOTES:FindFirstChild("BreedFrogs")

local POND = workspace:FindFirstChild("Ponds") 
    and workspace.Ponds:FindFirstChild(lp.Name)
    or workspace:FindFirstChild(lp.Name .. "Pond")

local TADPOLE_TYPE = "Basic"
local BUY_COUNT = 5
local MAX_FROGS = 35
local MIN_FOR_BREED = 2

getgenv().toggles = {
    AutoBuy = false, AutoSell = false, AutoBreed = false,
    AutoCollect = false, Noclip = false, Speed = 50
}

hookfunction(lp.Kick, function() warn("Kick blocked") end)

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
        if noclip then noclip:Disconnect() noclip = nil end
    end
end

spawn(function()
    while getgenv().FrogPondFarm do
        task.wait(0.25)
        if lp.Character then
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = getgenv().toggles.Speed end
        end
        updateNoclip()
        -- Farming logic here (same as before, omitted for space)
    end
end)

-- FIXED & DEBUGGED UI
local function createGUI()
    print("[DEBUG] Creating UI...")
    
    -- Clean old UI
    pcall(function()
        if game.CoreGui:FindFirstChild("FrogFarmUI") then game.CoreGui.FrogFarmUI:Destroy() end
        if lp.PlayerGui:FindFirstChild("FrogFarmUI") then lp.PlayerGui.FrogFarmUI:Destroy() end
    end)
    
    local parent = gethui and gethui() or game.CoreGui or lp:WaitForChild("PlayerGui")
    print("[DEBUG] UI parent:", parent.Name or "unknown")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "FrogFarmUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = parent
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 260, 0, 400)
    f.Position = UDim2.new(0.5, -130, 0.5, -200)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true
    f.ZIndex = 999  -- Force on top
    
    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1,0,0,45)
    title.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
    title.Text = "🐸 My Frog Pond Farm v2.4"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.ZIndex = 1000
    
    print("[DEBUG] UI frame created - should be visible soon")
    
    -- Add your toggle buttons here (copy from previous version)
    local y = 55
    local function toggleBtn(name)
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(1,-20,0,40)
        b.Position = UDim2.new(0,10,0,y)
        b.BackgroundColor3 = Color3.fromRGB(40,40,60)
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = name .. ": OFF"
        b.TextSize = 18
        b.ZIndex = 1000

        b.MouseButton1Click:Connect(function()
            getgenv().toggles[name] = not getgenv().toggles[name]
            b.Text = name .. ": " .. (getgenv().toggles[name] and "ON" or "OFF")
           
