local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Sanctuary_TipsItem_C = Base:Extend("UMG_Sanctuary_TipsItem_C")

function UMG_Sanctuary_TipsItem_C:OnConstruct()
  self.Button_57.OnClicked:Add(self, self.OnToogleBtnClicked)
  self.IsToggle = false
  self.ToggleCD = false
  self.LastClickTime = 0
  self.CDDuration = 0.5
end

function UMG_Sanctuary_TipsItem_C:OnDestruct()
end

function UMG_Sanctuary_TipsItem_C:OnToogleBtnClicked()
  local currentTime = _G.UE4Helper.GetCurrentWorld():GetTimeSeconds()
  if currentTime - self.LastClickTime < self.CDDuration then
    return
  end
  self.LastClickTime = currentTime
  if self.IsToggle == false then
    self.IsToggle = true
    _G.NRCAudioManager:PlaySound2DAuto(40002010, "UMG_Sanctuary_TipsItem_C:OnToogleBtnClicked")
    _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.SetSantuaryListState, self.firstName, 0)
    self.NRCImage_38:SetRenderScale(UE4.FVector2D(-1, 1))
    self.List:InitGridView(self.datas)
    self.List2:InitGridView(self.AllData)
  else
    self.IsToggle = false
    _G.NRCAudioManager:PlaySound2DAuto(40002009, "UMG_Sanctuary_TipsItem_C:OnToogleBtnClicked")
    _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.SetSantuaryListState, self.firstName, 1)
    self.NRCImage_38:SetRenderScale(UE4.FVector2D(1, -1))
    self.List:Clear()
    self.List2:Clear()
  end
end

function UMG_Sanctuary_TipsItem_C:OnItemUpdate(_data, datalist, index)
  self.OriginalData = _data
  local lstDatas, numerator, denominator = self:CreateChildrenDatas(_data)
  local AlllstDatas, Allnumerator, Alldenominator = self:CreateAllPlayerChildrenDatas(_data)
  if next(lstDatas) and lstDatas[1][1] then
    local firstData = lstDatas[1][1]
    if firstData.conf and next(firstData.conf.first_area_name) then
      self.firstName = firstData.conf.first_area_name[1]
    end
  end
  self.datas = lstDatas
  self.AllData = AlllstDatas
  self.Title:SetText(self.firstName)
  self.ProgressQuantity:SetText(string.format("%d/%d", numerator, denominator))
  self.IsToggle = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetSantuaryListState, self.firstName)
  if self.IsToggle then
    self.NRCImage_38:SetRenderScale(UE4.FVector2D(-1, 1))
    self.List:InitGridView(self.datas)
    self.List2:InitGridView(AlllstDatas)
  else
    self.NRCImage_38:SetRenderScale(UE4.FVector2D(1, -1))
    self.List:Clear()
    self.List2:Clear()
  end
end

function UMG_Sanctuary_TipsItem_C:OpItem(opType, ...)
  self.ListSwitcher:SetActiveWidgetIndex(opType)
  if 0 == opType then
    local lstDatas, numerator, denominator = self:CreateChildrenDatas(self.OriginalData)
    self.firstName = ""
    if lstDatas and lstDatas[1] and lstDatas[1][1] then
      self.firstName = lstDatas[1][1].conf.first_area_name[1]
    end
    self.Title:SetText(self.firstName)
    self.ProgressQuantity:SetText(string.format("%d/%d", numerator, denominator))
    for i = 1, #lstDatas do
      self.List:OpItemByIndex(i, opType)
    end
  elseif 1 == opType then
    local AlllstDatas, Allnumerator, Alldenominator = self:CreateAllPlayerChildrenDatas(self.OriginalData)
    self.firstName = ""
    if AlllstDatas and AlllstDatas[1] and AlllstDatas[1][1] then
      self.firstName = AlllstDatas[1][1].conf.first_area_name[1]
    end
    self.Title:SetText(self.firstName)
    self.ProgressQuantity:SetText(string.format("%d/%d", Allnumerator, Alldenominator))
    for i = 1, #AlllstDatas do
      self.List2:OpItemByIndex(i, opType)
    end
  end
end

