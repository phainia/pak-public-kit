require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local HoldingItemComponent = require("NewRoco.Modules.Core.Scene.Component.Show.HoldingItemComponent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local BP_StarGlow_C = Base:Extend("BP_StarGlow_C")
local StarGlowState = {
  None = -1,
  NORMAL = 0,
  ENHANCED = 1,
  SUPER = 2
}

function BP_StarGlow_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_StarGlow_C:Init()
  Base.Init(self)
  self.state = StarGlowState.NONE
end

function BP_StarGlow_C:SetSceneCharacter(sceneCharacter)
  if sceneCharacter then
    Base.SetSceneCharacter(self, sceneCharacter)
    self:Register()
  else
    self:Unregister()
    Base.SetSceneCharacter(self, sceneCharacter)
  end
end

function BP_StarGlow_C:Register()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:AddEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
  if not self.resourceLoaded then
    return
  end
  self:OnStatusChanged()
end

function BP_StarGlow_C:Unregister()
  if not self.sceneCharacter then
    return
  end
  self.sceneCharacter:RemoveEventListener(self, NPCModuleEvent.OnLogicStatusUpdated, self.OnStatusChanged)
end

function BP_StarGlow_C:OnStatusChanged()
  self:SetCurrentState()
end

function BP_StarGlow_C:SetCurrentState()
  if self.NRCChildActor ~= nil and nil ~= self.sceneCharacter then
    local child = self.NRCChildActor:GetChildActor()
    if child and UE.UObject.IsValid(child) then
      local state = self:GetCurrentState()
      if state == StarGlowState.SUPER and self.state ~= StarGlowState.SUPER then
        child:Third()
        child:FirstStop()
        child:SecondStop()
      elseif state == StarGlowState.ENHANCED and self.state ~= StarGlowState.ENHANCED then
        child:Second()
        child:FirstStop()
        child:ThirdStop()
      elseif state == StarGlowState.NORMAL and self.state ~= StarGlowState.NORMAL then
        child:First()
        child:ThirdStop()
        child:SecondStop()
      end
      self.state = state
    end
  end
end

function BP_StarGlow_C:GetCurrentState()
  if SceneUtils.IsLogicStatusStarGlow2(self.sceneCharacter) then
    return StarGlowState.SUPER
  elseif SceneUtils.IsLogicStatusStarGlow1(self.sceneCharacter) then
    return StarGlowState.ENHANCED
  else
    return StarGlowState.NORMAL
  end
end

return BP_StarGlow_C
