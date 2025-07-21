local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local Mouse = player:GetMouse()

local antiflingConnection
local anchorPosition = Vector3.new(2430, -113, 5824)
local anchorPart
local currentCharacter
local originalSizes = {}

local function idlePlayer()
    local GC = getconnections or get_signal_cons
    if GC then
        for _, v in ipairs(GC(player.Idled)) do
            if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end
        end
    else
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

local function startAntifling()
    if antiflingConnection then antiflingConnection:Disconnect() end
    antiflingConnection = RunService.Heartbeat:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

local function createAnchorPart()
    if not anchorPart or not anchorPart.Parent then
        anchorPart = Instance.new("Part")
        anchorPart.Name = "AnchorPart"
        anchorPart.Size = Vector3.new(10, 1, 10)
        anchorPart.Position = anchorPosition
        anchorPart.Anchored = true
        anchorPart.CanCollide = true
        anchorPart.Parent = Workspace
    end
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
    if part:IsA("BasePart") and part ~= anchorPart then
        part.CanCollide = false
    end
end

for _, part in ipairs(Workspace:GetDescendants()) do noclipPart(part) end
Workspace.DescendantAdded:Connect(noclipPart)

idlePlayer()
startAntifling()
createAnchorPart()

while true do
    task.wait(1)

    local success, err = pcall(function()
        createAnchorPart()
        if not currentCharacter or not currentCharacter.Parent then return end
        if not currentCharacter.PrimaryPart then
            local root = waitForHumanoidRootPart(currentCharacter, 10)
            if root then currentCharacter.PrimaryPart = root else return end
        end

        local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        local isMurderer = false
        for name, data in pairs(roles) do
            if name == player.Name and data.Role == "Murderer" then
                isMurderer = true
                break
            end
        end

        local fullLabel
        local eggFullVisible = false
        pcall(function()
            fullLabel = player.PlayerGui.MainGUI.Game.CoinBags.Container.BeachBall:FindFirstChild("Full")
            eggFullVisible = fullLabel and fullLabel.Visible
        end)

        if isMurderer and eggFullVisible then
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = target.Character.HumanoidRootPart
                    originalSizes[target.Name] = {
                        Size = hrp.Size,
                        Transparency = hrp.Transparency,
                        CFrame = hrp.CFrame,
                        Anchored = hrp.Anchored
                    }
                    hrp.Size = Vector3.new(9, 9, 9)
                    hrp.Transparency = 0.1
                    hrp.CanCollide = false
                    hrp.Massless = true
                    hrp.Anchored = true
                end
            end

            local moveConnection
            moveConnection = RunService.RenderStepped:Connect(function()
                if not isMurderer or not fullLabel or not fullLabel.Visible then
                    moveConnection:Disconnect()
                    return
                end
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = target.Character.HumanoidRootPart
                        local forward = currentCharacter.PrimaryPart.CFrame.LookVector
                        hrp.CFrame = currentCharacter.PrimaryPart.CFrame + forward * 1
                    end
                end
            end)

            local knife = player.Backpack:FindFirstChild("Knife")
            if knife then
                knife.Parent = player.Character
                task.wait(0.2)
            end

            while isMurderer and fullLabel and fullLabel.Visible and player.Character:FindFirstChild("Knife") do
                local knifeTool = player.Character:FindFirstChild("Knife")
                if knifeTool then
                    local stabEvent = knifeTool:FindFirstChild("Stab")
                    if stabEvent and stabEvent:IsA("RemoteEvent") then
                        stabEvent:FireServer()
                    end
                end
                task.wait(0.1)

                isMurderer = false
                local rolesUpdate = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                for name, data in pairs(rolesUpdate) do
                    if name == player.Name and data.Role == "Murderer" then
                        isMurderer = true
                        break
                    end
                end
            end

            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = target.Character.HumanoidRootPart
                    local original = originalSizes[target.Name]
                    if original then
                        hrp.Size = original.Size
                        hrp.Transparency = original.Transparency
                        hrp.CFrame = original.CFrame
                        hrp.Anchored = original.Anchored
                    end
                end
            end
        end

        local targetCoin = findCoinServer()
        if targetCoin then
            currentCharacter:SetPrimaryPartCFrame(targetCoin.CFrame * CFrame.new(0, 4, 0))
            task.wait(1)
            currentCharacter:SetPrimaryPartCFrame(anchorPart.CFrame + Vector3.new(0, 5, 0))
            task.wait(2)
        else
            currentCharacter:SetPrimaryPartCFrame(anchorPart.CFrame + Vector3.new(0, 5, 0))
        end
    end)

    if not success then
        warn("Error occurred: " .. tostring(err))
        task.wait(5)
    end
end
