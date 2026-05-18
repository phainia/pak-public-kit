local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local OwlStarNotificationComponent = Base:Extend("OwlStarNotificationComponent")

function OwlStarNotificationComponent:Ctor()
  Base.Ctor(self)
  Log.Info("OwlStarNotificationComponent Ctor")
  self._isInRange = false
  self.OwlStarInfo = nil
end

function OwlStarNotificationComponent:Attach(owner)
  Base.Attach(self, owner)
  Log.Info("OwlStarNotificationComponent:Attach ", self.owner)
  if self.owner then
    self.owner:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNpcLeave)
    self.owner:AddEventListener(self, NPCModuleEvent.SetAttacheeState, self.OnAttacheeStateChanged)
  end
  self:OnNpcCreate()
end

function OwlStarNotificationComponent:OnAttacheeStateChanged(status)
  self:Log("OwlStarNotificationComponent:OnAttacheeStateChanged ", status)
  if status == ProtoEnum.PendantItemStatus.PIS_DISABLE and self.owner then
    local npc_obj_id = self.owner:GetServerId()
    local npc_cfg_id = self.owner:GetConfigId()
    Log.Info("OwlStarNotificationComponent:DeAttach from OnAttacheeStateChanged ", npc_obj_id, npc_cfg_id)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoDestroy, npc_obj_id, npc_cfg_id)
  end
end

function OwlStarNotificationComponent:OnNpcCreate()
  if self.owner then
    local npc_obj_id = self.owner:GetServerId()
    local npc_cfg_id = self.owner:GetConfigId()
    local owlStarInfo = {}
    owlStarInfo.npc_obj_id = npc_obj_id
    owlStarInfo.npc_cfg_id = npc_cfg_id
    owlStarInfo.npc_pos = self.owner.serverData.base.pt.pos
    owlStarInfo.logic_id = self.owner:GetLogicID()
    owlStarInfo.npc_content_id = self.owner:GetContentId()
    owlStarInfo.npc_src_refresh_content_id = self.owner:GetSourceNPCRefreshContentID()
    self.OwlStarInfo = owlStarInfo
    Log.Info("OwlStarNotificationComponent OnNpcCreate ", npc_obj_id, npc_cfg_id, owlStarInfo.npc_content_id, owlStarInfo.npc_src_refresh_content_id, owlStarInfo.logic_id)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoCreate, owlStarInfo)
  end
end

function OwlStarNotificationComponent:OnNpcLeave(npc)
  if self.owner ~= npc then
    return
  end
  if self.owner then
    local npc_obj_id = self.owner:GetServerId()
    local npc_cfg_id = self.owner:GetConfigId()
    Log.Info("OwlStarNotificationComponent:DeAttach from OnNpcLeave ", npc_obj_id, npc_cfg_id)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoDestroy, npc_obj_id, npc_cfg_id)
  end
  self.OwlStarInfo = nil
end

function OwlStarNotificationComponent:OnVisible()
  if self.OwlStarInfo then
    Log.Info("OwlStarNotificationComponent:OnVisible ", self.OwlStarInfo.npc_obj_id, self.OwlStarInfo.npc_cfg_id)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoCreate, self.OwlStarInfo)
  end
end

function OwlStarNotificationComponent:OnInvisible()
  if self.owner == nil then
    Log.Error("OwlStarNotificationComponent:OnInvisible owner is nil")
    return
  end
  local npc_obj_id = self.owner:GetServerId()
  local npc_cfg_id = self.owner:GetConfigId()
  Log.Info("OwlStarNotificationComponent:OnInvisible ", npc_obj_id, npc_cfg_id)
  _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoDestroy, npc_obj_id, npc_cfg_id)
end

function OwlStarNotificationComponent:DeAttach()
  if self.owner then
    local npc_obj_id = self.owner:GetServerId()
    local npc_cfg_id = self.owner:GetConfigId()
    Log.Info("OwlStarNotificationComponent:DeAttach ", npc_obj_id, npc_cfg_id)
    _G.NRCEventCenter:DispatchEvent(NPCModuleEvent.OnOwlStarInfoDestroy, npc_obj_id, npc_cfg_id)
    self.owner:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnNpcLeave)
    self.owner:RemoveEventListener(self, NPCModuleEvent.SetAttacheeState, self.OnAttacheeStateChanged)
  end
end

return OwlStarNotificationComponent
