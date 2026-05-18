local mri = require("Debug.MemoryReferenceInfo")
mri.m_cConfig.m_bAllMemoryRefFileAddTime = false
local DumpFilePath = "C:\\Output\\"
local MemoryCheckTool = {}

function MemoryCheckTool:DumpCurrMemorySnapshot()
  if not _G.SnapshotNum then
    _G.SnapshotNum = 0
  end
  Log.Debug("Snapshot...")
  mri.m_cMethods.DumpMemorySnapshot(DumpFilePath, "snapshot_" .. tostring(_G.SnapshotNum), -1)
end

function MemoryCheckTool:DumpCurrMemorySnapshotWithGC()
  if not _G.SnapshotNum then
    _G.SnapshotNum = 0
  end
  collectgarbage("collect")
  collectgarbage("collect")
  mri.m_cMethods.DumpMemorySnapshot(DumpFilePath, "snapshot_" .. tostring(_G.SnapshotNum), -1)
end

function MemoryCheckTool:CompareSnapshot(a, b, filterMode, filterPara)
  Log.Debug("Compare Snapshot")
  local fileA = DumpFilePath .. "LuaMemRefInfo-All-[" .. "snapshot_" .. tostring(a) .. "].txt"
  local fileB = DumpFilePath .. "LuaMemRefInfo-All-[" .. "snapshot_" .. tostring(b) .. "].txt"
  local outputFilePath = mri.m_cMethods.DumpMemorySnapshotComparedFile(DumpFilePath, "Compared_" .. tostring(a) .. "_" .. tostring(b), -1, fileA, fileB, CompareBlackWordList)
  if filterPara and #filterPara > 0 then
    for i = 1, #filterPara do
      Log.Debug("Filter : " .. filterPara[i] .. "Mode : " .. tostring(filterMode))
      mri.m_cBases.OutputFilteredResult(outputFilePath, filterPara[i], filterMode, true)
      if true == filterMode then
        break
      end
    end
  end
end

function MemoryCheckTool:FilterCheckResult(a, filterPara)
  Log.Debug("Filter Snapshot")
end

return MemoryCheckTool
