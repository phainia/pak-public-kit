local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local Base = DebugTabBase
local DebugTabBattleDebug = Base:Extend("DebugTabBattleDebug")

function DebugTabBattleDebugCtor()
  Base.Ctor(self)
end

function DebugTabBattleDebug:SetupTabs()
  self:Add("\230\137\147\229\141\176\232\167\146\232\137\178\231\178\190\231\129\181\228\189\141\231\189\174", self.ShowRolePetInfo, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "ShowRolePetInfo")
end

function DebugTabBattleDebug:ShowCameraLine(Name, Panel)
  self:ToggleCameraDebugLines(true)
end

function DebugTabBattleDebug:CloseCameraLine(Name, Panel)
  self:ToggleCameraDebugLines(false)
end

function DebugTabBattleDebug:PrintFsmState(Name, Panel)
  Log.Debug("BattleFsm Current State", BattleManager.stateFsm:GetActiveStateName())
  local ActiveState = BattleManager.stateFsm.activeState
  for i, k in ipairs(ActiveState.activeActions) do
    Log.Debug("BattleFsm Active Action", k.name)
  end
end

function DebugTabBattleDebug:SetDefaultOpenProcessVisible()
  BattleManager.isDefaultShowVisible = true
end

function DebugTabBattleDebug:SetDefaultCloseProcessVisible()
  BattleManager.isDefaultShowVisible = false
end

function DebugTabBattleDebug:OpenProcessVisible(Name, Panel)
  local BattleMain = BattleUtils.GetMainWindow()
  if BattleMain then
    BattleMain:InitProcessVisible()
  end
end

function DebugTabBattleDebug:CloseProcessVisible()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleProcessUI)
end

function DebugTabBattleDebug:OperateSelectMarker3d(Name, Panel, id)
  if Panel then
    local num = Panel:GetInputNumber()
    if num then
      BattleConst.ModelOffset.SelectorMarker3dOffsetZ = num
    end
  elseif id then
    local num = id
    if num then
      BattleConst.ModelOffset.SelectorMarker3dOffsetZ = num
    end
  end
end

function DebugTabBattleDebug:OperatePlayerMoveSpeed(Name, Panel, id)
  if Panel then
    local num = Panel:GetInputNumber()
    if num then
      BattleConst.DynamicBattle.PlayerMaxMovementSpeed = num
      local pawnManger = _G.BattleManager.battlePawnManager
      if pawnManger.playerTeam and pawnManger:GetPlayerMyTeam() and pawnManger:GetPlayerMyTeam().model then
        local MoveComp = pawnManger:GetPlayerMyTeam().model.CharacterMovement
        if MoveComp then
          MoveComp.MaxWalkSpeed = BattleConst.DynamicBattle.PlayerMaxMovementSpeed
        end
      end
      if pawnManger.enemyTeam and pawnManger:GetPlayerEnemyTeam() and pawnManger:GetPlayerEnemyTeam().model then
        local MoveComp = pawnManger:GetPlayerEnemyTeam().model.CharacterMovement
        if MoveComp then
          MoveComp.MaxWalkSpeed = BattleConst.DynamicBattle.PlayerMaxMovementSpeed
        end
      end
    end
  elseif id then
    local num = id
    if num then
      BattleConst.DynamicBattle.PlayerMaxMovementSpeed = num
      local pawnManger = _G.BattleManager.battlePawnManager
      if pawnManger.playerTeam and pawnManger:GetPlayerMyTeam() and pawnManger:GetPlayerMyTeam().model then
        local MoveComp = pawnManger:GetPlayerMyTeam().model.CharacterMovement
        if MoveComp then
          MoveComp.MaxWalkSpeed = BattleConst.DynamicBattle.PlayerMaxMovementSpeed
        end
      end
      if pawnManger.enemyTeam and pawnManger:GetPlayerEnemyTeam() and pawnManger:GetPlayerEnemyTeam().model then
        local MoveComp = pawnManger:GetPlayerEnemyTeam().model.CharacterMovement
        if MoveComp then
          MoveComp.MaxWalkSpeed = BattleConst.DynamicBattle.PlayerMaxMovementSpeed
        end
      end
    end
  end
end

function DebugTabBattleDebug:OperateChangeBlendTime(Name, Panel, id)
  if Panel then
    local num = Panel:GetInputNumber()
    if num then
      BattleConst.OperationSelectSettings.ChangeOperateBlendTime = num
    end
  elseif id then
    local num = id
    if num then
      BattleConst.OperationSelectSettings.ChangeOperateBlendTime = num
    end
  end
end

function DebugTabBattleDebug:ToggleCameraDebugLines(enable)
  local CamManager = _G.BattleManager.vBattleField.battleCameraManager
  if CamManager then
    CamManager.ShowDebugLine = enable
  end
end

