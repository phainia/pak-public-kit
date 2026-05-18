require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_Soul_Door_C = Base:Extend("BP_Soul_Door_C")

function BP_Soul_Door_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Soul_Door_C:Init()
  Base.Init(self)
end

function BP_Soul_Door_C:OnVisible()
  Base.OnVisible(self)
  self:OnStatusChanged()
end

function BP_Soul_Door_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
  else
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Soul_Door_C:Register()
  if not self.sceneCharacter then
    return
  end
  if not self.resourceLoaded then
    return
  end
end

function BP_Soul_Door_C:Unregister()
  if not self.sceneCharacter then
    return
  end
end

function BP_Soul_Door_C:OnStatusChanged()
  self:FX_Reset()
end

function BP_Soul_Door_C:OnReconnect()
  self:OnStatusChanged()
end

return BP_Soul_Door_C
