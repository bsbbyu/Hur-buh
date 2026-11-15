-- ==========================================
-- KEREN HUB - ULTIMATE OFFICE BOT (PERFECT SYNC WALKING)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local AssignPrintJob = JobEvents:WaitForChild("AssignPrintJob")
local ComputersFolder = Workspace:WaitForChild("Computers")

local AutoFarmActive = true

-- Data Koordinat Pasti Printer Sesuai Pilihan Lu
local PrinterCoordinates = {
    ["Print_1"] = Vector3.new(-6008.849, 5.956, -210.805),
    ["Print_2"] = Vector3.new(-6008.840, 5.966, -224.522),
    ["Print_3"] = Vector3.new(-6008.839, 5.979, -238.361),
    ["Print_4"] = Vector3.new(-5868.426, 5.982, -213.191),
    ["Print_5"] = Vector3.new(-5868.429, 5.956, -249.965),
}

print("[Keren Hub] Ultimate Office Bot (Perfect Sync Mode) Loaded!")

-- Fungsi jalan kaki presisi berdasarkan target asli dari server
local function walkToTargetPrinter(assignedTarget)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. Berdiri / lompat dulu dari kursi kantor
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.6)
        end

        local printerName = ""

        -- Terjemahkan data mentah dari server secara akurat
        if typeof(assignedTarget) == "Instance" then
            printerName = assignedTarget.Name
        elseif typeof(assignedTarget) == "number" or typeof(assignedTarget) == "string" then
            -- Kalau server ngirim angka (misal 3) atau string ("Print_3" atau "3")
            local cleanName = tostring(assignedTarget):gsub("Print_", "")
            printerName = "Print_" .. cleanName
        end

        local targetPos = PrinterCoordinates[printerName]

        -- Jika nama printer gagal dikenali, ambil default Print_1
        if not targetPos then
            printerName = "Print_1"
            targetPos = PrinterCoordinates[printerName]
        end

        print("[Keren Hub] Target Printer Valid dari Server:", printerName)

        if targetPos then
            print("[Keren Hub] Berjalan kaki menuju " .. printerName .. "...")

            -- Buat path pakai PathfindingService biar jalan normal ada animasinya
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })

            path:ComputeAsync(hrp.Position, targetPos + Vector3.new(0, 0, 2))
            
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
                    while not reached and (tick() - t) < 1.5 do
                        task.wait(0.1)
                    end
                    if conn then conn:Disconnect() end
                end
            else
                -- Fallback kalau pathfinding mentok: jalan lurus manual
                humanoid:MoveTo(targetPos)
                task.wait(2)
            end

            -- 2. Sesampainya di printer, tekan ProximityPrompt-nya
            task.wait(0.3)
            local printerModel = ComputersFolder:FindFirstChild(printerName)
            if printerModel then
                local prompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
            print("[Keren Hub] Berhasil interaksi dengan " .. printerName .. "!")
        end
    end)
end

-- 1. FUNGSI AUTO SOLVER GUI (MATEMATIKA)
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

                if cleanBtnText == targetAnswer or btnText == targetAnswer then
                    if obj:IsA("GuiButton") then
                        if firesignal then
                            firesignal(obj.MouseButton1Click)
                            firesignal(obj.Activated)
                        else
                            obj:Activate()
                        end
                    end
                    
                    print("[Keren Hub] Sukses Jawab Soal -> Jawaban: " .. targetAnswer)
                    task.wait(1.2)
                    break
                end
            end
        end
    end)
end

-- Loop utama auto worker matematika
task.spawn(function()
    while AutoFarmActive do
        task.wait(1)
        solveOfficeTask()
    end
end)

-- 2. EVENT PENANGKAP PRINTER DARI SERVER (YANG UDAH PAS DETEKSINYA)
AssignPrintJob.OnClientEvent:Connect(function(assignedTarget)
    if not AutoFarmActive then return end
    print("[Keren Hub] Tugas Print diterima dari server! Target:", assignedTarget)
    task.wait(0.5)
    walkToTargetPrinter(assignedTarget)
end)
