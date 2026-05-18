local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Buff = require("NewRoco.Modules.Core.Scene.Component.Buff.ScenePlayerBuff")
local RideAllMainAbility = require("NewRoco.Modules.Core.Scene.Component.Ability.RideAll.RideAllMainAbility")
local ScenePlayerBuffComponent = Base:Extend("ScenePlayerBuffComponent")

function ScenePlayerBuffComponent:Ctor()
  self._buffTable = {}
  self._SceneRideAllActiveType = 0
end

function ScenePlayerBuffComponent:AddBuff(name, buffClassOrPath, ...)
  local existBuff = self._buffTable[name]
  if existBuff then
    if existBuff.OnReActive then
      existBuff:OnReActive(...)
      return
    end
    Log.Warning("buff already existed name = ", name)
    return
  end
  local buffClassType = type(buffClassOrPath)
  if "table" == buffClassType then
    local buff = buffClassOrPath(...)
    self._buffTable[name] = buff
    buff:OnBegin(...)
  elseif "string" == buffClassType then
    local buffClass = UE4.UNRCStatics.ResolveClass(buffClassOrPath)
    local currentWorld = UE4Helper.GetCurrentWorld()
    if buffClass and currentWorld then
      local buff = currentWorld:Abs_SpawnActor(buffClass)
      buff.isBP = true
      self._buffTable[name] = buff
      local params = {
        ...
      }
      buff:OnBegin(...)
    end
  end
  if "RideAll_Main_Buff" == name then
    self._SceneRideAllActiveType = RideAllMainAbility.GetSceneRideAllActiveTypeByPath(buffClassOrPath)
  end
end

function ScenePlayerBuffComponent:RemoveBuff(name, ...)
  local buff = self._buffTable[name]
  if buff and not buff._isInRemove then
    buff._isInRemove = true
    buff:OnFinish(...)
    self._buffTable[name] = nil
    if buff.isBP then
      buff:K2_DestroyActor()
    end
    if "RideAll_Main_Buff" == name then
      self._SceneRideAllActiveType = 0
    end
  end
end

function ScenePlayerBuffComponent:Update(deltaTime)
  if not self.owner.viewObj then
    return
  end
  for _, v in pairs(self._buffTable) do
    v:OnUpdate(deltaTime)
  end
end

function ScenePlayerBuffComponent:GetBuff(name)
  return self._buffTable[name]
end

function ScenePlayerBuffComponent:HasBuff(name)
  return self:GetBuff(name) ~= nil
end

return ScenePlayerBuffComponent
