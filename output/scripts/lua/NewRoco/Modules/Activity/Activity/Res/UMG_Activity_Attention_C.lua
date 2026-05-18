local Base = require("NewRoco.Modules.Activity.Activity.Template.UMG_Activity_WebSitesTemplate_C")
local UMG_Activity_Attention_C = Base:Extend("UMG_Activity_Attention_C")
local ActivityEnum = require("NewRoco.Modules.System.Activity.ActivityEnum")

function UMG_Activity_Attention_C:BindUIElements()
  local uiElements = {}
  uiElements.bgImage = self.bg
  uiElements.particularsBtn = self.BtnParticulars
  uiElements.itemList = self.List
  uiElements.title = self.Text_Title
  uiElements.promptText = self.PromptText
  uiElements.openAnimName = "In"
  uiElements.changeAnimName = "In"
  return uiElements
end

function UMG_Activity_Attention_C:OnConstruct()
  Base.OnConstruct(self)
end

function UMG_Activity_Attention_C:OnDestruct()
  Base.OnDestruct(self)
end

function UMG_Activity_Attention_C:GetCloseBtnImagePath()
  return _G.UEPath.CLOSE_BTN_BLACK
end

function UMG_Activity_Attention_C:OnItemUpdate(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  if _itemInst then
    _itemInst:SetDescribe(_itemObject:GetWebSiteName())
    _itemInst:SetRewardId(_itemObject:GetRewardID())
    _itemInst:SetupRedPoint(_itemObject:GetRewardRedPointData())
    _itemInst:PlayRewardUnAvailableAnimation()
  end
  self:OnItemRefreshView(_itemInst, _index, _itemObject)
end

function UMG_Activity_Attention_C:OnItemRefreshView(_itemInst, _index, _itemObject)
  if not _itemObject then
    return
  end
  if _itemInst then
    _itemInst:SetBtnText(_itemObject:GetInteractiveText())
    local rewardStatus = _itemObject:GetRewardStatus()
    if rewardStatus == ActivityEnum.RewardStatus.UnAvailable then
      _itemInst:SetRewardNumColor("f4eee1ff")
      _itemInst:SetUnfinished(true)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnVisible(true)
      _itemInst:SetBtnState(0)
      _itemInst:PlayRewardUnAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Available then
      _itemInst:SetRewardNumColor("f4eee1ff")
      _itemInst:SetUnfinished(false)
      _itemInst:SetAlreadyReceived(false)
      _itemInst:SetParticleVisible(true)
      _itemInst:SetBtnVisible(true)
      _itemInst:SetBtnState(2)
      _itemInst:PlayRewardAvailableAnimation()
    elseif rewardStatus == ActivityEnum.RewardStatus.Received then
      _itemInst:SetRewardNumColor("f4eee1ff")
      _itemInst:SetUnfinished(false)
      _itemInst:SetAlreadyReceived(true)
      _itemInst:SetParticleVisible(false)
      _itemInst:SetBtnState(0)
      _itemInst:SetBtnVisible(_itemObject:RecoverOptionIfRewardGet())
      _itemInst:PlayRewardReceivedAnimation()
    end
  end
end

return UMG_Activity_Attention_C
