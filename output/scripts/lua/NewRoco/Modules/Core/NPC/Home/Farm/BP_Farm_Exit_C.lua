require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local PetHUDComponent = require("NewRoco.Modules.Core.Scene.Component.HUD.PetHUDComponent")
local FarmModuleEvent = require("NewRoco.Modules.System.Farm.FarmModuleEvent")
local BP_Farm_Exit_C = Base:Extend("BP_Farm_Exit_C")

function BP_Farm_Exit_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Farm_Exit_C:Init()
  Base.Init(self)
end

function BP_Farm_Exit_C:OnFrameLoad(distanceRatio)
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_Farm_Exit_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_Farm_Exit_C:OnVisible()
  Base.OnVisible(self)
end

function BP_Farm_Exit_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Farm_Exit_C:Register()
  if not self.sceneCharacter then
    return
  end
end

function BP_Farm_Exit_C:Unregister()
end

return BP_Farm_Exit_C
