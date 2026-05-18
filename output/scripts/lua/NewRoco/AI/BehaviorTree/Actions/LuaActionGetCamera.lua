local Base = require("NewRoco.AI.BehaviorTree.LuaActionBase")
local LuaActionGetCamera = Base:Extend("LuaActionGetCamera")
local TRIPOD_CAMERA_NPC_REFRESH_ID = 41000000

function LuaActionGetCamera:OnStart(owner)
  local Player = owner:GetFocusPlayerCharacter()
  local FocusPlayerId = Player:GetServerId()
  local CameraNpc = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByFilter, nil, function(v)
    local NpcRefreshId = v.serverData.npc_base.npc_content_cfg_id
    if NpcRefreshId == TRIPOD_CAMERA_NPC_REFRESH_ID then
      local AvatarId = v.serverData.npc_base.create_avatar_id
      if AvatarId == FocusPlayerId then
        return true
      end
    end
  end)
  if nil == CameraNpc then
    return self:Finish(false)
  end
  self.OutCameraObject:SetValue(owner, CameraNpc)
  return self:Finish(true)
end

return LuaActionGetCamera
