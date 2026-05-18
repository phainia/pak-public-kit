local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local MainUIModuleEvent = reload("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local UMG_HavingAward_C = _G.NRCViewBase:Extend("UMG_HavingAward_C")

function UMG_HavingAward_C:OnConstruct()
  self:SetChildViews(self.UMG_HavingFitTogether)
  local icon1 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_kong_png.img_kong_png'"
  local icon2 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lv_png.img_lv_png'"
  local icon3 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lan_png.img_lan_png'"
  local icon4 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_zi_png.img_zi_png'"
  local icon5 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_cheng_png.img_cheng_png'"
  self.bgIcon = {
    icon1,
    icon2,
    icon3,
    icon4,
    icon5
  }
  self.uiData = {}
  self.subPanels = {
    self.CanvasPanel_par,
    self.UMG_HavingFitTogether
  }
  self:OnAddEventListener()
  self.UMG_HavingFitOpne = false
  self.haveGoodDada = nil
end

function UMG_HavingAward_C:OnDestruct()
  table.clear(self.bgIcon)
  table.clear(self.uiData)
  table.clear(self.subPanels)
  self:OnRemoveEventListener()
end

function UMG_HavingAward_C:OnActive()
end

function UMG_HavingAward_C:OnDeactive()
end

function UMG_HavingAward_C:OnAddEventListener()
  self:AddButtonListener(self.BtnSwich, self.BtnSwichClick)
  self:RegisterEvent(self, PetUIModuleEvent.AUTO_SUPPLY_CARRYON, self.OnAutoSupplyChangeSuccess)
end

function UMG_HavingAward_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, PetUIModuleEvent.AUTO_SUPPLY_CARRYON)
end

function UMG_HavingAward_C:SetSubPanelVisible(_index)
  for panelIndex, subPanel in pairs(self.subPanels) do
    if subPanel then
      if _index == panelIndex then
        subPanel:SetVisibility(UE4.ESlateVisibility.Visible)
      else
        subPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
    end
  end
  if 2 == _index then
    self.UMG_HavingFitOpen = true
  else
    self.UMG_HavingFitOpen = false
  end
end

function UMG_HavingAward_C:OnPanelStateChange(_isShow)
  self.uiData.isPanelShow = _isShow
  if _isShow then
    if self.uiData.petData ~= nil then
      self.uiData.petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(self.uiData.petData.gid)
    end
    self:SetSubPanelVisible(1)
    self:ShowPetInfo()
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
    self:DispatchEvent(PetUIModuleEvent.Hide_CloseBtn, true)
  end
end

function UMG_HavingAward_C:updatePetInfo(_petData, _petBaseConf)
  if self.uiData.petData ~= nil and self.uiData.petData.gid ~= _petData.gid then
    self.haveGoodDada = nil
    self:SetSubPanelVisible(1)
  end
  self.uiData.petData = _petData
  self.uiData.petBaseConf = _petBaseConf
  if self.UMG_HavingFitOpen == false then
    self:ShowPetInfo()
  end
end

function UMG_HavingAward_C:ShowPetInfo()
  if self.uiData.isPanelShow then
    local data = self:GetPetPossessionData(self.uiData.petData)
    self:GoodDataHasChange(data)
    self.List_1:InitGridView(data)
    local effectData = self:GetEffectDatas()
    self.haveSkillOrAttrData = effectData
    self.ListEffect:InitGridView(effectData)
    self:SetSwich(self.uiData.petData.possession.auto_supply)
  end
end

function UMG_HavingAward_C:GoodDataHasChange(data)
  if self.UMG_HavingFitOpen == true and self.haveGoodDada then
    for i = 1, #data do
      if i <= #self.haveGoodDada then
        local item = data[i]
        if item.open and item.possessionItem then
          local oldData = self.haveGoodDada[i]
          if not oldData.open or item.possessionItem.conf_id ~= oldData.possessionItem.conf_id then
            item.playAnima = true
          end
        end
      end
    end
  end
  self.haveGoodDada = data
end

