-- My Frog Pond Auto-Farm v2.3 (Jan 11 2026 - Delta Executor) - AUTO UI!
if getgenv().FrogPondFarm then return end
getgenv().FrogPondFarm = true

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local lp = Players.LocalPlayer

-- CONFIG (update from remote spy!)
local REMOTES = RS:FindFirstChild("Remotes") or RS

local BUY_REMOTE     = REMOTES:FindFirstChild("PurchaseTadpole") or REMOTES:FindFirstChild("BuyTadpole")
local SELL_REMOTE    = REMOTES:FindFirstChild("SellFrog")
local BREED_REMOTE   = REMOTES:FindFirstChild("Breed") or REMOTES:FindFirstChild("BreedFrogs")

local POND = workspace:FindFirstChild("Ponds") 
    and workspace.Ponds:FindFirstChild(lp.Name)
    or workspace:FindFirstChild(lp.Name .. "Pond")

local TADPOLE_TYPE = "Basic"
local BUY_COUNT    = 5
local MAX_FROGS    = 35
local MIN_FOR_BREED= 2

getgenv().toggles = {
    AutoBuy     = false,
    AutoSell    = false,
    AutoBreed   = false,
    AutoCollect = false,
    Noclip      = false,
    Speed       = 50
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
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = getgenv().toggles.Speed end
        end
        updateNoclip()
        -- ... (rest of farming logic same as before - omitted for brevity)
    end
end)

-- IMPROVED UI with auto-open + fallback parent
local function createGUI()
    pcall(function() if game.CoreGui:FindFirstChild("FrogFarmUI") then game.CoreGui.FrogFarmUI:Destroy() end end)
    
    local parent = gethui and gethui() or game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "FrogFarmUI"
    sg.ResetOnSpawn = false
    sg.Parent = parent
    
    print("UI parent set to: " .. parent.Name .. " - should be visible now")
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 240, 0, 380)
    f.Position = UDim2.new(0.5, -120, 0.5, -190)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    f.Active = true
    f.Draggable = true
    
    -- Title (fixed)
    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
    title.Text = "🐸 My Frog Pond Farm v2.3"
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
        b.TextSize = 16

        b.MouseButton1Click:Connect(function()
            getgenv().toggles[name] = not getgenv().toggles[name]
            b.Text = name .. ": " .. (getgenv().toggles[name] and "ON 🟢" or "OFF 🔴")
            b.BackgroundColor3 = getgenv().toggles[name] and Color3.fromRGB(0,180,0) or Color3.fromRGB(35,35,50)
        end)
        y = y + 42
    end

    toggleBtn("AutoBuy")
    toggleBtn("AutoSell")
    toggleBtn("AutoBreed")
    toggleBtn("AutoCollect")
    toggleBtn("Noclip")

    -- Speed box, close button (same as before - add them here if needed)

    print("UI created! If not visible → check Delta console for errors")
    return sg
end

getgenv().openFrogUI = createGUI

-- AUTO OPEN AFTER LOAD (with small delay)
spawn(function()
    task.wait(2.5)  -- give game time to load
    createGUI()
    print("Auto-opened UI! Toggle features now.")
end)

print("Script loaded! UI should appear in ~3 seconds.")
