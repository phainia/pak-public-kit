local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_HomeVisit_Dynamic_C = Base:Extend("UMG_HomeVisit_Dynamic_C")

function UMG_HomeVisit_Dynamic_C:OnConstruct()
  self:AddButtonListener(self.Btn.btnLevelUp, self.OnReqEnterFriendHome)
  if self.GrayBtn then
    self.GrayBtn:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function UMG_HomeVisit_Dynamic_C:OnDestruct()
  self:RemoveButtonListener(self.Btn.btnLevelUp)
end

function UMG_HomeVisit_Dynamic_C:OnReqEnterFriendHome()
  local isBan = _G.NRCModuleManager:DoCmd(FunctionBanModuleCmd.CheckUIFunctionBan, Enum.FunctionEntrance.FE_HOME, true)
  if isBan then
    return
  end
  NRCModuleManager:DoCmd(HomeModuleCmd.ReqEnterPlayerHomeIndoor, self.Data.visitor_uin, function(bSuccess)
    if bSuccess then
      HomeIndoorSandbox.Module:ClosePanel("HomeVisitPanel")
    end
  end)
end

function UMG_HomeVisit_Dynamic_C:OnItemUpdate(_data, datalist, index)
  self.Data = _data
  local name = _data.visitor_name
  self.NRCText_2:SetText(name)
  local icon_id = _data.visitor_icon
  local HeadPortrait = self.HeadItem.HeadPortrait
  local CardIconConf = _G.DataConfigManager:GetCardIconConf(icon_id)
  if CardIconConf then
    local AvatarPath = CardIconConf.icon_resource_path
    if AvatarPath then
      AvatarPath = string.format("%s%s.%s'", "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/", AvatarPath, AvatarPath)
      HeadPortrait:SetPath(AvatarPath)
    end
  end
  local desc = _data.visit_day_desc
  self.NRCText_3:SetText(desc or "")
  local dynamics = _data.message_list
  if dynamics and #dynamics > 0 then
    self.CanvasPanel_194:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.NRCGridView_71:InitGridView(dynamics)
  else
    self.CanvasPanel_194:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.Data.is_friend then
    self.FriendIdentifierIcon:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.FriendIdentifierIcon:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.Btn:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_HomeVisit_Dynamic_C:OnItemSelected(_bSelected)
end

function UMG_HomeVisit_Dynamic_C:OnDeactive()
end

return UMG_HomeVisit_Dynamic_C
