local Delegate = require("Utils.Delegate")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local TipUtils = require("NewRoco.Modules.System.TipsModule.Utils.TipUtils")
local TipsDisplayDistributor = Class()

function TipsDisplayDistributor:Ctor(tipPass)
  self.tipPass = tipPass
  self.completeDistributionEvent = Delegate()
  self.blockingTipCnt = 0
  self.blockingTips = _G.MakeWeakTable()
  self.batchTips = {}
end

function TipsDisplayDistributor:__tostring()
  local buffer = {"{"}
  table.insert(buffer, string.format("tipPass:%d, ", self.tipPass))
  table.insert(buffer, string.format("blockingTipCnt:%d, ", self.blockingTipCnt))
  table.insert(buffer, "}")
  return table.concat(buffer)
end

function TipsDisplayDistributor:Dispatch(tip)
  TipUtils.DebugTipFlow("[Dispatch]", tip)
  tip:RegisterStatusChangeHandle(TipEnum.TipStatus.Blocking, self, self.OnTipBlocking)
  if TipUtils.IsMutexRequiredTipPass(tip.tipPass) then
    tip:SetTipStatus(TipEnum.TipStatus.Blocking)
  else
    tip:SetTipStatus(TipEnum.TipStatus.Distributing)
  end
  local sortCmpFunc = TipUtils.GetTipSortHandler(tip)
  if sortCmpFunc then
    local tipList = self.batchTips[sortCmpFunc]
    if not tipList then
      tipList = {}
      self.batchTips[sortCmpFunc] = tipList
    end
    table.insert(tipList, tip)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ShowTip, tip)
  end
end

function TipsDisplayDistributor:SetDispatchBatchFinished()
  for _sortCmpFunc, _tipList in pairs(self.batchTips) do
    if #_tipList > 1 and _sortCmpFunc then
      table.stableSort(_tipList, _sortCmpFunc)
    end
    for _, _tip in ipairs(_tipList) do
      _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.ShowTip, _tip)
    end
  end
  self.batchTips = {}
end

function TipsDisplayDistributor:ShouldWaitDispatchFinished()
  return self.blockingTipCnt > 0
end

function TipsDisplayDistributor:GetDistributionPass()
  return self.tipPass
end

function TipsDisplayDistributor:RegisterCompleteDistributionEvent(caller, handler)
  self.completeDistributionEvent:Add(caller, handler)
end

function TipsDisplayDistributor:UnRegisterCompleteDistributionEvent(caller, handler)
  self.completeDistributionEvent:Remove(caller, handler)
end

function TipsDisplayDistributor:OnTipBlocking(tip)
  TipUtils.DebugTipFlow("[OnTipBlocking]", tip)
  if not TipUtils.IsMutexRequiredTipPass(tip.tipPass) then
    return
  end
  self.blockingTipCnt = self.blockingTipCnt + 1
  tip:RegisterStatusChangeHandle(TipEnum.TipStatus.Expired, self, self.OnTipExpired)
  if not RocoEnv.IS_SHIPPING then
    self.blockingTips[tip.tipSeq] = tip
  end
end

function TipsDisplayDistributor:OnTipExpired(tip)
  TipUtils.DebugTipFlow("[OnTipExpired]", tip)
  if not TipUtils.IsMutexRequiredTipPass(tip.tipPass) then
    return
  end
  if self.blockingTipCnt > 0 then
    self.blockingTipCnt = self.blockingTipCnt - 1
    if 0 == self.blockingTipCnt then
      self.completeDistributionEvent:Invoke(self)
    end
  end
  if not RocoEnv.IS_SHIPPING then
    self.blockingTips[tip.tipSeq] = nil
  end
end

return TipsDisplayDistributor
