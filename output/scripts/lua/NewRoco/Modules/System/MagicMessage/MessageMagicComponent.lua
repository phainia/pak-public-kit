local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local MessageMagicComponent = Base:Extend("MessageMagicComponent")

function MessageMagicComponent.ShouldCreate(npc)
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
  if npcBase.npc_cfg_id == 55561 then
    return true
  end
  return false
end

return MessageMagicComponent
