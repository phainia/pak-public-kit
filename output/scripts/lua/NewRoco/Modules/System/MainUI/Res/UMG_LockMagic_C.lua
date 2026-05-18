local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local ThrowUtils = require("NewRoco.Modules.Core.NPC.ThrowUtils")
local AbilityHelperManager = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityHelperManager")
local AbilityID = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityID")
local UMG_LockMagic_C = _G.NRCPanelBase:Extend("UMG_LockMagic_C")

function UMG_LockMagic_C:OnActive()
end

function UMG_LockMagic_C:OnDeactive()
end

function UMG_LockMagic_C:OnAddEventListener()
end

function UMG_LockMagic_C:OnConstruct()
  self:BindLockUMG()
  self.lastActor = nil
  self.curActor = nil
  self.isLockingState = false
  self.wndSize = UE4.UWidgetLayoutLibrary.GetViewportSize(_G.UE4Helper.GetCurrentWorld())
  self.LineTraceDist = 10000
  self.curTickTime = 0
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  _G.NRCEventCenter:RegisterEvent("UMG_LockMagic_C", self, SceneEvent.PlayerBornFinish, self.RebindPlayer)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_LockMagic_C:RebindPlayer()
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
end

function UMG_LockMagic_C:OnTick(InDeltaTime)
  if not self.player then
    return
  end
  if not self.isShowing then
    return
  end
  local playerCtrl = self.player:GetUEController()
  if not playerCtrl then
    return
  end
  if not UE4.UObject.IsValid(playerCtrl) then
    return
  end
  local WorldLocation, CamDir = playerCtrl:Abs_DeprojectScreenPositionToWorld(self.wndSize.X / 2, self.wndSize.Y / 2)
  local endPos = FVectorZero
  if self.LineTraceDist > 0 then
    endPos = WorldLocation + CamDir * self.LineTraceDist
  end
  local TraceChannel = _G.UE4.ECollisionChannel.ECC_GameTraceChannel1
  local OutHit, Res = UE4.UKismetSystemLibrary.Abs_LineTraceSingle(self.player.viewObj, WorldLocation, endPos, TraceChannel, false, nil, 0, nil, true)
  self.curTickTime = self.curTickTime + InDeltaTime
  if self.curTickTime > 0.7 then
    self.curTickTime = 0.0
    if OutHit.Actor ~= nil and OutHit.Actor ~= self.lastActor then
      self.curActor = OutHit.Actor
      if nil ~= self.curActor and self.curActor.sceneCharacter and self:CanInteract(self.curActor.sceneCharacter) then
        if self:IsAnimationPlaying(self.open) then
          self:OnEnterLockingState(false)
        else
          self:OnEnterLockingState(true)
        end
        self.isLockingState = true
      elseif self.lastActor and self.lastActor.sceneCharacter and self.lastActor.sceneCharacter.config and self.isLockingState then
        self:OnEnterLockingState(false)
        self.isLockingState = false
      end
    end
    self.lastActor = OutHit.Actor
  end
end

function UMG_LockMagic_C:CanInteract(actor)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local buff = AbilityHelperManager.GetHelper(AbilityID.MAGIC_STAR):GetBuff(player)
  local ballNpc
  if buff then
    ballNpc = buff.magicInfo.customMagicInfo.ballLua
  end
  local actorLocation = _G.FVectorZero
  local chargeLv = 0
  local range = 0
  if ballNpc and ballNpc.viewObj then
    actorLocation = ballNpc.viewObj:K2_GetActorLocation()
    chargeLv = ballNpc.viewObj.charge_level or 0
    range = ballNpc.viewObj.BoomRange or 0
  end
  local canInteract = false
  if actor.config then
    local npcCfg = _G.DataConfigManager:GetNpcConf(actor.config.id)
    for k, v in ipairs(npcCfg.option_id) do
      local npcOptionCfg
      npcOptionCfg = _G.DataConfigManager:GetNpcOptionConf(npcCfg.option_id[k])
      if npcOptionCfg and npcOptionCfg.magic_interact_id and npcOptionCfg.magic_interact_id > 0 then
        local magicInteractConf = _G.DataConfigManager:GetMagicInteractConf(npcOptionCfg.magic_interact_id)
        if magicInteractConf and 1 == magicInteractConf.action_struct[1].magic_id and chargeLv >= magicInteractConf.action_struct[1].magic_charge_level then
          local isFighting = false
          if actor.GetAimDisplay then
            local aimType = self.curActor.sceneCharacter:GetAimDisplay()
            if aimType and aimType[1] == _G.Enum.NPC_AIM_DISPLAY.NAD_WILD_PET then
              isFighting = actor:IsLogicStatus(ProtoEnum.SpaceActorLogicStatus.SALS_FIGHTING)
            end
          end
          if isFighting then
            canInteract = false
          else
            canInteract = true
          end
        end
      end
    end
  else
    canInteract = false
  end
  return canInteract
end

function UMG_LockMagic_C:OnWandChanged()
  self:BindLockUMG()
end

function UMG_LockMagic_C:BindLockUMG()
  self.LockUmgLoader:UnLoadPanel(true)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if self.player then
    self.wandData = self.player:GetCurWandDataByMagicType(ProtoEnum.SceneMagicType.SMT_STAR)
    self:LoadLockPanel(self.wandData.LockUMG)
  else
    Log.Error("UI\229\136\157\229\167\139\229\140\150\230\151\182\230\151\160player")
  end
end

function UMG_LockMagic_C:LoadLockPanel(classPath)
  local softClassPath = UE4.UKismetSystemLibrary.MakeSoftClassPath(tostring(classPath))
  self.LockUmgLoader:SetWidgetClass(softClassPath)
  self.LockUmgLoader:LoadPanel(nil)
end

function UMG_LockMagic_C:OnDestruct()
end

function UMG_LockMagic_C:OnShow()
  self.isShowing = true
  self:ResetInfo()
  local panelInst = self.LockUmgLoader:GetPanel()
  if panelInst then
    panelInst:OnShow()
  end
end

function UMG_LockMagic_C:OnCancel(cancelType)
  self.isShowing = false
  self:ResetInfo()
  local panelInst = self.LockUmgLoader:GetPanel()
  if panelInst then
    panelInst:OnCancel(cancelType)
  end
end

function UMG_LockMagic_C:ResetInfo()
  self.lastActor = nil
  self.curActor = nil
  self.curTickTime = 0
  self.isLockingState = false
end

function UMG_LockMagic_C:OnEnterLockingState(bool)
  local panelInst = self.LockUmgLoader:GetPanel()
  if panelInst then
    panelInst:OnEnterLockingState(bool)
  end
end

function UMG_LockMagic_C:ClearActorCache()
  local panelInst = self.LockUmgLoader:GetPanel()
  if panelInst then
    panelInst:ClearActorCache()
  end
end

return UMG_LockMagic_C
