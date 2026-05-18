local NRCLooper = {}

function NRCLooper.Tick(deltaTime, realTickTime)
  UpdateManager:OnTick(deltaTime, realTickTime)
end

local UpdateGameDebugData = UE4.UCrashReportBlueprintLibrary.UpdateGameDebugData
local EGameDebugDataType = UE4.EGameDebugDataType
local _sb = {}
local _sb_n = 0

local function _push(v)
  _sb_n = _sb_n + 1
  _sb[_sb_n] = v
end

local function _clear()
  for i = 1, _sb_n do
    _sb[i] = nil
  end
  _sb_n = 0
end

function NRCLooper.UpdateGameDebugData(DeltaTime)
  if NRCModuleManager then
    local scene = NRCModuleManager:GetModule("SceneModule")
    if scene then
      UpdateGameDebugData(EGameDebugDataType.Scene, tostring(scene.mapResId))
    end
  end
  local dm = _G.DataModelMgr
  if dm and dm.PlayerDataModel and dm.PlayerDataModel.playerInfo then
    UpdateGameDebugData(EGameDebugDataType.IsMultiPlayer, tostring(dm.PlayerDataModel:IsVisitState()))
  end
  local pm = _G.NRCPanelManager
  if pm then
    local openedPanels = pm:GetAllOpenedPanelName()
    UpdateGameDebugData(EGameDebugDataType.OpenedPanels, table.concat(openedPanels, ","))
  end
  local bm = _G.BattleManager
  if bm and bm:IsInBattle() then
    if BattleField then
      _clear()
      _push("LastEnterBattlePoint = ")
      _push(tostring(BattleField.debugLastEnterBattlePoint))
      _push("\n")
      _push("LastEnterBattleRotateAns = ")
      _push(tostring(BattleField.debugLastEnterBattleRotateAns))
      _push("\n")
      _push("LastEnterBattleOriRotate = ")
      _push(tostring(BattleField.debugLastEnterBattleOriRotate))
      _push("\n")
      _push("LastEnterBattleRotateBit = ")
      _push(tostring(BattleField.debugLastEnterBattleRotateBit))
      _push("\n")
      _push("LastUseFullStation = ")
      _push(tostring(BattleField.debugLastUseFullStation))
      UpdateGameDebugData(EGameDebugDataType.BattleTransform, table.concat(_sb))
    end
    local rt = bm.battleRuntimeData
    if rt then
      _clear()
      _push("CurrentStateName = ")
      _push(tostring(bm:GetCurrentStateName()))
      _push("\n")
      _push("BattleType = ")
      _push(tostring(rt.battleType))
      _push("\n")
      _push("playerNumber = ")
      _push(tostring(rt.playerNumber))
      _push("\n")
      _push("playerPetNumber = ")
      _push(tostring(rt.playerPetNumber))
      _push("\n")
      _push("enemyNumber = ")
      _push(tostring(rt.enemyNumber))
      _push("\n")
      _push("enemyPetNumber = ")
      _push(tostring(rt.enemyPetNumber))
      _push("\n")
      _push("showRound = ")
      _push(tostring(rt.showRound))
      _push("\n")
      _push("curWeatherID = ")
      _push(tostring(rt.curWeatherID))
      UpdateGameDebugData(EGameDebugDataType.BattleStatus, table.concat(_sb))
    end
  else
    UpdateGameDebugData(EGameDebugDataType.BattleTransform, "NotInBattle")
    UpdateGameDebugData(EGameDebugDataType.BattleStatus, "NotInBattle")
  end
end

function NRCLooper.UpdateMemoryCheck(DeltaTime)
  UE4.UMemoryUtils.UpdateCheck()
end

return NRCLooper
