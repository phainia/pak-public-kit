local Class = _G.MakeSimpleClass
local AreaInfo = Class("AreaInfo")

function AreaInfo:Ctor(conf, unlocked)
  self.id = conf.id
  self.Conf = conf
  self.bIsUnlocked = unlocked
  self.AreaHeight = nil
end

function AreaInfo:IsSafe()
  for _, effect in ipairs(self.Conf.scene_effect) do
    if effect.effect_type == Enum.SceneEffect.SE_SAFE then
      return true
    end
  end
  return false
end

function AreaInfo:IsCave()
  if self.Conf.belong_cave and #self.Conf.belong_cave > 0 then
    return true
  end
  return false
end

function AreaInfo:CanMessage()
  for _, effect in ipairs(self.Conf.scene_effect) do
    if effect.effect_type == Enum.SceneEffect.SE_MARK_BAN then
      return false
    end
  end
  return true
end

function AreaInfo:IsAbnormal()
  for _, effect in ipairs(self.Conf.scene_effect) do
    if effect.effect_type == Enum.SceneEffect.SE_ABNORMAL_ENVIR then
      return not self.bIsUnlocked
    end
  end
  return false
end

function AreaInfo:GetHeight()
  if self.AreaHeight ~= nil then
    return self.AreaHeight
  end
  local IDs = self.Conf.area_id
  for _, ID in ipairs(IDs) do
    local Conf = _G.DataConfigManager:GetAreaConf(ID)
    if Conf and Conf.area_height > 0 then
      self.AreaHeight = Conf.area_height
      break
    end
  end
  if self.AreaHeight == nil then
    self.AreaHeight = 0
  end
  return self.AreaHeight
end

function AreaInfo:IsActivity()
  if self.Conf and self.Conf.broadcast_type and self.Conf.broadcast_type == Enum.AreaBroadcastType.ABT_ACTIVITY then
    return true
  end
  return false
end

return AreaInfo
