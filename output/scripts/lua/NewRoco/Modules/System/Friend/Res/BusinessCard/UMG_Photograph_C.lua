local FriendEnum = require("NewRoco.Modules.System.Friend.FriendEnum")
local FriendModuleEvent = reload("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_Photograph_C = _G.NRCPanelBase:Extend("UMG_Photograph_C")

function UMG_Photograph_C:OnConstruct()
  self.data = self.module:GetData("FriendModuleData")
  self:SetChildViews(self.UMG_CardImage)
  self.UMG_CardImage:SetCardEntranceType(FriendEnum.CardEntrance.Photograph)
  self:OnAddEventListener()
  self:AddPcInputBlock()
end

function UMG_Photograph_C:OnDestruct()
  self:RemovePcInputBlock()
end

function UMG_Photograph_C:OnActive()
  self.UMG_CardImage.panelName = "Photograph"
  self.UMG_CardImage:SetPlayerPath()
  local _AppearanceInfo = self.data:GetPlayerCardAppearanceInfo()
  Log.Dump(_AppearanceInfo, 3, "UMG_Photograph_C:OnActive")
  self.UMG_CardImage:SetScaleAndLocation(UE4.FVector(0.78, 0.78, 0.78), UE4.FVector(0, -20, 23))
  self.UMG_CardImage:SelectSuit(_AppearanceInfo.fashion_wear_id, FriendEnum.CardEntrance.Photograph, _AppearanceInfo.salon_item_data)
  local Path = _G.DataConfigManager:GetCardSkinConf(_AppearanceInfo.card_skin_selected)
  if Path then
    self.PanelBg:SetPath(string.format(UEPath.CARD_COMMON_PATH, Path.skin_resource_path, "1", Path.skin_resource_path, "1"))
  else
    Log.Debug("\230\178\161\230\156\137\233\133\141\231\189\174\232\161\168\230\149\176\230\141\174---", _AppearanceInfo.card_skin_selected)
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Photograph_C:OnDeactive()
end

function UMG_Photograph_C:AddPcInputBlock()
end

function UMG_Photograph_C:RemovePcInputBlock()
end

function UMG_Photograph_C:OnPcClose()
  self:OnCloseBtn()
end

function UMG_Photograph_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseRenamePanel, self.OnCloseBtn)
  self:AddButtonListener(self.Btn2.btnLevelUp, self.rephotograph)
  self:AddButtonListener(self.Btn3.btnLevelUp, self.Confirm)
  self:RegisterEvent(self, FriendModuleEvent.ShowOnlyActorsSucceed, self.OnShowOnlyActorsSucceed)
end

function UMG_Photograph_C:OnShowOnlyActorsSucceed()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Photo)
end

function UMG_Photograph_C:rephotograph()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_ThisTag_C:OnActive")
  self:OnCloseBtn()
end

function UMG_Photograph_C:Confirm()
  if _G.GlobalConfig.DebugOpenUI then
    self:OnCloseBtn()
    return
  end
  _G.NRCModeManager:DoCmd(FriendModuleCmd.PhotoGraphSave)
  self:PlayAnimation(self.Pick)
end

function UMG_Photograph_C:PlayPickAnim()
  self:PlayAnimation(self.Pick)
end

function UMG_Photograph_C:OnCloseBtn()
  self:OnClose()
  _G.NRCModuleManager:DoCmd(FriendModuleCmd.AgainPhotograph)
end

function UMG_Photograph_C:OnAnimationFinished(Anim)
  if Anim == self.Pick then
    self:OnClose()
  end
end

return UMG_Photograph_C
