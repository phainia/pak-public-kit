local UpdateRvtDistance = 5000.0
local UpdateRvtDistanceSquare = UpdateRvtDistance * UpdateRvtDistance
local CreateMagicNpdConfigIds = {
  55554,
  55555,
  55556
}
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local MagicCreationUtils = require("NewRoco.Modules.System.MagicCreation.MagicCreationUtils")
local CreateMagicComponent = Base:Extend("CreateMagicComponent")

function CreateMagicComponent.ShouldCreate(npc)
  if nil == npc then
    return false
  end
  local serverData = npc.serverData
  if nil == serverData then
    return false
  end
  local npcBase = serverData.npc_base
  if nil == npcBase then
    return false
  end
  local configId = npcBase.npc_cfg_id
  for _, v in ipairs(CreateMagicNpdConfigIds) do
    if v == configId then
      return true
    end
  end
  return false
end

function CreateMagicComponent:OnVisible()
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.SetNpcAppearance, self.owner, MagicCreationUtils.NpcValidType.Normal)
end

function CreateMagicComponent:Attach(owner)
  Base.Attach(self, owner)
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.RegisterCreation, owner)
  owner:AddEventListener(self, NPCModuleEvent.OnViewVisible, self.OnVisible)
end

function CreateMagicComponent:DeAttach()
  self.owner:RemoveEventListener(self, NPCModuleEvent.OnViewVisible, self.OnVisible)
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.UnregisterCreation, self.owner)
  Base.DeAttach(self)
end

function CreateMagicComponent:OnSetViewObj()
  if not self.owner then
    return
  end
  local viewObj = self.owner.viewObj
  if not UE4.UObject.IsValid(viewObj) then
    return
  end
  Log.Debug("CreateMagicComponent:OnSetViewObj", self.owner:DebugNPCNameAndID())
  viewObj:AddCustomTickDistance(UpdateRvtDistance)
  _G.NRCModuleManager:DoCmd(_G.MagicCreationModuleCmd.ApplySuitEffect, self.owner)
end

function CreateMagicComponent:OnDistanceOptimize(distance, viewDotValue, bulkyVisible, distanceRatio)
  if distance >= UpdateRvtDistanceSquare then
    return
  end
  if not self.hasUpdatedRvt then
    self.hasUpdatedRvt = true
    local viewObj = self.owner.viewObj
    if viewObj and viewObj.UpdateCaptureWorldDepth then
      viewObj:UpdateCaptureWorldDepth()
    end
  end
end

return CreateMagicComponent
