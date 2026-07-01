local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PastActivity_TerritoryItem_C = Base:Extend("UMG_PastActivity_TerritoryItem_C")

function UMG_PastActivity_TerritoryItem_C:OnConstruct()
end

function UMG_PastActivity_TerritoryItem_C:OnDestruct()
end

function UMG_PastActivity_TerritoryItem_C:OnItemUpdate(_data, datalist, index)
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_data.petBaseId)
  self.Icon1:SetPath(petBaseConf.JL_res)
  self.Image:SetPath(petBaseConf.share_uncommon_card_bg)
  self.Atmosphere1:SetPath(petBaseConf.share_uncommon_card_fg)
  self.Text_Title:SetText(petBaseConf.name)
  local activityConf = _G.DataConfigManager:GetActivityConf(_data.activityId)
  local appearTime = string.split(string.split(activityConf.appear_time, " ")[1], "-")
  local disappearTime = string.split(string.split(activityConf.disappear_time, " ")[1], "-")
  self.Text_Time:SetText(appearTime[1] .. " " .. appearTime[2] .. "." .. appearTime[3] .. "/" .. disappearTime[2] .. "." .. disappearTime[3])
  if _data.bCompleted then
    self.Completed:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Completed:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.bSelected = false
  self:StopAllAnimations()
  self.Switcher:SetActiveWidgetIndex(0)
  self:PlayAnimation(self.normal)
  self.index = index
  local angles = {
    -3,
    -0.2,
    2.5,
    0
  }
  local slot = (index - 1) % #angles
  self:SetRenderTransformAngle(angles[slot + 1])
end

function UMG_PastActivity_TerritoryItem_C:OnItemSelected(_bSelected, bScrollChoose)
  if _bSelected ~= self.bSelected then
    self.bSelected = _bSelected
    self:StopAllAnimations()
    if _bSelected then
      if bScrollChoose then
        self:PlayAnimation(self.Press_loop, nil, 0)
      else
        self:PlayAnimation(self.Press_in)
      end
      self:BroadcastMsg("OnItemSelected", self.index)
    else
      self:PlayAnimation(self.Press_out)
    end
  end
end

function UMG_PastActivity_TerritoryItem_C:OnAnimationFinished(Anim)
  if Anim == self.Press_in then
    self:PlayAnimation(self.Press_loop, nil, 0)
  end
end

function UMG_PastActivity_TerritoryItem_C:OnTouchEnded(_MyGeometry, _TouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(40002021, "UMG_PastActivity_TerritoryItem_C:OnTouchEnded")
  Base.OnTouchEnded(self, _MyGeometry, _TouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

return UMG_PastActivity_TerritoryItem_C
