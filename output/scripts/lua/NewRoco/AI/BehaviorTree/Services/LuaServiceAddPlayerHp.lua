local Base = require("NewRoco.AI.BehaviorTree.LuaServiceBase")
local PlayerAddHpComponent = require("NewRoco.Modules.Core.Scene.Component.RoleHP.PlayerAddHpComponent")
local LuaServiceAddPlayerHp = Base:Extend("LuaServiceAddPlayerHp")

function LuaServiceAddPlayerHp:OnStart(controller)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local owner = controller
  local addHpComp = player:EnsureComponent(PlayerAddHpComponent)
  addHpComp:RegisterHealer(owner.Npc)
end

function LuaServiceAddPlayerHp:OnEnd(controller)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return
  end
  local owner = controller
  local addHpComp = player:EnsureComponent(PlayerAddHpComponent)
  addHpComp:UnregisterHealer(owner.Npc)
end

return LuaServiceAddPlayerHp
