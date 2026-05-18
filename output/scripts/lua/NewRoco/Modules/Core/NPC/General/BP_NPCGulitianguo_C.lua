require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.BP_NPCChildBase_C")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local AttacheeComponent = require("NewRoco.Modules.Core.Scene.Component.Pendant.AttacheeComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_NPCGulitianguo_C = Base:Extend("BP_NPCGulitianguo_C")

function BP_NPCGulitianguo_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.Status = ProtoEnum.PendantItemStatus.PIS_NONE
  self.isShowing = false
  self.shouldDisappear = false
  self.CurrentPendantID = -1
end

function BP_NPCGulitianguo_C:OnLoadResource()
  Base.OnLoadResource(self)
  local AttacheeInstance = self:GetAttacheeComponent()
  if AttacheeInstance then
    self:UpdatePendantStatus(AttacheeInstance.status)
  end
end

function BP_NPCGulitianguo_C:SetSceneCharacter(sceneCharacter)
  if self.sceneCharacter then
    self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.SetAttacheeState, self.UpdatePendantStatus)
    self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.PendantDestroy, self.OnDisappear)
  end
  if not Base.SetSceneCharacter then
    return
  end
  Base.SetSceneCharacter(self, sceneCharacter)
  if sceneCharacter then
    sceneCharacter:AddEventListener(self, NPCModuleEvent.SetAttacheeState, self.UpdatePendantStatus)
    sceneCharacter:AddEventListener(self, NPCModuleEvent.PendantDestroy, self.OnDisappear)
  end
end

function BP_NPCGulitianguo_C:OnVisible()
  Base.OnVisible(self)
  if SceneUtils.IsRuntime then
    self.SoundSession = _G.NRCAudioManager:PlaySound3DWithActor(3016, self, "BP_NPCGulitianguo_C:OnVisible", false, true, "", true)
  end
  local actor = self.ChildActor:GetChildActor()
  if actor then
    actor.TriggerShowEnd:Add(self, self.OnShowEnd)
    actor:PlayAnim()
  end
  local AttacheeInstance = self:GetAttacheeComponent()
  if AttacheeInstance then
    self.CurrentPendantID = AttacheeInstance.itemId
  end
end

function BP_NPCGulitianguo_C:GetAttacheeComponent()
  if not self.sceneCharacter then
    return nil
  end
  local AttacheeInstance = self.sceneCharacter:GetComponent(AttacheeComponent)
  return AttacheeInstance
end

function BP_NPCGulitianguo_C:OnInVisible()
  Base.OnInVisible(self)
  _G.NRCAudioManager:ReleaseSession(self.SoundSession, true, "BP_NPCGulitianguo_C:OnInVisible", false)
  self.SoundSession = 0
  local actor = self.ChildActor:GetChildActor()
  if actor then
    actor.TriggerShowEnd:Clear()
    actor:StopAnim()
  end
end

function BP_NPCGulitianguo_C:UpdatePendantStatus(Status)
  if self.isShowing then
    return
  end
  if Status == ProtoEnum.PendantItemStatus.PIS_DISABLE then
    if self.Status == ProtoEnum.PendantItemStatus.PIS_NONE then
      local Actor = self.ChildActor:GetChildActor()
      Actor:SetActorHiddenInGame(true)
    else
      self:OnAttacheeInteracted()
    end
  else
    local Actor = self.ChildActor:GetChildActor()
    if Actor and Actor.SwitchView then
      Actor:SwitchView(Status == ProtoEnum.PendantItemStatus.PIS_ENABLE)
    end
  end
  self.Status = Status
end

function BP_NPCGulitianguo_C:OnAttacheeInteracted()
  self.isShowing = true
  local Actor = self.ChildActor:GetChildActor()
  if Actor and Actor.Show then
    local AttacheeInstance = self:GetAttacheeComponent()
    if not AttacheeInstance or not AttacheeInstance.attacher then
      self:OnShowEnd()
      return
    end
    local OwnerID = AttacheeInstance.attacher:GetWorldOwnerID()
    local Player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, OwnerID)
    Actor:Show(Player and Player.viewObj)
  else
    self:OnShowEnd()
  end
end

function BP_NPCGulitianguo_C:OnDisappear()
  if self.isShowing then
    self.shouldDisappear = true
    return
  end
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, self.sceneCharacter.serverData.base.actor_id, true)
end

function BP_NPCGulitianguo_C:OnShowEnd()
  self.isShowing = false
  if self.shouldDisappear then
    self:OnDisappear()
  end
end

return BP_NPCGulitianguo_C
