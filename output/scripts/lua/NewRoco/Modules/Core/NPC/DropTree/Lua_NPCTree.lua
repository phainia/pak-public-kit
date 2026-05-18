local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.Core.NPC.Lua_NPCBase")
local Lua_NPCTree = Base:Extend("Lua_NPCTree")

function Lua_NPCTree:LuaBeginPlay()
  Base.LuaBeginPlay(self)
  self.enable = true
  self.CachedOptionID = 0
  self.CachedResult = false
  self.prepareCreat = false
  self.waitForTimeChange = false
  self.shakeTreeNum = -1
end

function Lua_NPCTree:InitActStatus(optionInfo)
  self:UpdateActStatus(optionInfo)
  if self:IsAShakeTreeAction(optionInfo) then
    self.shakeTreeNum = optionInfo.executable_times
  end
end

function Lua_NPCTree:UpdateActStatus(optionInfo)
  Log.Debug("Lua_NPCTree:UpdateActStatus", self:GetDebugInfo(), optionInfo.executable_times)
  if not self:IsAShakeTreeAction(optionInfo) then
    return
  end
  local oldEnable = self.enable
  self.enable = 0 ~= optionInfo.executable_times
  self.shakeTreeNum = optionInfo.executable_times
  if not oldEnable and self.enable and self.viewObj then
    self.viewObj:PlayOptRefreshEffect()
  end
end

function Lua_NPCTree:IsAShakeTreeAction(optionInfo)
  local OptionID = optionInfo.option_id
  if not OptionID or 0 == optionInfo then
    return false
  end
  local OptionConf = _G.DataConfigManager:GetNpcOptionConf(OptionID)
  if not OptionConf then
    return false
  end
  if OptionConf.action.action_type == Enum.ActionType.ACT_SHAKETREE then
    return true
  end
  if OptionConf.pet_action.action_type == Enum.ActionType.ACT_PETSHAKETREE then
    return true
  end
  if OptionID == self.CachedOptionID then
    return self.CachedResult
  end
  if OptionConf.magic_interact_id > 0 then
    local MagicConf = _G.DataConfigManager:GetMagicInteractConf(OptionConf.magic_interact_id)
    for _, Conf in ipairs(MagicConf.action_struct) do
      if Conf.action_type == Enum.ActionType.ACT_STAR_HIT_FRUITTREE then
        self.CachedResult = true
        self.CachedOptionID = OptionID
        return true
      end
    end
    self.CachedResult = false
    self.CachedOptionID = OptionID
    return false
  end
  if OptionConf.pet_action.action_type == Enum.ActionType.ACT_TRIG_PET_INTERACT then
    local NumberStrings = string.Split(OptionConf.pet_action.action_param1, ";")
    NumberStrings = NumberStrings or {
      OptionConf.pet_action.action_param1
    }
    for _, Str in ipairs(NumberStrings) do
      local Conf = _G.DataConfigManager:GetPetInteractionConf(tonumber(Str))
      if Conf and Conf.action_type == Enum.ActionType.ACT_PETSHAKETREE then
        self.CachedResult = true
        self.CachedOptionID = OptionID
        return true
      end
    end
    self.CachedResult = false
    self.CachedOptionID = OptionID
    return false
  end
  self.CachedOptionID = OptionID
  self.CachedResult = false
  return false
end

function Lua_NPCTree:GetShakeTreeTimes()
  return self.shakeTreeNum
end

function Lua_NPCTree:OnNpcOptionChange(option)
  self:InitActStatus(option.optionInfo)
end

return Lua_NPCTree
