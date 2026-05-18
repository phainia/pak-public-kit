local Lua_NPCBase = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Base = Lua_NPCBase
local Lua_ShenShou_Transmit_Com = Base:Extend("Lua_ShenShou_Transmit_Com")

function Lua_ShenShou_Transmit_Com:Ctor()
  Base.Ctor(self)
end

function Lua_ShenShou_Transmit_Com:OnLogicStatusChange(ChangeInfo)
  Base.OnLogicStatusChange(self, ChangeInfo)
  local ShenShouTransmit = self.viewObj
  if ShenShouTransmit and ChangeInfo and ChangeInfo.changed_status.status == _G.ProtoEnum.SpaceActorLogicStatus.SALS_INTERACTING then
    ShenShouTransmit:CheckActivatedEffect()
  end
end

return Lua_ShenShou_Transmit_Com
