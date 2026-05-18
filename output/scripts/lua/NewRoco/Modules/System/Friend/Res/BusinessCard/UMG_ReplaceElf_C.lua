local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_ReplaceElf_C = _G.NRCPanelBase:Extend("UMG_ReplaceElf_C")

function UMG_ReplaceElf_C:OnConstruct()
  self:SetChildViews(self.PopUp3)
  self.data = self.module:GetData("FriendModuleData")
  self:OnAddEventListener()
end

function UMG_ReplaceElf_C:OnDestruct()
end

function UMG_ReplaceElf_C:OnActive(_data)
  self:AddPcInputBlock()
  self.In = self:GetAnimByIndex(0)
  self.Loop = self:GetAnimByIndex(1)
  self.Out = self:GetAnimByIndex(2)
  self.FavoriteData = _data
  self.data:SetCardFavoriteData(_data)
  self:SetCommonPopUpInfo()
  self:SetPanelInfo()
  self:PlayAnimation(self.In)
  _G.NRCAudioManager:PlaySound2DAuto(41400007, "UMG_ReplaceElf_C:OnActive")
end

local function SortPetList(a, b)
  if a.IsFirst then
    return true
  end
  if b.IsFirst then
    return false
  end
  local AHandBookId = _G.DataConfigManager:GetPetbaseConf(a.base_conf_id).pictorial_book_id
  local BHandBookId = _G.DataConfigManager:GetPetbaseConf(b.base_conf_id).pictorial_book_id
  if AHandBookId ~= BHandBookId then
    return AHandBookId > BHandBookId
  else
    return a.base_conf_id > b.base_conf_id
  end
end

function UMG_ReplaceElf_C:SetPanelInfo()
  self.firstSelectItem = false
  local PetDataList = _G.DataModelMgr.PlayerDataModel:GetPetDataByDepartment(self.FavoriteData.SystemType.id)
  if PetDataList then
    self.PetNum = #PetDataList
    for i, PetData in ipairs(PetDataList) do
      if self.FavoriteData.CardFavorite and PetData.base_conf_id == self.FavoriteData.CardFavorite.pet_base_id and self:CheckPetDataMutationType(PetData) then
        PetDataList[i].IsFirst = true
        self.firstSelectItem = true
        break
      end
    end
  end
  if PetDataList then
    table.sort(PetDataList, SortPetList)
  end
  if PetDataList and #PetDataList > 0 then
    self.List_4:InitGridView(PetDataList)
    for i = 1, #PetDataList do
      if PetDataList[i].IsFirst then
        self.List_4:SelectItemByIndex(i - 1)
      end
    end
    self.Switcher:SetActiveWidgetIndex(0)
    self.PopUp3:SetDescInfo(string.format(LuaText.rolecard_favourite_pets_replace_tips, self.FavoriteData.SystemType.short_name))
  else
    self.Switcher:SetActiveWidgetIndex(1)
    self.PopUp3:SetDescInfo(LuaText.rolecard_favourite_pets_empty_bottom)
  end
  self.UMG_StudentCard_Item_104:SetReplaceElfHead(self.FavoriteData)
  self.NRCTitle_2:SetText(string.format(LuaText.rolecard_favourite_pets_replace_title, self.FavoriteData.SystemType.short_name))
  self.NRCText_54:SetText(string.format(LuaText.rolecard_favourite_pets_empty, self.FavoriteData.SystemType.short_name))
end

function UMG_ReplaceElf_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Btn_LeftText = LuaText.rolecard_favourite_pets_close_btn
  CommonPopUpData.Btn_RightText = LuaText.rolecard_favourite_pets_show_btn
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_LeftHandler = self.OnCloseBtn
  CommonPopUpData.Btn_RightHandler = self.OnClickBtn3
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp3:SetPanelInfo(CommonPopUpData)
  self.PopUp3:SetTitleTextInfo()
end

function UMG_ReplaceElf_C:OnDeactive()
  self:RemovePcInputBlock()
end

function UMG_ReplaceElf_C:AddPcInputBlock()
end

function UMG_ReplaceElf_C:RemovePcInputBlock()
end

function UMG_ReplaceElf_C:OnAddEventListener()
  self:RegisterEvent(self, FriendModuleEvent.SelectFavoritePet, self.OnSelectFavoritePet)
  self.ScrollBox_0.OnUserScrolled:Add(self, self.OnUserScrolledInfo)
end

function UMG_ReplaceElf_C:OnPcClose()
  self:OnCloseBtn()
end

function UMG_ReplaceElf_C:OnUserScrolledInfo(Offset)
end

function UMG_ReplaceElf_C:OnSelectFavoritePet()
  if self.firstSelectItem then
    self.firstSelectItem = false
  else
    _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ReplaceElf_C:OnActive")
  end
  local PetData = self.data:GetFavoritePet()
  if self.FavoriteData.CardFavorite then
    if PetData.base_conf_id == self.FavoriteData.CardFavorite.pet_base_id then
      if self:CheckPetDataMutationType(PetData) then
        self.PopUp3:SetBtnRightText(LuaText.rolecard_favourite_pets_offload_btn)
      else
        self.PopUp3:SetBtnRightText(LuaText.rolecard_favourite_pets_show_btn)
      end
    else
      self.PopUp3:SetBtnRightText(LuaText.rolecard_favourite_pets_show_btn)
    end
  else
    self.PopUp3:SetBtnRightText(LuaText.rolecard_favourite_pets_show_btn)
  end
end

function UMG_ReplaceElf_C:OnCloseBtn()
  Log.Dump(self.Out, 3, "UMG_ReplaceElf_C:OnCloseBtn")
  _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_ReplaceElf_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_ReplaceElf_C:OnClickBtn3()
  local PetData = self.data:GetFavoritePet()
  if not PetData then
    _G.NRCAudioManager:PlaySound2DAuto(41400008, "UMG_ReplaceElf_C:OnActive")
    self:PlayAnimation(self.Out)
    return
  end
  if self.FavoriteData.CardFavorite then
    if PetData.base_conf_id == self.FavoriteData.CardFavorite.pet_base_id then
      if self:CheckPetDataMutationType(PetData) then
        _G.NRCModeManager:DoCmd(FriendModuleCmd.SetFavoritePet, false)
      else
        _G.NRCModeManager:DoCmd(FriendModuleCmd.SetFavoritePet, true)
      end
    else
      _G.NRCModeManager:DoCmd(FriendModuleCmd.SetFavoritePet, true)
    end
  else
    _G.NRCModeManager:DoCmd(FriendModuleCmd.SetFavoritePet, true)
  end
  _G.NRCAudioManager:PlaySound2DAuto(40002006, "UMG_ReplaceElf_C:OnActive")
  self:PlayAnimation(self.Out)
end

function UMG_ReplaceElf_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    self:DoClose()
  elseif Anim == self.In then
    self:PlayAnimation(self.Loop)
  end
end

function UMG_ReplaceElf_C:CheckPetDataMutationType(PetData)
  local isShine = (PetMutationUtils.GetMutationValue(PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING) or PetUtils.CheckIsCHAOS(PetData.mutation_type)) and PetMutationUtils.GetMutationValue(self.FavoriteData.CardFavorite.mutation_diff_type, _G.Enum.MutationDiffType.MDT_SHINING)
  local isNormal = PetData.mutation_type == _G.Enum.MutationDiffType.MDT_NONE and self.FavoriteData.CardFavorite.mutation_diff_type == _G.Enum.MutationDiffType.MDT_NONE
  return isShine or isNormal
end

return UMG_ReplaceElf_C
