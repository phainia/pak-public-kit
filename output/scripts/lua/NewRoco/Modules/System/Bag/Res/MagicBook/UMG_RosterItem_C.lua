local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local BagModuleEvent = require("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_RosterItem_C = Base:Extend("UMG_RosterItem_C")

function UMG_RosterItem_C:OnConstruct()
  NRCEventCenter:RegisterEvent("UMG_RosterItem_C", self, BagModuleEvent.ReadMagicBookEraseRedPoint, self.EraseRedPoint)
end

function UMG_RosterItem_C:OnDestruct()
  NRCEventCenter:UnRegisterEvent(self, BagModuleEvent.ReadMagicBookEraseRedPoint, self.EraseRedPoint)
end

function UMG_RosterItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data.id then
    self.npcID = self.data.id
    self:UpdateUI()
  else
    self.npcID = nil
    self:UpdateBlankUI()
  end
end

function UMG_RosterItem_C:OnItemSelected(_bSelected)
  if self.npcID == nil then
    return
  end
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    if self.npcID then
      _G.NRCAudioManager:PlaySound2DAuto(1083, "UMG_MagicBook_C:OnPrePageBtnClick")
      NRCModuleManager:DoCmd(BagModuleCmd.OpenMagicBook, self.npcID)
      self.RedPoint:EraseRedPoint(true)
    end
  else
    self:PlayAnimation(self.Select_Out)
  end
end

function UMG_RosterItem_C:EraseRedPoint(NPCID)
  if NPCID == self.npcID then
    self.RedPoint:EraseRedPoint(true)
  end
end

function UMG_RosterItem_C:OnDeactive()
end

function UMG_RosterItem_C:UpdateUI()
  local MageConf = _G.DataConfigManager:GetMageConf(self.npcID)
  if not MageConf then
    return
  end
  local iconPath = MageConf.avatar_res
  self.RedPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.RedPoint:SetupKey(241, {
    self.npcID
  })
  self.Image:SetPath(iconPath)
  self.Image:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text_Name:SetText(MageConf.mage_name)
  self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Text_Name_1:SetText(MageConf.lune_name)
  self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Switcher:SetActiveWidgetIndex(1)
end

function UMG_RosterItem_C:UpdateBlankUI()
  self.Text_Name:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_Name_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Image:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.RedPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Switcher:SetActiveWidgetIndex(0)
  self.RedPoint:SetupKey(241, {999})
end

return UMG_RosterItem_C
