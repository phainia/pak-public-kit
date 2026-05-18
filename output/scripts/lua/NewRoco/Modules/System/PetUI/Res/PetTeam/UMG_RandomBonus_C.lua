local UMG_RandomBonus_Item_C = require("NewRoco.Modules.System.PetUI.Res.PetTeam.UMG_RandomBonus_Item_C")
local UMG_RandomBonus_Item_ContentType = UMG_RandomBonus_Item_C.ContentType
local UMG_RandomBonus_C = _G.NRCPanelBase:Extend("UMG_RandomBonus_C")

function UMG_RandomBonus_C:OnConstruct()
  self:SetChildViews(self.PopUp1)
end

function UMG_RandomBonus_C:OnActive(props)
  self.props = {}
  local onActiveCallback = props and props.onActiveCallback
  local callbackOwner = props and props.callbackOwner
  if onActiveCallback then
    tcall(callbackOwner, onActiveCallback, self)
  end
  self:SetCommonPopUpInfo()
  self:LoadAnimation(0)
end

function UMG_RandomBonus_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.ClosePanel
  CommonPopUpData.TitleText = _G.DataConfigManager:GetLocalizationConf("PVP_rank_character8", true).msg
  self.PopUp1:SetPanelInfo(CommonPopUpData)
end

function UMG_RandomBonus_C:ReceiveProps(props)
  local nextProps = {}
  table.copy(props, nextProps)
  local prevProps = self.props
  self.props = nextProps
  self:RenderWidget(prevProps, nextProps)
end

function UMG_RandomBonus_C:RenderWidget(prevProps, nextProps)
  if prevProps == nextProps then
    return
  end
  local startItemTitleConf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character20", true)
  local startItemTitleConfStr = startItemTitleConf and startItemTitleConf.str or ""
  local winItemTitleConf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character21", true)
  local winItemTitleConfStr = winItemTitleConf and winItemTitleConf.str or ""
  local hitPetItemTitleConf = _G.DataConfigManager:GetBattleGlobalConfig("pvp_rank_character22", true)
  local hitPetItemTitleConfStr = hitPetItemTitleConf and hitPetItemTitleConf.str or ""
  local startItemData = {
    titleText = startItemTitleConfStr,
    contentType = UMG_RandomBonus_Item_ContentType.Star,
    amount = nextProps.starCount or 0
  }
  local winItemData = {
    titleText = winItemTitleConfStr,
    contentType = UMG_RandomBonus_Item_ContentType.Reword,
    amount = nextProps.winNum or 0,
    amountTextPrefix = "+"
  }
  local hitPetItemData = {
    titleText = hitPetItemTitleConfStr,
    contentType = UMG_RandomBonus_Item_ContentType.Reword,
    amount = nextProps.hitPetNum or 0,
    amountTextPrefix = "+"
  }
  local itemDataList = {startItemData}
  self.GridView:InitGridView(itemDataList)
end

function UMG_RandomBonus_C:ClosePanel()
  self:LoadAnimation(2)
end

function UMG_RandomBonus_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    local props = self.props
    local onCloseCallback = props and props.onCloseCallback
    local callbackOwner = props and props.callbackOwner
    if onCloseCallback then
      tcall(callbackOwner, onCloseCallback, self)
    end
  elseif anim == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  end
end

function UMG_RandomBonus_C:OnDeactive()
end

function UMG_RandomBonus_C:OnAddEventListener()
end

return UMG_RandomBonus_C
