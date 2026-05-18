local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UIUtils = require("NewRoco.Modules.System.TipsModule.Utils.UIUtils")
local UMG_MiracleExchange_Main_Item_C = Base:Extend("UMG_MiracleExchange_Main_Item_C")

function UMG_MiracleExchange_Main_Item_C:OnConstruct()
end

function UMG_MiracleExchange_Main_Item_C:OnDestruct()
end

function UMG_MiracleExchange_Main_Item_C:OnItemUpdate(_data, _datalist, index)
  Log.Dump(_data, 4, "UMG_MiracleExchange_Main_Item_C:OnItemUpdate")
  self.PetList = _data
  self.datalist = _datalist
  self:SetData()
end

function UMG_MiracleExchange_Main_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    self.SelectPet = self.PetList
    _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.OnMiracleMainPetSelectChange, self.PetList.PetData.gid, self.PetList, self._index)
  elseif not self.PetList.IsbMultipleChoice and self.IconNew:GetVisibility() == UE4.ESlateVisibility.Visible and self.SelectPet.PetData.gid == self.PetList.PetData.gid then
    self.IconNew:SetVisibility(UE4.ESlateVisibility.Hidden)
    _G.NRCModuleManager:DoCmd(MiracleExchangeModuleCmd.SetPetNewStateInfo, self.PetList)
  end
  self:SetSelect(_bSelected, self.PetList.IsbMultipleChoice, self.PetList.IsFree)
end

function UMG_MiracleExchange_Main_Item_C:SetData()
  local petList = self.PetList
  self:ShowUpdate()
  if petList and petList.IsHasPet then
    if petList.Icon then
    else
    end
    if petList.IsbMultipleChoice then
      if petList.PetData.IsTeams or petList.banFree and 1 == petList.banFree then
        if petList.PetData.IsTeams and petList.PetData.IsMainTeam then
          self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
          self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Visible)
        elseif petList.PetData.IsTeams then
          self.TagIcon:SetVisibility(UE4.ESlateVisibility.Visible)
          self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
        else
          self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
          self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
        self:SetClickable(false)
        self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
        self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
      else
        self:SetClickable(true)
        self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
        self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
      end
    else
      if petList.PetData.IsOpenTeam then
        if petList.PetData.CanChangeTeam then
          self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
          self.PetLevel_1:SetText(self.PetList.PetData.energy)
        else
        end
        if petList.PetData.IsTeams then
          if petList.PetData.IsMainTeam then
            self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
            self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Visible)
            self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
          else
            self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
          end
        else
          self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
        end
      elseif petList.PetData.IsTeams and petList.PetData.IsMainTeam then
        self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Visible)
      elseif petList.PetData.IsTeams then
        self.TagIcon:SetVisibility(UE4.ESlateVisibility.Visible)
        self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
      else
        self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
        self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
      self:SetClickable(true)
      self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
      self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
    end
    self.ItemIcon:SetPath(NRCUtils:FormatConfIconPath(petList.PetData.PetIcon.icon, _G.UIIconPath.HeadIconPath))
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petList.PetData.BaseConfId)
    UIUtils.GetPetQuality(self.BGColor, petBaseConf.quality)
    self.ItemIcon.OnIconLoaded = self:LoadSuccess(petList.IconListInfo)
    if 4 == petList.PetData.pet_status_flags then
      self.IconNew:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.IconNew:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
    if petList.PetData.IsOpenTeam then
      if petList.PetData.CanChangeTeam == false then
        self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
        self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#FFFFFF7F"))
      else
        self.Lock:SetVisibility(UE4.ESlateVisibility.collapsed)
        self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
        self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
      end
    end
    if petList.PetData.IsTeams or petList.PetData.IsMainTeam then
      self:SetClickable(false)
      self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Visible)
      self.IconNew:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#989898FF"))
      self.TagIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#989898FF"))
      self.TagIcon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#989898FF"))
    else
      self:SetClickable(true)
      self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.IconNew:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
      self.TagIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
      self.TagIcon_1:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
    end
  else
    self:SetClickable(false)
    self:NoPetUpdate()
  end
end

function UMG_MiracleExchange_Main_Item_C:ShowUpdate()
  self:SetClickable(true)
  self.ItemIcon:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
  self.BGColor:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffffff"))
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TheHoodBlack:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.IconNew:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Plus:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Visible)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Visible)
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_MiracleExchange_Main_Item_C:NoPetUpdate()
  self.Plus:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ItemIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TextBG:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.NumText:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TagIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.TagIcon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.BGColor:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_MiracleExchange_Main_Item_C:LoadSuccess(testInfo)
  self.NumText:SetText(testInfo)
end

function UMG_MiracleExchange_Main_Item_C:SetSelect(_flag, bMultipleChoice, _IsFree)
  self:StopAllAnimations()
  if _flag then
    self:PlayAnimation(self.change1)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Visible)
    if not bMultipleChoice or _IsFree then
    else
    end
    goto lbl_30
  else
    self:PlayAnimation(self.change2)
    self.Selected:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  ::lbl_30::
end

function UMG_MiracleExchange_Main_Item_C:OnDeactive()
end

return UMG_MiracleExchange_Main_Item_C
