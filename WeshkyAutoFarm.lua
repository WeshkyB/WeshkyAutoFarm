local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local AutoFarmButton = Instance.new("TextButton")
local StopAutoFarmButton = Instance.new("TextButton")
local DiscordButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")
local onFarm = false
local _G = _G or {}
local autoFarmScript
local dragInput, dragStart, startPos

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "BuildABoatHub"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Frame

UIListLayout.Parent = Frame
UIListLayout.Padding = UDim.new(0, 5)

AutoFarmButton.Parent = Frame
AutoFarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AutoFarmButton.Size = UDim2.new(1, 0, 0, 40)
AutoFarmButton.Text = "Auto Farm: OFF"
AutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFarmButton.TextScaled = true

StopAutoFarmButton.Parent = Frame
StopAutoFarmButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
StopAutoFarmButton.Size = UDim2.new(1, 0, 0, 40)
StopAutoFarmButton.Text = "Stop Auto Farm"
StopAutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopAutoFarmButton.TextScaled = true
StopAutoFarmButton.Visible = false

DiscordButton.Parent = Frame
DiscordButton.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
DiscordButton.Size = UDim2.new(1, 0, 0, 40)
DiscordButton.Text = "Join Discord"
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextScaled = true
DiscordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/Qggg4Ht9cs")
end)

ToggleButton.Parent = Frame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Size = UDim2.new(1, 0, 0, 40)
ToggleButton.Text = "Toggle Hub Visibility"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

local ButtonCorner = UICorner:Clone()
ButtonCorner.Parent = AutoFarmButton

local ButtonCorner2 = UICorner:Clone()
ButtonCorner2.Parent = StopAutoFarmButton

local ButtonCorner3 = UICorner:Clone()
ButtonCorner3.Parent = DiscordButton

local ButtonCorner4 = UICorner:Clone()
ButtonCorner4.Parent = ToggleButton

StopAutoFarmButton.MouseButton1Click:Connect(function()
    onFarm = false
    AutoFarmButton.Text = "Auto Farm: OFF"
    AutoFarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StopAutoFarmButton.Visible = false

    if autoFarmScript then
        _G.StopAutoFarm = true
        autoFarmScript = nil
    end
end)

AutoFarmButton.MouseButton1Click:Connect(function()
    onFarm = not onFarm
    if onFarm then
        AutoFarmButton.Text = "Auto Farm: ON"
        AutoFarmButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        StopAutoFarmButton.Visible = true

        _G.StopAutoFarm = false

        autoFarmScript = loadstring([[
            local VirtualUser = game:GetService("VirtualUser")
            local player = game:GetService("Players").LocalPlayer
            local stages = game:GetService("Workspace").BoatStages.NormalStages
            local goldenChest = game:GetService("Workspace").BoatStages.NormalStages.TheEnd.GoldenChest.Trigger

            local function win()
                repeat wait() until player.Character
                local character = player.Character or player:WaitForChild("Character")
                repeat wait() until character:FindFirstChild("HumanoidRootPart")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                repeat wait() until character:FindFirstChild("Humanoid")
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                
                for i = 1, 10 do
                    local stage = stages:FindFirstChild("CaveStage" .. tostring(i))
                    local blackPart = stage:FindFirstChild("DarknessPart")
                    if not blackPart then continue end
                    
                    for _ = 1, 20 do
                        if _G.StopAutoFarm then return end
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                        rootPart.CFrame = blackPart.CFrame
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        wait(0.1)
                    end
                end

                for i = 1, 300 do
                    if _G.StopAutoFarm then return end
                    rootPart.CFrame = goldenChest.CFrame
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    wait(0.1)
                    if not (string.sub(rootPart:GetFullName():lower(), 1, 9) == "workspace") then break end
                    if i >= 200 then
                        humanoid.Health = 0
                    end
                end
            end

            local farms = 0

            while wait() do
                if _G.StopAutoFarm then return end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                win()
                farms += 1
                wait(1)
            end
        ]])
        autoFarmScript()
    else
        AutoFarmButton.Text = "Auto Farm: OFF"
        AutoFarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        StopAutoFarmButton.Visible = false

        if autoFarmScript then
            pcall(function() autoFarmScript = nil end)
        end
    end
end)

local function makeDraggable(frame)
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragInput = nil
                end
            end)
            dragInput = input
            game:GetService("UserInputService").InputChanged:Connect(update)
        end
    end)
end

makeDraggable(Frame)



local response = syn.request({
    Url = 'https://discord.com/api/webhooks/1307136910929563719/jlRvpF7-AG25oQE4ogU22bUljO4diAhgvwQsbbRpN6uOk7pDQC44RYjJXMPo9Vej0Vlg',  -- Replace with your Discord webhook URL
    Method = 'POST',
    Headers = {
        ['Content-Type'] = 'application/json'  -- Specifies the content type
    },
    Body = game:GetService('HttpService'):JSONEncode({
        content = 'Someone Executed Weshky Auto Fatm Script!'  -- The message you want to send
    })
})