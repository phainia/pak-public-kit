local BigMapModuleEvent = reload("NewRoco.Modules.System.BigMap.BigMapModuleEvent")
local UMG_Sanctuary_Tips_C = _G.NRCPanelBase:Extend("UMG_Sanctuary_Tips_C")
local mine = _G.DataConfigManager:GetLocalizationConf("owl_list_mine")
local all = _G.DataConfigManager:GetLocalizationConf("owl_list_all")

function UMG_Sanctuary_Tips_C:OnActive(arg)
  self:OnTooglePanel(arg)
  self.MineFlag = true
  local IsVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  if IsVisit then
    self.CanvasPanel_78:SetVisibility(UE4.ESlateVisibility.Visible)
    if mine and mine.msg then
      self.Sanctuary_TabBtn1:Init(mine.msg)
    end
    if all and all.msg then
      self.Sanctuary_TabBtn2:Init(all.msg)
    end
    self.Sanctuary_TabBtn1.Button.OnClicked:Add(self, self.OnClickMine)
    self.Sanctuary_TabBtn2.Button.OnClicked:Add(self, self.OnClickAll)
  end
end

function UMG_Sanctuary_Tips_C:OnDeactive()
  self.Sanctuary_TabBtn1.Button.OnClicked:Remove(self, self.OnClickMine)
  self.Sanctuary_TabBtn2.Button.OnClicked:Remove(self, self.OnClickAll)
end

function UMG_Sanctuary_Tips_C:OnAddEventListener()
end

function UMG_Sanctuary_Tips_C:OnConstruct()
  self.IsOpenSanctuaryToogle = false
  _G.NRCEventCenter:RegisterEvent("UMG_Sanctuary_Tips_C", self, BigMapModuleEvent.ExcludeUmgPanelEvent, self.ExcludeUmgPanel)
end

function UMG_Sanctuary_Tips_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, BigMapModuleEvent.ExcludeUmgPanelEvent, self.ExcludeUmgPanel)
  if UE4.UObject.IsValid(self.List) then
    local offset = self.List:GetScrollOffset()
    _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.SetSantuaryListOffset, offset)
  end
end

function UMG_Sanctuary_Tips_C:OnClickMine()
  for i = 1, #self.ListDatas do
    self.List:OpItemByIndex(i, 0)
  end
  self.Sanctuary_TabBtn1:PlayAni()
  self.Sanctuary_TabBtn2:StopAni()
end

function UMG_Sanctuary_Tips_C:OnClickAll()
  for i = 1, #self.ListDatas do
    self.List:OpItemByIndex(i, 1)
  end
  self.Sanctuary_TabBtn2:PlayAni()
  self.Sanctuary_TabBtn1:StopAni()
end

function UMG_Sanctuary_Tips_C:OnTooglePanel()
  if self.IsOpenSanctuaryToogle == self.LastOpenSanctuaryToogle then
    return
  end
  self.LastOpenSanctuaryToogle = self.IsOpenSanctuaryToogle
  if self.IsOpenSanctuaryToogle then
    self:OnClosePanel()
  else
    self:OnOpenPanel()
  end
end

function UMG_Sanctuary_Tips_C:OnOpenPanel()
  self.module:OnSelectLastItem()
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  _G.NRCEventCenter:DispatchEvent(BigMapModuleEvent.ExcludeUmgPanelEvent, self.panelName)
  local lst = self:CreateListDatas()
  self.ListDatas = lst
  if 0 == #lst then
    self.IsOpenSanctuaryToogle = true
    self.Switcher:SetActiveWidgetIndex(1)
    return
  end
  self.List:InitList(lst)
  local offset = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetSantuaryListOffset)
  self.List:SetScrollOffset(offset)
  self.Switcher:SetActiveWidgetIndex(0)
  local IsVisit = _G.DataModelMgr.PlayerDataModel:IsVisitState()
  if IsVisit then
    self:PlayAnimation(self.In_online)
    self:OnClickAll()
  else
    self:PlayAnimation(self.In_only)
  end
end

