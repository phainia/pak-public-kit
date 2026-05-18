require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_Soul_LightBall_C = Base:Extend("BP_Soul_LightBall_C")

function BP_Soul_LightBall_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_Soul_LightBall_C:Init()
  Base.Init(self)
end

function BP_Soul_LightBall_C:OnVisible()
  Base.OnVisible(self)
  self:OnStatusChanged()
end

function BP_Soul_LightBall_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_Soul_LightBall_C:Register()
  if not self.sceneCharacter then
    return
  end
  if not self.resourceLoaded then
    return
  end
end

function BP_Soul_LightBall_C:Unregister()
  if not self.sceneCharacter then
    return
  end
end

function BP_Soul_LightBall_C:OnStatusChanged()
  if SceneUtils.IsLogicStatusLightBallUnlock(self.sceneCharacter) then
    if self.IMT_Active then
      self:IMT_Active()
    end
  elseif self.IMT_Deactive then
    self:IMT_Deactive()
  end
end

function BP_Soul_LightBall_C:OnReconnect()
  self:OnStatusChanged()
end

return BP_Soul_LightBall_C
