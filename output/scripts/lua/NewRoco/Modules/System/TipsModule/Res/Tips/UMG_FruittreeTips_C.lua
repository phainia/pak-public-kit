local UMG_FruittreeTips_C = _G.NRCPanelBase:Extend("UMG_FruittreeTips_C")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")

function UMG_FruittreeTips_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("UMG_FruittreeTips_C", self, TipsModuleEvent.FinishFruitTreeTips, self.OnFinishFruitTreeTips)
end

function UMG_FruittreeTips_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, TipsModuleEvent.FinishFruitTreeTips, self.OnFinishFruitTreeTips)
end

function UMG_FruittreeTips_C:OnActive(Params)
  self.CurCount = 0
  self.TotalCount = Params.TotalCount
  self.UMG_FruitTreeTipsRollNumber_C_0:PlayRollNumberAnim(0, Params.TotalCount)
  self.Title:SetText(string.format("%d /%d", Params.TotalCount, Params.TotalCount))
  self.Title_1:SetText(string.format("/%d", Params.TotalCount))
  self.Title_Describe_1:SetText(Params.AreaName)
  self:PlayAnimation(self.In)
end

function UMG_FruittreeTips_C:OnDeactive()
  self:CancelDelay()
end

function UMG_FruittreeTips_C:OnAddEventListener()
end

function UMG_FruittreeTips_C:OnAnimationFinished(Animation)
  if Animation == self.seal then
    self:PlayAnimation(self.Out)
  elseif Animation == self.Out then
    self:DoClose()
  end
end

function UMG_FruittreeTips_C:OnFinishFruitTreeTips()
  self:PlayAnimation(self.seal)
  self:DelaySeconds(0.68, function()
    _G.NRCAudioManager:PlaySound2DAuto(232107, "UMG_FruittreeTips_C:OnFinishFruitTreeTips")
  end)
end

return UMG_FruittreeTips_C
