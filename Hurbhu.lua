-- ==========================================
-- TEST SCRIPT: SELECT JOB -> SEATED TELE -> KUSI PRINT 3
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")

-- Rute Waypoints Custom menuju ke area Office dengan titik akhir persis di kursi dekat Printer 3
local OfficeWaypoints = {
    CFrame.new(-876.491, 2.788, -627.639),
    CFrame.new(-1727.164, 37.488, -575.180),
    CFrame.new(-3162.552, 2.788, -548.694),
    CFrame.new(-4445.568, 2.759, -554.887),
    CFrame.new(-5936.579, 2.759, -553.939),
    CFrame.new(-5967.168, 4.643, -260.844) -- Titik akhir pas di kursi dekat printer 3
}

print("[TEST] Memulai uji coba rute ke kursi Printer 3...")

-- 1. Select job dulu
local event = JobEvents:FindFirstChild("TeamChangeRequest")
if event then
    event:FireServer("Office Worker", 11378976, 0, 0, "Detector")
    print("[TEST] Job 'Office Worker' dikirim...")
end

task.wait(3) -- Jeda 3 detik

-- 2. Ambil karakter
local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local humanoid = char and char:FindFirstChildOfClass("Humanoid")

if hrp and humanoid then
    -- Duduk dulu di tempat awal sebelum mulai rute
    humanoid.Sit = true
    task.wait(1)

    -- Lempar ke waypoint pertama
    hrp.CFrame = OfficeWaypoints[1] + Vector3.new(0, 2, 0)
    task.wait(1)

    -- 3. Loop seated teleport lewatin waypoint
    local totalPoints = #OfficeWaypoints
    for index, targetCFrame in ipairs(OfficeWaypoints) do
        hrp.CFrame = targetCFrame
        
        -- Cek apakah ini titik akhir (kursi dekat printer 3)
        if index == totalPoints then
            task.wait(0.2)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Anti pingsan / ragdoll
            task.wait(0.3)
            humanoid.Sit = true -- Pasang posisi duduk di kursi tujuan
            print("[TEST] Sampai di kursi dekat Printer 3!")
        else
            -- Waypoint perjalanan: duduk di angin sebentar, lalu bangunin buat lanjut
            humanoid.Sit = true
            task.wait(1)
            humanoid.Sit = false
            task.wait(0.1)
        end
    end
    print("[TEST] Uji coba rute selesai dengan aman!")
else
    print("[TEST] Gagal: Karakter tidak ditemukan!")
end
