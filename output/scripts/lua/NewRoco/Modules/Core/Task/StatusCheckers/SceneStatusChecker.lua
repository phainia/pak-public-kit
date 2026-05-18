local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local StatusCheckerBase = require("NewRoco.Modules.Core.Task.StatusCheckers.StatusCheckerBase")
local Base = StatusCheckerBase
local SceneStatusChecker = Base:Extend("SceneStatusChecker")

function SceneStatusChecker:Ctor()
  Base.Ctor(self)
end

function SceneStatusChecker:CheckPass()
  local SceneModule = _G.NRCModuleManager:GetModule("SceneModule")
  if not SceneModule then
    self:Log("\230\137\190\228\184\141\229\136\176\229\156\186\230\153\175\230\168\161\229\157\151")
    return false
  end
  if SceneModule.triggerEnterScene then
    self:Log("\229\156\186\230\153\175\230\168\161\229\157\151\230\173\163\229\156\168\229\138\160\232\189\189,triggerEnterScene")
    return false
  end
  if SceneModule._isLoading then
    self:Log("\229\156\186\230\153\175\230\168\161\229\157\151\230\173\163\229\156\168\229\138\160\232\189\189,_isLoading")
    return false
  end
  return true
end

function SceneStatusChecker:StartCheck()
  self:RegisterGlobalEvent(SceneEvent.BigWorldPrepared, self.OnMapLoaded)
end

function SceneStatusChecker:OnMapLoaded()
  self:FireCallback()
end

function SceneStatusChecker:EndCheck()
  self:UnregisterGlobalEvent(SceneEvent.BigWorldPrepared, self.OnMapLoaded)
end

return SceneStatusChecker
