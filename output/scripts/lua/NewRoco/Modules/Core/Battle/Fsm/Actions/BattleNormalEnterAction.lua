local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleNormalEnterAction = BattleActionBase:Extend("BattleNormalEnterAction")

function BattleNormalEnterAction:Ctor(name, properties)
  BattleActionBase.Ctor(self, name, properties)
  self.BattleManager = _G.BattleManager
  self.BattleField = self.BattleManager.vBattleField
  self.CameraManager = self.BattleField.battleCameraManager
  self.PawnManager = self.BattleManager.battlePawnManager
end

function BattleNormalEnterAction:OnEnter()
  self.timeout = 100.0
  self.IsPrepare = false
end

function BattleNormalEnterAction:StartPrepare()
  if not self.IsPrepare then
    self.IsPrepare = true
    local Result = self.BattleManager:PrepareBattle()
    if not Result then
      local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
      local Context = DialogContext()
      Context:SetTitle(LuaText.battlenormalenteraction_1):SetContent(LuaText.battlenormalenteraction_2):SetMode(DialogContext.Mode.OK)
      NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_OpenDialog, Context)
      self.fsm:SendEvent(BattleEvent.EnterNormalOver, self)
      return
    end
  end
end

function BattleNormalEnterAction:CheckBattlePrepareOver()
  return _G.BattleManager.PrepareOver
end

function BattleNormalEnterAction:CheckMainWindowReady()
  return BattleUtils.IsMainWindowReady()
end

function BattleNormalEnterAction:CheckBattleSceneReady()
  return true
end

function BattleNormalEnterAction:CheckBattleSkillsReady()
  return not self.SkillsLoader.isLoading
end

function BattleNormalEnterAction:OnTick(DeltaTime)
  if not BattleManager.isInBattle then
    return
  end
  if not self:CheckMainWindowReady() then
    return
  end
  if not self:CheckBattleSceneReady() then
    return
  end
  self:StartPrepare()
  if not self:CheckBattlePrepareOver() then
    return
  end
  self:OnLoaded()
end

function BattleNormalEnterAction:RestorePet(flag)
  Log.Debug("Try Restore Pet Scale!")
  local Pets = self.PawnManager:GetInFieldAllPet(flag)
  if Pets then
    for _, pet in ipairs(Pets) do
      pet:SetScale(1)
    end
  else
    Log.Error("Can't restore pet!!!!!!")
  end
end

function BattleNormalEnterAction:OnLoaded()
  self:RestorePet(BattleEnum.Team.ENUM_TEAM)
  self:RestorePet(BattleEnum.Team.ENUM_ENEMY)
  self.BattleField:SwitchToBattle()
  self.BattleManager:PlayBattleBGM()
  self.CameraManager:ChangeToPlayerPet(0)
  self:Finish()
end

function BattleNormalEnterAction:OnExit()
  self.BattleManager = nil
  self.BattleField = nil
  self.CameraManager = nil
end

return BattleNormalEnterAction
