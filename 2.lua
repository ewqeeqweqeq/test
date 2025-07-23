local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Clip = false

local function enableNoclip(character)
    local function noclipLoop()
        if Clip == false and character ~= nil then
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
    end

    RunService.Stepped:Connect(noclipLoop)
end

local function checkMurderer()
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local isMurderer = false
    for name, data in pairs(roles) do
        if name == player.Name and data.Role == "Murderer" then
            isMurderer = true
            break
        end
    end
    return isMurderer
end

local function modifyPlayerHitboxes()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer ~= player then
            local character = otherPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if rootPart and rootPart:IsA("BasePart") then
                rootPart.Size = Vector3.new(50, 50, 50)
                rootPart.CanCollide = false

                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * 50
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 1
                    end
                end

                rootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
            end
        end
    end
end

local function equipKnifeAndStab()
    local knife = player.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = player.Character
        task.wait(0.2)

        local stabEvent = knife:FindFirstChild("Stab")
        if stabEvent and stabEvent:IsA("RemoteEvent") then
            local args = {"Slash"}
            stabEvent:FireServer(unpack(args))
        else
            warn("Stab event not found in Knife tool!")
        end
    else
        warn("Knife tool not found in Backpack!")
    end
end

local function restorePlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = otherPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                rootPart.Size = Vector3.new(2, 1, 1)
                rootPart.CanCollide = true
                rootPart.Anchored = false

                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.Anchored = false
                        part.Size = part.Size / 50
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end

local function main()
    enableNoclip(player.Character)

    while true do
        if checkMurderer() then
            modifyPlayerHitboxes()
            equipKnifeAndStab()
            wait(0.5)

        else
            restorePlayers()
            break 
        end
    end
end

main()
