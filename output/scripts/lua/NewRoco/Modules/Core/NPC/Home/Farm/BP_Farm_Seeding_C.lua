require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_Farm_Seeding_C = Base:Extend("BP_Farm_Seeding_C")

function BP_Farm_Seeding_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Farm_Seeding_C:Init()
  Base.Init(self)
end

function BP_Farm_Seeding_C:OnLoadResource()
  Base.OnLoadResource(self)
end

function BP_Farm_Seeding_C:OnVisible()
  Base.OnVisible(self)
end

function BP_Farm_Seeding_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Farm_Seeding_C:Register()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  if not self.resourceLoaded then
    return
  end
  self:OnStatusChanged()
end

function BP_Farm_Seeding_C:Unregister()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
end

function BP_Farm_Seeding_C:OnStatusChanged()
end

return BP_Farm_Seeding_C
