local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSPingDisplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.8
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.fromRGB(100, 100, 100)

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 10)

local function createLabel(text, position)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = position
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    return label
end

local fpsLabel = createLabel("FPS: Calculating...", UDim2.new(0, 0, 0, 0))
local pingLabel = createLabel("Ping: Calculating...", UDim2.new(0, 0, 0, 20))
local playersLabel = createLabel("Players: Calculating...", UDim2.new(0, 0, 0, 40))
local adminsLabel = createLabel("Admins: None", UDim2.new(0, 0, 0, 60))

local function isHDAdmin(player)
    local adminLevel = player:FindFirstChild("AdminLevel")
    if adminLevel then
        local allowedRoles = { "Owner", "Admin", "Moderator", "CustomRank" }
        for _, role in ipairs(allowedRoles) do
            if adminLevel.Value == role then
                return true
            end
        end
    end
    return false
end

local function getAdmins()
    local admins = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player:GetAttribute("IsAdmin") == true 
        or (player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Admin") and player.leaderstats.Admin.Value == true)
        or isHDAdmin(player) then
            table.insert(admins, player.Name)
        end
    end
    return admins
end

local fpsValues = {}
local function calculateAverageFPS(newFPS)
    table.insert(fpsValues, newFPS)
    if #fpsValues > 30 then
        table.remove(fpsValues, 1)
    end
    local total = 0
    for _, v in ipairs(fpsValues) do
        total = total + v
    end
    return math.floor(total / #fpsValues)
end

game:GetService("RunService").RenderStepped:Connect(function()
    local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
    fpsLabel.Text = "FPS: " .. calculateAverageFPS(fps)

    local ping = game:GetService("Stats"):FindFirstChild("PerformanceStats")
    if ping then
        local latency = ping:FindFirstChild("Ping")
        if latency then
            pingLabel.Text = "Ping: " .. math.floor(latency:GetValue()) .. " ms"
        end
    end

    playersLabel.Text = "Players: " .. #game.Players:GetPlayers()

    local admins = getAdmins()
    if #admins > 0 then
        adminsLabel.Text = "Admins: " .. table.concat(admins, ", ")
    else
        adminsLabel.Text = "Admins: None"
    end
end)
