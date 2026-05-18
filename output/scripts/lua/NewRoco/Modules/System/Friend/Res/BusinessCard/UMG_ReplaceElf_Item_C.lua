local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_ReplaceElf_Item_C = Base:Extend("UMG_ReplaceElf_Item_C")

function UMG_ReplaceElf_Item_C:OnConstruct()
end

function UMG_ReplaceElf_Item_C:OnDestruct()
end

function UMG_ReplaceElf_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self:SetInfo()
  self:InitializedInfo()
  if self.data.IsFirst then
    self:SetIsCheck(true)
  end
end

function UMG_ReplaceElf_Item_C:SetInfo()
  local _petInfo = self.data
  if _petInfo and _petInfo.gid and _petInfo.gid > 0 then
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(_petInfo.base_conf_id)
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      if modelConf then
        if PetMutationUtils.GetMutationValue(_petInfo.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) then
          self.HeadPortrait:SetPath(modelConf.shiny_icon)
        elseif PetMutationUtils.GetMutationValue(_petInfo.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS) then
          self.HeadPortrait:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
        else
          self.HeadPortrait:SetPath(NRCUtils:FormatConfIconPath(modelConf.icon, _G.UIIconPath.HeadIconPath))
        end
      end
    end
  else
    Log.Error("PetInfo\230\151\160\230\149\176\230\141\174")
  end
end

function UMG_ReplaceElf_Item_C:InitializedInfo()
  self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_ReplaceElf_Item_C:SetIsCheck(_IsCheck)
  Log.Debug(_IsCheck, "UMG_ReplaceElf_Item_C:SetIsCheck")
  if _IsCheck then
    self.Checked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Checked:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ReplaceElf_Item_C:SetSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Selected)
    self.Select:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.data.IsFirst = false
  else
    self:PlayAnimation(self.UnSelected)
  end
end

function UMG_ReplaceElf_Item_C:OnItemSelected(_bSelected)
  self:SetSelected(_bSelected)
  if _bSelected then
    _G.NRCModeManager:DoCmd(FriendModuleCmd.SelectFavoritePet, self.data)
  end
end

function UMG_ReplaceElf_Item_C:OnAnimationFinished(Anim)
  if Anim == self.UnSelected then
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_ReplaceElf_Item_C:OnDeactive()
end

return UMG_ReplaceElf_Item_C
