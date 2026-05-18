local Lua_NPCBase = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Base = Lua_NPCBase
local Lua_ShenShou_Transmit_Com_HD = Base:Extend("Lua_ShenShou_Transmit_Com_HD")

function Lua_ShenShou_Transmit_Com_HD:Ctor()
  Base.Ctor(self)
end

function Lua_ShenShou_Transmit_Com_HD:OnLogicStatusChange(ChangeInfo)
  Base.OnLogicStatusChange(self, ChangeInfo)
  local ShenShouTransmit = self.viewObj
  if ShenShouTransmit and ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_INTERACTING then
    ShenShouTransmit:CheckActivatedEffect()
  end
end

return Lua_ShenShou_Transmit_Com_HD
