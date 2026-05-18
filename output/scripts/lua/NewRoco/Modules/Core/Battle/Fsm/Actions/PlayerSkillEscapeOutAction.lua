local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local LineTraceUtils = require("NewRoco.Modules.Core.Battle.Common.LineTraceUtils")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local PlayerSkillEscapeOutAction = BattleActionBase:Extend("PlayerSkillEscapeOutAction")
FsmUtils.MergeMembers(BattleActionBase, PlayerSkillEscapeOutAction, {})

function PlayerSkillEscapeOutAction:OnEnter()
  self.SkillFinish = false
  self.PawnManager = _G.BattleManager.battlePawnManager
  self.PawnManager:TogglePetBuffsVisibility(false, true)
  self.PawnManager:HideAll(false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.CloseBattleRedPanel)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideMain, false)
  _G.NRCModuleManager:DoCmd(BattleUIModuleCmd.HideBattlePopupPanel)
  _G.BattleManager.vBattleField:HideAllWaterPlatforms()
  _G.BattleManager:StopBattleBGM()
  self.localPlayer = BattleUtils.GetPlayer()
  if not self.localPlayer then
    self:Finish()
    return
  end
  self:AddPlayerZ()
  BattleUtils.FocusPlayer()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  BattleUtils.SetPlayerSkmTickable(false)
  self.localPlayer:GetUEController():ResetCtrlRotation(100)
  local moveComp = self.localPlayer.viewObj:GetMovementComponent()
  moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
  self.resList = {
    BattleConst.PlayerSkillEscapeSelfOut
  }
  self.loadedResCount = 0
  BattleEventCenter:Bind(self, BattleEvent.OnSkillResLoaded)
  _G.BattleSkillManager:PreLoadRes(self.resList, true)
end

function PlayerSkillEscapeOutAction:OnBattleEvent(event, value)
  if event == BattleEvent.OnSkillResLoaded then
    Log.Debug("BattleMultiPvPEnterAction:OnBattleEvent:", event, value)
    for i = 1, #self.resList do
      if value == self.resList[i] then
        self.loadedResCount = self.loadedResCount + 1
      end
    end
    if self.loadedResCount == #self.resList then
      self:SafeDelayFrames("d_TryPlaySkill", 15, self.TryPlaySkill, self)
    end
    return true
  end
end

function PlayerSkillEscapeOutAction:OnPlayerStatusChanged(status, value, type)
  if status == Enum.WorldPlayerStatusType.WPST_LANDED then
    local AnimComp = self.localPlayer:GetAnimComponent()
    local AnimLength = 0
    if AnimComp then
      AnimLength = AnimComp:GetAnimLengthByName("MagicRunJumpEnd")
    end
    self.localPlayer:PlayAnim("MagicRunJumpEnd", 1, 0, 0.25, 0.25, 1, 0)
    if AnimLength > 0 then
      self:SafeDelaySeconds("d_LandedOver", AnimLength + 0.5, self.LandedOver, self)
    end
  end
end

function PlayerSkillEscapeOutAction:LandedOver()
  self:SafeCancelDelayById("d_LandedOver")
  if self.SkillFinish then
    self:Finish()
  end
end

function PlayerSkillEscapeOutAction:AddPlayerZ()
  if self.localPlayer and self.localPlayer.viewObj then
    local halfHeight = self.localPlayer:GetHalfHeight()
    local playerPos = self.localPlayer:GetActorLocation()
    local lineEnd = UE4.FVector(playerPos.X, playerPos.Y, playerPos.Z + halfHeight)
    local lineBegin = UE4.FVector(lineEnd.X, lineEnd.Y, lineEnd.Z + 350)
    local hitResult = LineTraceUtils.HitWorldStatic(lineBegin, lineEnd)
    if hitResult then
      if hitResult.Distance > 0 then
        self.localPlayer.viewObj:K2_AddActorLocalOffset(UE4.FVector(0, 0, hitResult.Distance), false, nil, false)
      end
    else
      self.localPlayer.viewObj:K2_AddActorLocalOffset(UE4.FVector(0, 0, 350), false, nil, false)
    end
  end
end

function PlayerSkillEscapeOutAction:TryPlaySkill()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, true)
  if BattleUtils.HasUI("BattleLoading") then
    local asyncData = {
      owner = self,
      callback = self.StartPlaySkill
    }
    NRCModuleManager:DoCmdAsync(asyncData, BattleUIModuleCmd.CloseLoading)
  else
    self:StartPlaySkill()
  end
end

function PlayerSkillEscapeOutAction:GetSkillClass(resPath)
  if _G.BattleSkillManager:IsResLoaded(resPath) then
    return _G.BattleSkillManager:GetLoadedClass(resPath)
  else
    Log.Error("BattlePvpEnterActionPetShow:GetSkillClass resPath not loaded resPath=", resPath)
    self:Finish()
  end
end

function PlayerSkillEscapeOutAction:StartPlaySkill()
  NRCModeManager:DoCmd(PlayerModuleCmd.HIDE_LOCAL_PLAYER, false)
  BattleUtils.SetPlayerSkmTickable(true)
  BattleUtils.ToggleMove(true)
  NRCModeManager:DoCmd(PlayerModuleCmd.CLOSE_LOCAL_PLAYER_Collision, false)
  if not self.localPlayer.viewObj then
    Log.Error("zgx PlayerSkillEscapeOutAction caster is nil")
    self:Finish()
    return
  end
  self.localPlayer:AddEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
  local SkillComp = self.localPlayer.viewObj:GetComponentByClass(UE4.URocoSkillComponent)
  if not SkillComp then
    local Identity = UE4.FTransform()
    SkillComp = self.localPlayer.viewObj:AddComponentByClass(UE4.URocoSkillComponent, false, Identity, false)
  end
  local skillClass = self:GetSkillClass(BattleConst.PlayerSkillEscapeSelfOut)
  if skillClass then
    local skillObj = SkillComp:FindOrAddSkillObj(skillClass)
    if skillObj then
      skillObj:SetCaster(self.localPlayer.viewObj)
      skillObj:RegisterEventCallback("End", self, self.SkillOver)
      skillObj:RegisterEventCallback("PreEnd", self, self.SkillOver)
      SkillComp:PlaySkill(skillObj)
    else
      Log.Error("zgx BattlePlayerSkillEscapePlayer skillObj is nil")
      self:OpenLoading()
    end
  end
end

function PlayerSkillEscapeOutAction:SkillOver()
  self.SkillFinish = true
  if not self:SafeFindDelayById("d_LandedOver") then
    self:Finish()
  end
end

function PlayerSkillEscapeOutAction:OnFinish()
  BattleEventCenter:UnBind(self)
  if self.localPlayer then
    self.localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_STATUS_CHANGED, self.OnPlayerStatusChanged)
    self.localPlayer = nil
  end
end

return PlayerSkillEscapeOutAction