function DebugTabBattleDebug:DebugCameraInfo()
  local CamManager = _G.BattleManager.vBattleField.battleCameraManager
  CamManager:ToggleDebugInfo()
end

function DebugTabBattleDebug:CameraSetting()
  local CamManager = _G.BattleManager.vBattleField.battleCameraManager
  CamManager:ToggleCameraSetting()
end

function DebugTabBattleDebug:ToggleTouchBattle()
  GlobalConfig.DisableTouchBattle = not GlobalConfig.DisableTouchBattle
  self:ShowTips(string.format("\229\183\178\231\187\143\228\184\186\230\130\168%s\230\142\165\232\167\166\232\191\155\230\136\152\230\150\151\231\154\132\229\138\159\232\131\189", GlobalConfig.DisableTouchBattle and "\229\129\156\231\148\168" or "\230\129\162\229\164\141"))
end

function DebugTabBattleDebug:OpenOnLyShowLogic()
  UE4.UNRCStatics.SetOnLyShowLogicSkill(true)
end

function DebugTabBattleDebug:CloseOnLyShowLogic()
  UE4.UNRCStatics.SetOnLyShowLogicSkill(false)
end

function DebugTabBattleDebug:OpenControllerBattleFlow()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.OpenBattleControllerPanel)
end

function DebugTabBattleDebug:CloseControllerBattleFlow()
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleControllerPanel)
end

function DebugTabBattleDebug:OpenRuntimeDebugConfigPanel()
  local debugCtrl = _G.BattleManager.battleRuntimeData.battleDebugControl
  if not debugCtrl then
    local BattleDebugControl = require("NewRoco.Modules.System.BattleUI.Res.BattleDebugger.BattleDebugControl")
    _G.BattleManager.battleRuntimeData.battleDebugControl = BattleDebugControl()
  end
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenRuntimeDebugConfig)
end

function DebugTabBattleDebug:OpenRuntimeDebugSkillPanel()
  local debugCtrl = _G.BattleManager.battleRuntimeData.battleDebugControl
  if not debugCtrl then
    local BattleDebugControl = require("NewRoco.Modules.System.BattleUI.Res.BattleDebugger.BattleDebugControl")
    _G.BattleManager.battleRuntimeData.battleDebugControl = BattleDebugControl()
  end
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
  NRCModuleManager:DoCmd(_G.DebugModuleCmd.OpenRuntimeDebugSkill)
end

function DebugTabBattleDebug:DebugSkillAutoPlay(Name, Panel)
  local BattleDebugControl = require("NewRoco.Modules.System.BattleUI.Res.BattleDebugger.BattleDebugControl")
  local fileName = Panel:GetInputString()
  if "" == fileName then
    fileName = "skill-auto-play"
  end
  local configData = BattleDebugControl.LoadAutoPlayConfigFromSaved(fileName)
  if configData then
    local debugCtrl = _G.BattleManager.battleRuntimeData.battleDebugControl
    if not debugCtrl then
      _G.BattleManager.battleRuntimeData.battleDebugControl = BattleDebugControl()
    end
    _G.BattleManager.battleRuntimeData.battleDebugControl:StartAutoPlaySkill(configData)
  else
    Log.Error("\232\135\170\229\138\168\230\146\173\230\148\190\230\136\152\230\150\151\233\133\141\231\189\174\232\142\183\229\143\150\229\164\177\232\180\165\239\188\140\229\183\178\229\143\150\230\182\136\230\146\173\230\148\190.")
  end
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabBattleDebug:RunTimeSkillAutoTest()
  local SkillAutoTest = require("NewRoco.Modules.Core.Battle.AutoTest.SkillAutoTest")
  SkillAutoTest:StartAutoTest()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabBattleDebug:RunBossCombatOutside()
  local BossCombatOutside = require("NewRoco.Modules.System.Debug.BossCombatOutside.BossCombatOutsideAutomation")
  BossCombatOutside:StartAutomationWithSavedConfig()
  NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, false)
end

function DebugTabBattleDebug:ShowRolePetInfo(Name, Panel)
  local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
  local allPlayTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_TEAM)
  for i, team in ipairs(allPlayTeams) do
    for j, pet in ipairs(team.pets) do
      Log.DebugFormat("ShowRolePetInfo \230\136\145\230\150\185\231\178\190\231\129\181%s \231\178\190\231\129\181\228\189\141\231\189\174:%s TeamID:%s \230\149\176\231\187\132\231\180\162\229\188\149:%s \230\152\175\229\144\166\229\156\168\229\156\186\228\184\138:%s", pet.card.name, pet.card.pos, i, j, pet.card:IsExistAtField())
    end
  end
  local allEnemyTeams = _G.BattleManager.battlePawnManager:GetAllTeam(BattleEnum.Team.ENUM_ENEMY)
  for i, team in ipairs(allEnemyTeams) do
    for j, pet in ipairs(team.pets) do
      Log.DebugFormat("ShowRolePetInfo \230\149\140\230\150\185\231\178\190\231\129\181%s \231\178\190\231\129\181\228\189\141\231\189\174:%s TeamID:%s \230\149\176\231\187\132\231\180\162\229\188\149:%s \230\152\175\229\144\166\229\156\168\229\156\186\228\184\138:%s", pet.card.name, pet.card.pos, i, j, pet.card:IsExistAtField())
    end
  end