function UMG_HavingAward_C:GetPetPossessionData(petData)
  local conf = _G.DataConfigManager:GetPetGlobalConfig("pet_max_equip_num")
  local items = petData.possession.item
  local maxNum = conf.num
  local PossessionData = {}
  for i = 1, maxNum do
    local data = {}
    data.callbackCaller = self
    data.callbackFunc = self.OnClickHavingItem
    data.pos = i
    data.bgIcon = self.bgIcon
    if i <= #items then
      data.open = true
      data.possessionItem = items[i]
    else
      data.breakData = self:GetPetBreakData(petData, i)
    end
    table.insert(PossessionData, data)
  end
  return PossessionData
end

function UMG_HavingAward_C:GetPetBreakData(petData, index)
  local initConf = _G.DataConfigManager:GetPetGlobalConfig("pet_initial_equip_num")
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local break_awardConf = _G.DataConfigManager:GetBreakRewardConf(petBaseConf.break_award_sort)
  local brekNum = self:GetbreakthroughNum()
  local num = initConf.num
  for i = 1, #break_awardConf.break_award do
    local item = break_awardConf.break_award[i]
    num = num + item.is_slot_add
    if index <= num then
      local breakData = {}
      breakData.conf = item
      breakData.breakOpenIndex = i
      if i <= brekNum then
        breakData.open = true
      else
        breakData.open = false
      end
      return breakData
    end
  end
end

function UMG_HavingAward_C:GetbreakthroughNum()
  local PetData = self.uiData.petData
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
  local break_awardConf = _G.DataConfigManager:GetBreakRewardConf(petBaseConf.break_award_sort)
  for i = 1, #break_awardConf.break_award do
    local item = break_awardConf.break_award[i]
    if PetData.last_breakthrough_lv >= item.break_level_point then
      return i
    end
  end
  return 0
end

function UMG_HavingAward_C:GetEffectDatas()
  local havegoodata = self.haveGoodDada
  local datas = {}
  for i = 1, #havegoodata do
    local item = havegoodata[i]
    if item.open and item.possessionItem.conf_id ~= nil then
      local conf = _G.DataConfigManager:GetPetCarryonItem(item.possessionItem.conf_id)
      for j = 1, #conf.carryon_effect do
        local carryoneffect = {}
        carryoneffect.conf = conf
        carryoneffect.carryoneffect = conf.carryon_effect[j]
        carryoneffect.UMG_HavingFitOpen = self.UMG_HavingFitOpen
        carryoneffect.gid = self.uiData.petData.gid
        carryoneffect.playAnima = item.playAnima
        table.insert(datas, carryoneffect)
      end
    end
  end
  return datas
end

function UMG_HavingAward_C:OnClickHavingItem(pos)
  self.selectpos = pos
  self:ShowSelectProssessiong()
end

function UMG_HavingAward_C:ShowSelectProssessiong()
  if self.selectpos == nil then
    return
  end
  local data = {}
  data.petgid = self.uiData.petData.gid
  data.pos = self.selectpos
  data.callbackCaller = self
  data.callbackFunc = self.UMG_HavingFitTogetherClose
  data.petData = self.uiData.petData
  self.UMG_HavingFitTogether:UpdatePetInfo(data)
  self:SetSubPanelVisible(2)
end

function UMG_HavingAward_C:UMG_HavingFitTogetherClose()
  self:ShowPetInfo()
  self:SetSubPanelVisible(1)
end

function UMG_HavingAward_C:BtnSwichClick()
  local flag = self.uiData.petData.possession.auto_supply
  if nil == flag then
    flag = false
  end
  if true == flag then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1006, "UMG_HavingAward_C:BtnSwichClick1")
    flag = false
  else
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_HavingAward_C:BtnSwichClick2")
    flag = true
  end
  NRCModuleManager:DoCmd(PetUIModuleCmd.AutoSupplyCarryon, self.uiData.petData.gid, flag)
end

function UMG_HavingAward_C:OnAutoSupplyChangeSuccess(_changes)
  local flag = self.uiData.petData.possession.auto_supply
  if true == flag then
    self.uiData.petData.possession.auto_supply = false
  else
    flag = true
    self.uiData.petData.possession.auto_supply = true
  end
  self:SetSwich(self.uiData.petData.possession.auto_supply)
end

function UMG_HavingAward_C:SetSwich(flag)
  if true == flag then
    self.NRCSwitcher_p:SetActiveWidgetIndex(1)
  else
    self.NRCSwitcher_p:SetActiveWidgetIndex(0)
  end
end

return UMG_HavingAward_C
