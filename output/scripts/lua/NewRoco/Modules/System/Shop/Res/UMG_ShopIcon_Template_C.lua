local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ShopIcon_Template_C = Base:Extend("UMG_ShopIcon_Template_C")

function UMG_ShopIcon_Template_C:OnConstruct()
end

function UMG_ShopIcon_Template_C:OnDestruct()
  _G.UpdateManager:UnRegister(self)
end

function UMG_ShopIcon_Template_C:OnItemUpdate(_data, datalist, index)
  self.FirstSelect = true
  self.FirstSelectTimer = 3
  self.SelectLoopTimer = 8
  self.UpdateTime = 0
  self.PlayAudio = false
  self.uiData = _data
  self.index = index
  local ShopList = self.uiData.shopConf
  if self.uiData.title then
    self.title:SetText(self.uiData.title)
  end
  if ShopList[1].icon then
    self.Ordinary:SetPath(ShopList[1].icon)
    local Temp = string.len("PaperSprite'/Game/NewRoco/Modules/System/Shop/ShopStatic/Frames/")
    local cutString = string.sub(ShopList[1].icon, Temp + 1)
    local cutpos = string.find(cutString, "%.")
    local addr = string.sub(cutString, 1, cutpos - 5) .. "_Light_png"
    local lightPath = "PaperSprite'/Game/NewRoco/Modules/System/Shop/ShopStatic/Frames/" .. addr .. "." .. addr
    self.PitchOn:SetPath(lightPath)
  end
  self:PlayAnimation(self.normal)
end

function UMG_ShopIcon_Template_C:OnItemSelected(_bSelected)
  if not self.uiData then
    return
  end
  local ShopList = self.uiData.shopConf
  local hasTab = self.uiData.hasTab
  self:StopAllAnimations()
  self:CancelPlayLoopAnim()
  if _bSelected then
    if self.PlayAudio then
      _G.NRCAudioManager:PlaySound2DAuto(1005, "UMG_ShopIcon_Template_C:OnItemSelected")
    end
    self:PlayAnimation(self.change1)
    self.Title:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("272727"))
    if 1 == #ShopList then
      _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetStoreListReq, ShopList[1].shop_id)
      local IsHiddenRed = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnGetIsHiddenShopItemRed, ShopList[1].shop_id)
      if IsHiddenRed then
        self.RedDot:SetupKey(0)
      else
        self.RedDot:SetupKey(378, ShopList[1].shop_id)
      end
    end
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdInitShopTabList, hasTab, ShopList)
    _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdCloseRefreshBtn)
  else
    self.UpdateTime = 0
    self.FirstSelect = true
    self:PlayAnimation(self.change2)
    self.Title:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("c4c2b6"))
  end
end

function UMG_ShopIcon_Template_C:StartPlayLoopAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:PlayAnimation(self.select_loop)
  self.loopFuncID = nil
end

function UMG_ShopIcon_Template_C:CancelPlayLoopAnim()
  if self.loopFuncID then
    DelayManager:CancelDelayById(self.loopFuncID)
    self.loopFuncID = nil
  end
end

function UMG_ShopIcon_Template_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:CancelPlayLoopAnim()
    self.loopFuncID = DelayManager:DelaySeconds(self.FirstSelectTimer, self.StartPlayLoopAnim, self)
  elseif anim == self.select_loop then
    self:CancelPlayLoopAnim()
    self.loopFuncID = DelayManager:DelaySeconds(self.SelectLoopTimer, self.StartPlayLoopAnim, self)
  end
end

function UMG_ShopIcon_Template_C:OnDestruct()
  self:CancelPlayLoopAnim()
end

function UMG_ShopIcon_Template_C:OnDeactive()
end

return UMG_ShopIcon_Template_C
