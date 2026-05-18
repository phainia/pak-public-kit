local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_SpectatorsItem_C = Base:Extend("UMG_SpectatorsItem_C")

function UMG_SpectatorsItem_C:OnConstruct()
  self.data = {}
end

function UMG_SpectatorsItem_C:OnDestruct()
end

function UMG_SpectatorsItem_C:OnItemUpdate(_data, datalist, index)
  local prevData = self.data
  self.data = _data
  self:OnDataUpdate(prevData, self.data)
end

function UMG_SpectatorsItem_C:OnItemSelected(_bSelected)
end

function UMG_SpectatorsItem_C:OnDataUpdate(prevData, nextData)
  local isEmpty = nextData and nextData.isEmpty
  if isEmpty then
    self:SetRenderOpacity(0)
    return
  end
  self:SetRenderOpacity(1)
  local imageHeadVisibility = UE.ESlateVisibility.Collapsed
  local NRCSwitcher_EncouragementIconVisibility = UE.ESlateVisibility.Collapsed
  local imageHeadPath = ""
  local observerBriefInfo = nextData and nextData.observerBriefInfo
  local scoreRecord = nextData and nextData.scoreRecord
  local delayPlayLikeUiSeconds = nextData and nextData.delayPlayLikeUiSeconds or 0
  local isWin = nextData and nextData.isWin
  local switcherIndex = isWin and 0 or 1
  local icon = observerBriefInfo and observerBriefInfo.icon
  local score = scoreRecord and scoreRecord.score
  local scoreText = string.format("x%s", tostring(score))
  local showMax = 999999
  if score > showMax then
    scoreText = string.format("x%s+", tostring(showMax))
  end
  local path = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/"
  local headIconFullPath
  local cardIconConf = _G.DataConfigManager:GetCardIconConf(icon, true)
  if cardIconConf then
    local headIconRelativePath = cardIconConf.icon_resource_path
    headIconFullPath = string.format("%s%s.%s'", path, headIconRelativePath, headIconRelativePath)
  end
  if headIconFullPath then
    imageHeadVisibility = UE.ESlateVisibility.SelfHitTestInvisible
    imageHeadPath = headIconFullPath
  end
  self.Image_Head:SetVisibility(imageHeadVisibility)
  self.Image_Head:SetPath(imageHeadPath)
  self.TextNumber:SetText(scoreText)
  BattleUtils.SetPvpScoreIcon(self.NRCImage_7)
  if delayPlayLikeUiSeconds > 0 then
    self.playLikeId = _G.DelayManager:DelaySeconds(delayPlayLikeUiSeconds, self.PlayLikeAnimation, self)
  else
    NRCSwitcher_EncouragementIconVisibility = UE.ESlateVisibility.SelfHitTestInvisible
  end
  self.NRCSwitcher_EncouragementIcon:SetVisibility(NRCSwitcher_EncouragementIconVisibility)
  self.NRCSwitcher_EncouragementIcon:SetActiveWidgetIndex(switcherIndex)
  if nextData then
    nextData.delayPlayLikeUiSeconds = 0
  end
end

function UMG_SpectatorsItem_C:PlayLikeAnimation()
  if not UE.UObject.IsValid(self) then
    return
  end
  local NRCSwitcher_EncouragementIconVisibility = UE.ESlateVisibility.SelfHitTestInvisible
  self.NRCSwitcher_EncouragementIcon:SetVisibility(NRCSwitcher_EncouragementIconVisibility)
  self:PlayAnimation(self.like)
end

function UMG_SpectatorsItem_C:OnDespawn()
  if self.playLikeId then
    _G.DelayManager:CancelDelayById(self.playLikeId)
    self.playLikeId = nil
  end
end

function UMG_SpectatorsItem_C:OnDeactive()
  if self.playLikeId then
    _G.DelayManager:CancelDelayById(self.playLikeId)
    self.playLikeId = nil
  end
end

return UMG_SpectatorsItem_C
