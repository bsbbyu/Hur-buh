-- ==========================================
-- TEST SCRIPT: KELAR SOAL -> JALAN KE KURSI PRINTER TERDEKAT
-- ==========================================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ComputersFolder = Workspace:WaitForChild("Computers")

local PrinterCoordinates = {
    ["Print_1"] = Vector3.new(-6008.849, 5.956, -210.805),
    ["Print_2"] = Vector3.new(-6008.840, 5.966, -224.522),
    ["Print_3"] = Vector3.new(-6008.839, 5.979, -238.361),
    ["Print_4"] = Vector3.new(-5868.426, 5.982, -213.191),
    ["Print_5"] = Vector3.new(-5868.429, 5.956, -249.965),
}

-- Tabel kursi spesifik masing-masing printer
local PrinterSeats = {
    ["Print_1"] = Vector3.new(-5968.743, 4.643, -228.440),
    ["Print_2"] = Vector3.new(-5968.743, 4.643, -228.440),
    ["Print_3"] = Vector3.new(-5967.168, 4.643, -260.844),
    ["Print_4"] = Vector3.new(-5878.439, 4.643, -228.620),
    ["Print_5"] = Vector3.new(-5880.500, 4.643, -261.013),
}

-- Fungsi jalan kaki pakai Pathfinding
local function walkToPosition(targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })

    path:ComputeAsync(hrp.Position, targetPos)
    
    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            humanoid:MoveTo(waypoint.Position)
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            local reached = false
            local conn
            conn = humanoid.MoveToFinished:Connect(function()
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
        task.wait(2)
    end
end

-- Fungsi Utama Test Sesuai Arahan Lu
local function runTestCycle(testPrinterName)
    print("[TEST] Memulai siklus untuk: " .. testPrinterName)
    local targetPos = PrinterCoordinates[testPrinterName]
    local targetSeat = PrinterSeats[testPrinterName]

    if not targetPos or not targetSeat then
        print("[TEST] Koordinat printer/kursi tidak ditemukan!")
        return
    end

    -- 1. Jalan kaki ke printer target
    print("[TEST] Berjalan ke " .. testPrinterName)
    walkToPosition(targetPos + Vector3.new(0, 0, 1.5))
    task.wait(0.5)

    -- Cari dan pencet proximity prompt printer kalau ada
    local printerModel = ComputersFolder:FindFirstChild(testPrinterName)
    if printerModel then
        for _, desc in ipairs(printerModel:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(desc)
                break
            end
        end
    end

    print("[TEST] Menunggu WorkGui (soal math) muncul dan dikerjakan...")

    -- 2. Tunggu WorkGui muncul lalu tunggu sampai selesai dijawab (hilang)
    local startTime = tick()
    local guiFound = false
    
    while tick() - startTime < 4 do
        if PlayerGui:FindFirstChild("WorkGui") then
            guiFound = true
            break
        end
        task.wait(0.1)
    end

    if guiFound then
        -- Tunggu sampai soal selesai / WorkGui tertutup sendiri
        while PlayerGui:FindFirstChild("WorkGui") do
            task.wait(0.2)
        end
        print("[TEST] Soal math selesai dikerjakan!")
    else
        print("[TEST] WorkGui tidak muncul, langsung lanjut jalan...")
    end

    task.wait(0.8) -- Jeda transisi aman

    -- 3. Jalan kaki balik ke kursi printer tersebut
    print("[TEST] Berjalan kaki kembali ke kursi untuk " .. testPrinterName)
    walkToPosition(targetSeat)

    -- Sampai di kursi, duduk manis
    task.wait(0.3)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Sit = true
    end
    print("[TEST] Siklus tes selesai! Berhasil duduk di kursi " .. testPrinterName)
end

-- CONTOH EKSEKUSI: Tes langsung ke Print_3 (bisa diganti Print_1 s.d Print_5)
task.spawn(function()
    runTestCycle("Print_3")
end)
