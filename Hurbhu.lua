-- ==========================================
-- KEREN HUB - ULTIMATE OFFICE BOT (FIXED DETECTION)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local AssignPrintJob = JobEvents:WaitForChild("AssignPrintJob")
local ComputersFolder = Workspace:WaitForChild("Computers")

local AutoFarmActive = true

-- Data Koordinat Pasti Printer
local PrinterCoordinates = {
    ["Print_1"] = Vector3.new(-6008.849, 5.956, -210.805),
    ["Print_2"] = Vector3.new(-6008.840, 5.966, -224.522),
    ["Print_3"] = Vector3.new(-6008.839, 5.979, -238.361),
    ["Print_4"] = Vector3.new(-5868.426, 5.982, -213.191),
    ["Print_5"] = Vector3.new(-5868.429, 5.956, -249.965),
}

print("==========================================")
print("[Keren Hub] Ultimate Office Bot Active (Fixed Mode)!")
print("==========================================")

-- ==========================================
-- FUNGSI UTAMA: DETEKSI & JALAN KE PRINTER
-- ==========================================
local function walkToActivePrinter()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. Lepas dari kursi dulu & beri waktu transisi
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(1)
        end

        local targetPrinterName = nil
        local targetPos = nil
        local targetPrompt = nil
        local foundActive = false

        -- 2. Sistem Polling / Retry Deteksi (Memastikan server game sudah siapin status prompt)
        local attempts = 0
        while not foundActive and attempts < 15 do
            attempts = attempts + 1

            for i = 1, 5 do
                local pName = "Print_" .. i
                local printerModel = ComputersFolder:FindFirstChild(pName)
                
                if printerModel then
                    local isPromptEnabled = false
                    local foundPrompt = nil

                    for _, descendant in ipairs(printerModel:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            foundPrompt = descendant
                            if descendant.Enabled then
                                isPromptEnabled = true
                            end
                            break
                        end
                    end

                    -- Ambil printer pertama yang status prompt-nya aktif (Enabled = true)
                    if isPromptEnabled and foundPrompt then
                        targetPrinterName = pName
                        targetPos = PrinterCoordinates[pName]
                        targetPrompt = foundPrompt
                        foundActive = true
                        break
                    end
                end
            end

            if not foundActive then
                task.wait(0.4) -- Coba scan ulang kalau status belum siap
            end
        end

        -- 3. Eksekusi Perjalanan jika Tujuan Ditemukan
        if targetPos and targetPrinterName then
            print("[Keren Hub] Menuju ke tujuan aktif: " .. targetPrinterName)
            
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })

            path:ComputeAsync(hrp.Position, targetPos + Vector3.new(0, 0, 1.5))
            
            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for _, waypoint in ipairs(waypoints) do
                    humanoid:MoveTo(waypoint.Position)
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    local reached = false
                    local conn
                    conn = humanoid.MoveToFinished:Connect(function(isReached)
                        reached = true
                        if conn then conn:Disconnect() end
                    end)
                    
                    local t = tick()
                    while not reached and (tick() - t) < 0.8 do
                        task.wait(0.05)
                    end
                    if conn then conn:Disconnect() end
                end
            else
                humanoid:MoveTo(targetPos)
                task.wait(1.5)
            end

            task.wait(0.3)
            if targetPrompt and fireproximityprompt then
                fireproximityprompt(targetPrompt)
                print("• Semua lancar (Berhasil interaksi dengan " .. targetPrinterName .. ")")
            else
                print("[Keren Hub] Warning: Gagal mengeksekusi fireproximityprompt.")
            end
        else
            print("[Keren Hub] Gagal mendeteksi tujuan printer aktif (Waktu tunggu habis).")
        end
    end)
end

-- ==========================================
-- FUNGSI AUTO SOLVER GUI (MATEMATIKA)
-- ==========================================
local function solveOfficeTask()
    pcall(function()
        local workGui = PlayerGui:FindFirstChild("WorkGui")
        if not workGui then return end

        local questionLabel = workGui:FindFirstChild("QuestionLabel") or workGui:FindFirstChild("TextLabel")
        if not questionLabel then return end

        local rawText = questionLabel.Text
        if not rawText or rawText == "" then return end

        if not (rawText:find("%+") or rawText:find("%-")) then return end

        local cleanExpr = rawText:gsub("=.*", ""):gsub("[^%d%+%-]", "")
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end

        local success, result = pcall(mathFunc)
        if not success or not result then return end
        
        local targetAnswer = tostring(result)

        task.wait(math.random(10, 15) / 10)

        local frame = workGui:FindFirstChild("Frame")
        if not frame then return end

        for _, obj in ipairs(frame:GetChildren()) do
            if obj.Name == "AnswerButton" or obj:IsA("TextButton") then
                local btnText = ""
                if obj:IsA("TextButton") then
                    btnText = obj.Text
                else
                    local lbl = obj:FindFirstChildOfClass("TextLabel")
                    if lbl then btnText = lbl.Text end
                end

                local cleanBtnText = btnText:gsub("%D", "")

                if cleanBtnText == targetAnswer or btnTest == targetAnswer then
                    if obj:IsA("GuiButton") then
                        if firesignal then
                            firesignal(obj.MouseButton1Click)
                            firesignal(obj.Activated)
                        else
                            obj:Activate()
                        end
                    end
                    
                    task.wait(1.2)
                    break
                end
            end
        end
    end)
end

-- ==========================================
-- LOOP & EVENT LISTENER UTAMA
-- ==========================================
task.spawn(function()
    while AutoFarmActive do
        task.wait(1)
        solveOfficeTask()
    end
end)

AssignPrintJob.OnClientEvent:Connect(function()
    if not AutoFarmActive then return end
    task.wait(0.5)
    walkToActivePrinter()
end)
