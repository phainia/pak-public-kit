local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCCharacter")
local Lua_PEO_Scene = Base:Extend("Lua_PEO_Scene")

function Lua_PEO_Scene:Ctor()
  self.reliedPet = {}
end

function Lua_PEO_Scene:SetCreateNPC(new_npc)
  local isReliedPet = false
  local new_npc_serverData = new_npc.serverData
  local new_npc_ref_content = _G.DataConfigManager:GetNpcRefreshContentConf(new_npc_serverData.npc_base.npc_content_cfg_id, true)
  if new_npc_ref_content then
    isReliedPet = new_npc_ref_content.refresh_type == Enum.RefreshType.RFT_RELY
  end
  if isReliedPet then
    if not new_npc:HasListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnReliedPetLeave) then
      new_npc:AddEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnReliedPetLeave)
    end
    local new_npc_id = new_npc_serverData.base.actor_id
    if not table.contains(self.reliedPet, new_npc) then
      table.insert(self.reliedPet, new_npc)
    end
  end
  new_npc.bNeedPosAdjust = false
  if not self.sceneCharacter then
    Log.Error("No scene character found!!!")
    return false
  end
  new_npc.serverPos = self.sceneCharacter:GetNearLocation()
  local radius = math.random() * 50 + 100
  local radian = math.random() * 6.28
  new_npc.serverPos.X = new_npc.serverPos.X + radius * math.sin(radian)
  new_npc.serverPos.Y = new_npc.serverPos.Y + radius * math.cos(radian)
  return true
end

function Lua_PEO_Scene:OnReliedPetLeave(relied_pet)
  relied_pet:RemoveEventListener(self, NPCModuleEvent.On_NPC_LEAVE, self.OnReliedPetLeave)
  local idx = 0
  for _, child in pairs(self.reliedPet) do
    if child == relied_pet then
      idx = _
      break
    end
  end
  if 0 ~= idx then
    table.remove(self.reliedPet, idx)
  else
    Log.Error("\230\173\163\229\156\168\231\167\187\233\153\164\228\184\128\228\184\170\228\184\141\229\134\141\232\183\159\233\154\143npc\231\154\132\231\178\190\231\129\181")
  end
  if self.sceneCharacter and self.sceneCharacter.shouldDestroy then
    self.sceneCharacter:SetNotDestroyFlag(false)
    if self.sceneCharacter then
      _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, self.sceneCharacter:GetServerId())
    end
  end
end

return Lua_PEO_Scene