end

function DebugTabBattleDebug:CheckG6IsUse()
  local resName = self.Panel:GetInputString()
  if string.IsNilOrEmpty(resName) then
    return
  end
  local AllSkill = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  for _, v in pairs(AllSkill) do
    if not string.IsNilOrEmpty(v.res_id) and v.res_id:find(resName) then
      Log.DebugFormat("CheckG6IsUse \232\181\132\230\186\144: %s \232\162\171\230\138\128\232\131\189: %s, \230\138\128\232\131\189Id: %d\228\189\191\231\148\168", resName, v.name, v.id)
    end
  end
  local AllBuffs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BUFF_CONF):GetAllDatas()
  for _, v in pairs(AllBuffs) do
    if not string.IsNilOrEmpty(v.res_id_0) and v.res_id_0:find(resName) then
      Log.DebugFormat("CheckG6IsUse \232\181\132\230\186\144: %s \232\162\171 Buff: %s, BuffId: %d\228\189\191\231\148\168", resName, v.name or "", v.id)
    end
    if not string.IsNilOrEmpty(v.res_id_1) and v.res_id_1:find(resName) then
      Log.DebugFormat("CheckG6IsUse \232\181\132\230\186\144: %s \232\162\171 Buff: %s, BuffId: %d\228\189\191\231\148\168", resName, v.name or "", v.id)
    end
    if not string.IsNilOrEmpty(v.res_id_2) and v.res_id_2:find(resName) then
      Log.DebugFormat("CheckG6IsUse \232\181\132\230\186\144: %s \232\162\171 Buff: %s, BuffId: %d\228\189\191\231\148\168", resName, v.name or "", v.id)
    end
  end
  local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
  self:CheckTableValue(BattleConst, resName, "")
end

function DebugTabBattleDebug:CheckTableValue(tbl, value, preKey)
  for i, v in pairs(tbl) do
    if type(v) == "string" then
      if string.find(v, value) then
        Log.DebugFormat("CheckG6IsUse \232\181\132\230\186\144: %s \232\162\171 BattleConst \231\154\132 %s%s \229\188\149\231\148\168\239\188\140\233\156\128\232\166\129\231\168\139\229\186\143\228\191\174\230\148\185", value, preKey, i)
      end
    elseif type(v) == "table" then
      self:CheckTableValue(v, value, i .. ".")
    end
  end
end

function DebugTabBattleDebug:CheckG6UseRes()
  local AllSkill = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  for _, v in pairs(AllSkill) do
    if not string.IsNilOrEmpty(v.res_id) and not UE4.UNRCStatics.CheckAssetExists(v.res_id) then
      Log.DebugFormat("CheckG6UseRes \230\138\128\232\131\189\228\189\191\231\148\168\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168, \230\138\128\232\131\189\229\144\141\229\173\151 %s, \230\138\128\232\131\189Id %d, \232\181\132\230\186\144\232\183\175\229\190\132 %s", v.name, v.id, v.res_id)
    end
  end
  local AllBuffs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BUFF_CONF):GetAllDatas()
  for _, v in pairs(AllBuffs) do
    if not string.IsNilOrEmpty(v.res_id_0) and not UE4.UNRCStatics.CheckAssetExists(v.res_id_0) then
      Log.DebugFormat("CheckG6UseRes Buff\228\189\191\231\148\168\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168, Buff\229\144\141\229\173\151 %s, BuffId %d, \232\181\132\230\186\144\232\183\175\229\190\132 %s", v.name or "", v.id, v.res_id_0)
    end
    if not string.IsNilOrEmpty(v.res_id_1) and not UE4.UNRCStatics.CheckAssetExists(v.res_id_1) then
      Log.DebugFormat("CheckG6UseRes Buff\228\189\191\231\148\168\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168, Buff\229\144\141\229\173\151 %s, BuffId %d, \232\181\132\230\186\144\232\183\175\229\190\132 %s", v.name or "", v.id, v.res_id_1)
    end
    if not string.IsNilOrEmpty(v.res_id_2) and not UE4.UNRCStatics.CheckAssetExists(v.res_id_2) then
      Log.DebugFormat("CheckG6UseRes Buff\228\189\191\231\148\168\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168, Buff\229\144\141\229\173\151 %s, BuffId %d, \232\181\132\230\186\144\232\183\175\229\190\132 %s", v.name or "", v.id, v.res_id_2)
    end
  end
end

return DebugTabBattleDebug
