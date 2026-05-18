require("UnLuaEx")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_LobbyMainCompassMesh_C = Base:Extend("BP_LobbyMainCompassMesh_C")

function BP_LobbyMainCompassMesh_C:OnClickSkeletalMesh(StaticMesh)
  if StaticMesh == self.Luopan or StaticMesh == self.LuopanSphere then
    self:OnCompassClicked()
    return true
  end
  return false
end

function BP_LobbyMainCompassMesh_C:OnCompassClicked(Luopan)
end

function BP_LobbyMainCompassMesh_C:EnterStar()
  self:AnimStateChange(1)
  self:IdleStateChange(0)
end

function BP_LobbyMainCompassMesh_C:EndStar()
  self:AnimStateChange(3)
  self:IdleStateChange(0)
end

function BP_LobbyMainCompassMesh_C:SwitchToIdle()
  self:AnimStateChange(2)
  self:IdleStateChange(0)
end

function BP_LobbyMainCompassMesh_C:SwitchToIdle2()
  self:AnimStateChange(2)
  self:IdleStateChange(100)
end

return BP_LobbyMainCompassMesh_C