function UMG_Sanctuary_TipsItem_C:CreateAllPlayerChildrenDatas(data)
  local allSanctuaryConfs = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetAllOwlSanctuaryConfs)
  local datas = {}
  local numerator = 0
  local denominator = 0
  local groupSort = 0
  for owl_content_id, owlInfo in pairs(data) do
    local unLockFlag = false
    local HasPlayer = {}
    for playerUin, v in pairs(owlInfo) do
      HasPlayer[playerUin] = true
      if 1 == v.unlock then
        unLockFlag = true
      end
    end
    local temp = {}
    for playerUin, v in pairs(owlInfo) do
      if unLockFlag then
        groupSort = v.conf.owl_sanctuary_order
        table.insert(temp, v)
      end
    end
    if unLockFlag then
      local visitors = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
      local firstKey, firstValue = next(HasPlayer)
      for _, v in pairs(visitors) do
        if not HasPlayer[v.uin] then
          local fruits = {}
          local fruit = {
            fruit_active_timestamp = 0,
            fruit_gid = 0,
            fruit_id = 0,
            is_active = false,
            slot_active_timestamp = 0
          }
          table.insert(fruits, fruit)
          if 2 == #owlInfo[firstKey].fruits then
            table.insert(fruits, fruit)
          end
          local visitorInfo = {
            uin = v.uin,
            conf = owlInfo[firstKey].conf,
            contentId = owl_content_id,
            fruits = fruits,
            unlock = 0
          }
          table.insert(temp, visitorInfo)
        end
      end
    end
    if next(temp) then
      table.insert(datas, temp)
    end
    if unLockFlag then
      numerator = numerator + 1
    end
  end
  for i, v in pairs(allSanctuaryConfs) do
    if v.owl_sanctuary_order == groupSort then
      denominator = denominator + 1
    end
  end
  local ownerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin() or 0
  table.sort(datas, function(item_a, item_b)
    item_a.HasFruit = 0
    item_b.HasFruit = 0
    local a = item_a[1]
    local b = item_b[1]
    for _, info in ipairs(item_a) do
      for _, fruit in pairs(info.fruits) do
        if 0 ~= fruit.fruit_id then
          item_a.HasFruit = 1
          break
        end
      end
      if 1 == item_a.HasFruit then
        break
      end
    end
    for _, info in ipairs(item_b) do
      for _, fruit in pairs(info.fruits) do
        if 0 ~= fruit.fruit_id then
          item_b.HasFruit = 1
          break
        end
      end
      if 1 == item_b.HasFruit then
        break
      end
    end
    if item_a.HasFruit == item_b.HasFruit then
      for _, v in pairs(item_a) do
        if v.uin == ownerUin then
          a = v
          break
        end
      end
      for _, v in pairs(item_b) do
        if v.uin == ownerUin then
          b = v
          break
        end
      end
      if a.is_upgrade == b.is_upgrade then
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
          if #a.fruits == #b.fruits then
            return a.conf.id < b.conf.id
          else
            return #a.fruits > #b.fruits
          end
        else
          return fruit_num_a > fruit_num_b
        end
      else
        return a.is_upgrade and not b.is_upgrade
      end
    else
      return item_a.HasFruit > item_b.HasFruit
    end
  end)
  for _, v in pairs(datas) do
    v.HasFruit = nil
  end
  return datas, numerator, denominator
end

function UMG_Sanctuary_TipsItem_C:CreateChildrenDatas(data)
  local allSanctuaryConfs = _G.NRCModeManager:DoCmd(_G.BigMapModuleCmd.GetAllOwlSanctuaryConfs)
  local datas = {}
  local numerator = 0
  local denominator = 0
  local groupSort = 0
  local ownerUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin() or 0
  for owl_content_id, owlInfo in pairs(data) do
    local PlayerDetInfo = false
    local temp = {}
    for playerUin, v in pairs(owlInfo) do
      groupSort = v.conf.owl_sanctuary_order
      if playerUin == ownerUin and 1 == v.unlock then
        table.insert(temp, v)
        PlayerDetInfo = true
        break
      end
    end
    if next(temp) then
      table.insert(datas, temp)
    end
    if PlayerDetInfo then
      numerator = numerator + 1
    end
  end
  for i, v in pairs(allSanctuaryConfs) do
    if v.owl_sanctuary_order == groupSort then
      denominator = denominator + 1
    end
  end
  table.sort(datas, function(item_a, item_b)
    item_a.HasFruit = 0
    item_b.HasFruit = 0
    local a = item_a[1]
    local b = item_b[1]
    for _, info in ipairs(item_a) do
      for _, fruit in pairs(info.fruits) do
        if 0 ~= fruit.fruit_id then
          item_a.HasFruit = 1
          break
        end
      end
      if 1 == item_a.HasFruit then
        break
      end
    end
    for _, info in ipairs(item_b) do
      for _, fruit in pairs(info.fruits) do
        if 0 ~= fruit.fruit_id then
          item_b.HasFruit = 1
          break
        end
      end
      if 1 == item_b.HasFruit then
        break
      end
    end
    if item_a.HasFruit == item_b.HasFruit then
      for _, v in pairs(item_a) do
        if v.uin == ownerUin then
          a = v
          break
        end
      end
      for _, v in pairs(item_b) do
        if v.uin == ownerUin then
          b = v
          break
        end
      end
      if a.is_upgrade == b.is_upgrade then
        if #a.fruits == #b.fruits then
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
        return a.is_upgrade and not b.is_upgrade
      end
    else
      return item_a.HasFruit > item_b.HasFruit
    end
  end)
  for _, v in pairs(datas) do
    v.HasFruit = nil
  end
  return datas, numerator, denominator
end

function UMG_Sanctuary_TipsItem_C:OnItemSelected(_bSelected)
  if not _bSelected and self.datas then
    for i = 1, #self.datas do
      self.List:OpItemByIndex(i, 2)
      self.List2:OpItemByIndex(i, 2)
    end
  end
end

function UMG_Sanctuary_TipsItem_C:OnDeactive()
end

function UMG_Sanctuary_TipsItem_C:OnAnimationFinished(anim)
end

return UMG_Sanctuary_TipsItem_C
