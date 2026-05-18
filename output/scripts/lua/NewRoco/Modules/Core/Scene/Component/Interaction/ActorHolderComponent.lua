local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local ActorHolderComponent = Base:Extend("ActorHolderComponent")

function ActorHolderComponent:Attach(owner)
  Base.Attach(self, owner)
  SceneUtils.RegisterNPCVisibilityNotify(self, true)
end

function ActorHolderComponent:OnVisible()
end

function ActorHolderComponent:OnInvisible()
end

function ActorHolderComponent:UpdateRelatedNPC(Action)
  self.owner.serverData.related_npc_infos = Action.relate_npcs
end

function ActorHolderComponent:GetRelatedNPCs(Type)
  local Raw = self.owner.serverData.related_npc_infos
  local NPCs
  if Raw and Raw.related_npc_infos then
    for _, Info in ipairs(Raw.related_npc_infos) do
      if nil == Type or Info.type == Type then
        if nil == NPCs then
          NPCs = {}
        end
        table.insert(NPCs, Info.npc_id)
      end
    end
  end
  return NPCs
end

function ActorHolderComponent:DeAttach()
  SceneUtils.UnregisterNPCVisibilityNotify(self)
  Base.DeAttach(self)
end

function ActorHolderComponent:Destroy()
  Base.Destroy(self)
end

return ActorHolderComponent
