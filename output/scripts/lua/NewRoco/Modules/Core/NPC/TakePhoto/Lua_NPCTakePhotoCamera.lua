local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCTakePhotoCamera = Base:Extend("Lua_NPCTakePhotoCamera")

function Lua_NPCTakePhotoCamera:OnDestroy()
  self:TryExitBeforeDestroy()
  Base.OnDestroy(self)
end

function Lua_NPCTakePhotoCamera:TryExitBeforeDestroy()
  if self.sceneCharacter then
    local ServerData = self.sceneCharacter.serverData
    local AvatarId = ServerData.npc_base.create_avatar_id
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    if localPlayer then
      local LocalActorId = localPlayer.serverData.base.actor_id
      Log.Info("[TakePhoto] Npc destroyed, create_avatar_id=", AvatarId, "local_actor_id=", LocalActorId)
      if AvatarId == LocalActorId then
        NRCModuleManager:DoCmd(TakePhotosModuleCmd.TryExitTakePhotoByTripodDestroyed)
      end
    end
  else
    Log.Error("[TakePhoto] cannot found sceneCharacter")
  end
end

return Lua_NPCTakePhotoCamera
