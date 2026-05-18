local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local VideoMagicComponent = Base:Extend("VideoMagicComponent")

function VideoMagicComponent.ShouldCreate(npc)
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
  if npcBase.npc_cfg_id == 55591 then
    return true
  end
  return false
end

return VideoMagicComponent
