local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local BaseMixActivityObject = Base:Extend("BaseMixActivityObject")
local ActivityModuleEvent = require("NewRoco/Modules/System/Activity/ActivityModuleEvent")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")

function BaseMixActivityObject:OnConstruct(_conf)
  self.mixCfg = _G.DataConfigManager:GetActivityMixConf(self:GetSinglePartId())
  self:AddActivityExpiredCallback("BaseMixActivityExpired", nil, function()
    self:SendEvent(ActivityModuleEvent.OnBaseMixActivityExpired)
  end)
end

function BaseMixActivityObject:GetMixCfg()
  return self.mixCfg
end

function BaseMixActivityObject:GetSlotRedPointData(slotData)
  if not slotData then
    return
  end
  
  local function SplitString(str, pattern)
    local result = {}
    if not string.IsNilOrEmpty(str) and not string.IsNilOrEmpty(pattern) then
      for match in string.gmatch(str, pattern) do
        result[#result + 1] = match
      end
    end
    return result
  end
  
  return slotData.red_point_id, SplitString(slotData.red_point_rule, "[^%#]+")
end

function BaseMixActivityObject:DoOperate(index, bOption)
  if self:IsInProgress() then
    local slot = self.mixCfg.slot_group[index]
    if bOption then
      ActivityUtils.DoActivityOptionCmd(slot.option_id)
    elseif slot.slot_function_type == _G.Enum.ActiviyMixSlotFunciton.AMSF_ACTIVITY then
      local dropObject = _G.NRCModuleManager:DoCmd(_G.ActivityModuleCmd.GetActivityInstById, slot.param, true)
      local getNum = 0
      if dropObject then
        getNum, _ = dropObject:GetAlreadyGetNum()
      end
      return getNum
    end
  end
end

function BaseMixActivityObject:GetTabRedPointCustomExtraKeyList()
  local extraKeyList = {}
  local mixCfg = self:GetMixCfg()
  if mixCfg then
    for _, slotData in ipairs(mixCfg.slot_group or {}) do
      local redPointId, redPointExtraKey = self:GetSlotRedPointData(slotData)
      if redPointId and next(redPointExtraKey) then
        table.insert(extraKeyList, redPointExtraKey)
      end
    end
  end
  return extraKeyList
end

return BaseMixActivityObject
