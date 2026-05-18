local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_InstanceNPC = Base:Extend("Lua_InstanceNPC")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local InstanceUtils = require("NewRoco.Modules.Core.Instance.InstanceUtils")

function Lua_InstanceNPC:Ctor()
  Base.Ctor(self)
  self.LogicStatus = nil
end

function Lua_InstanceNPC:OnLogicStatusChange()
  local Break = true
  if SceneUtils.IsLogicStatusTriggerOn(self.sceneCharacter) then
    self.LogicStatus = 1
    Break = false
  else
    self.LogicStatus = 0
    Break = false
  end
  if Break then
    return
  end
  if self.viewObj and self.viewObj.UpdateState then
    self.viewObj:UpdateState(false)
  end
end

function Lua_InstanceNPC:SetCreateNPC(NPC)
  if self.viewObj and self.viewObj.SetCreateNPC then
    self.viewObj:SetCreateNPC(NPC)
  else
    table.insert(self.NPCs, NPC)
  end
end

function Lua_InstanceNPC:UpdateActStatus(optionInfo)
  Base.UpdateActStatus(self, optionInfo)
  if self.viewObj and self.viewObj.UpdateState then
    self.viewObj:UpdateState(false)
  end
end

function Lua_InstanceNPC:LuaBeginPlay()
  self:OnLogicStatusChange()
  self.NPCs = {}
  Base.LuaBeginPlay(self)
end

function Lua_InstanceNPC:OnSetViewObj()
  Base.OnSetViewObj(self)
  local View = UE.UObject.IsValid(self.viewObj) and self.viewObj
  for _, NPC in pairs(self.NPCs) do
    if View and View.SetCreateNPC then
      View:SetCreateNPC(NPC)
    end
  end
  table.clear(self.NPCs)
  if View and View.UpdateState then
    View:UpdateState(true)
  end
end

return Lua_InstanceNPC