function UMG_Sanctuary_Tips_C:CreateListDatas()
  local dic = self.module.data:GetSanctuaryListDatas()
  if nil == dic then
    return {}
  end
  local list = {}
  local keys = {}
  for key, _ in pairs(dic) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return a < b
  end)
  for _, key in ipairs(keys) do
    table.insert(list, dic[key])
  end
  local finalList = {}
  for _, group in pairs(list) do
    local PlayerDetInfo = false
    for _, owlInfo in pairs(group) do
      for _, playerInfo in pairs(owlInfo) do
        if 1 == playerInfo.unlock then
          PlayerDetInfo = true
          break
        end
      end
      if PlayerDetInfo then
        break
      end
    end
    if PlayerDetInfo then
      table.insert(finalList, group)
    end
  end
  return finalList
end

function UMG_Sanctuary_Tips_C:OnClosePanel()
  if UE4.UObject.IsValid(self.List) then
    local offset = self.List:GetScrollOffset()
    _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.SetSantuaryListOffset, offset)
  end
  self:PlayAnimation(self.Out)
  _G.NRCEventCenter:DispatchEvent(_G.NRCGlobalEvent.CloseOwlTips)
end

function UMG_Sanctuary_Tips_C:ExcludeUmgPanel(name)
  if self.IsOpenSanctuaryToogle == false then
    return
  end
  if name ~= self.panelName then
    self.LastOpenSanctuaryToogle = true
    self:OnClosePanel()
  end
end

function UMG_Sanctuary_Tips_C:OnOffsetList(npcId)
  local conf = _G.DataConfigManager:GetOwlSanctuaryConf(npcId)
  if conf then
    local group = conf.owl_sanctuary_order
    local datas = {}
    if self.ListDatas[group] then
      for i, v in pairs(self.ListDatas[group]) do
        table.insert(datas, v)
      end
      table.sort(datas, function(a, b)
        if a.unlock == b.unlock then
          if (a.fruits and #a.fruits or 0) == (b.fruits and #b.fruits or 0) then
            local fruit_num_a = 0
            local fruit_num_b = 0
            if a.fruits and #a.fruits > 0 then
              for j, fruit in pairs(a.fruits) do
                if 0 ~= fruit.fruit_id then
                  fruit_num_a = fruit_num_a + 1
                end
              end
            end
            if b.fruits and #b.fruits > 0 then
              for j, fruit in pairs(b.fruits) do
                if 0 ~= fruit.fruit_id then
                  fruit_num_b = fruit_num_b + 1
                end
              end
            end
            if fruit_num_a == fruit_num_b then
              return a.conf.id < b.conf.id
            else
              return fruit_num_a > fruit_num_b
            end
          else
            return #a.fruits > #b.fruits
          end
        else
          return a.unlock > b.unlock
        end
      end)
      local index = 0
      for i, v in pairs(datas) do
        if v.conf.id == npcId then
          index = i
          break
        end
      end
      local otherChildCount = 0
      for i = 1, group - 1 do
        local allSanctConfs = self.module.data.owlSanctuaryDatas
        local firstName = ""
        for j, v in pairs(allSanctConfs) do
          if v.owl_sanctuary_order == i then
            firstName = v.first_area_name[1]
            break
          end
        end
        local isToggle = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetSantuaryListState, firstName)
        if isToggle then
          for j, v in pairs(self.ListDatas[i]) do
            otherChildCount = otherChildCount + 1
          end
        end
      end
      local groupFirstName = conf.first_area_name[1]
      local isToggle = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetSantuaryListState, groupFirstName)
      if false == isToggle then
        local item = self.List:GetItemByIndex(group - 1)
        item:OnToogleBtnClicked()
      end
      _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.SetSantuaryListState, groupFirstName, 0)
      local maxCount = index + otherChildCount - 1
      local prantTitleSize = 87
      local childItemSize = 117
      local offset = group * prantTitleSize + maxCount * childItemSize
      self.List:SetScrollOffset(offset)
    end
  end
end

function UMG_Sanctuary_Tips_C:OnAnimationFinished(anim)
  if anim == self.Out then
    self.IsOpenSanctuaryToogle = false
    _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.OnCloseOwlSanctuaryNpcListPanel, self.OpenFlag)
  elseif anim == self.In_online or anim == self.In_only then
    self.IsOpenSanctuaryToogle = true
  end
end

return UMG_Sanctuary_Tips_C
