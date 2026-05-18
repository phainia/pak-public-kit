local BattlePassModuleEvent = require("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_EvolutionaryChainPanel_C = _G.NRCPanelBase:Extend("UMG_EvolutionaryChainPanel_C")

function UMG_EvolutionaryChainPanel_C:OnConstruct()
  self.IconDic = {}
  self.allNodeDic = {}
  self.allGroupDic = {}
  self.maxEvoStage = 0
  self.maxEvoNodeCount = 0
  self.nodeNumber = 0
  self.lastSelectPetId = nil
  self.isShowBoss = false
  self.leftOffset = 100
  self.ScreenSize = UE4.FVector2D(2340, 1080)
  self.WidthRatio = 10
  self:OnAddEventListener()
end

function UMG_EvolutionaryChainPanel_C:OnActive(petbaseId, unLock, isShining)
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.OnShowEvolutionaryBtn, false)
  local conf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  self.isShining = isShining
  if conf and conf.relate_boss_id and 0 ~= conf.relate_boss_id then
    petbaseId = conf.relate_boss_id
  end
  local selectedPetId = petbaseId
  self.isUnlock = unLock
  petbaseId = self:GetPetBaseId(petbaseId)
  self:SetPetEvoDatas(petbaseId)
  self:SetIcons()
  self:SetLines()
  self:OnChangeItemSelectState(selectedPetId)
  self:PlayAnimation(self.In)
  self:SetTitle(selectedPetId)
end

function UMG_EvolutionaryChainPanel_C:GetPetBaseId(petbaseId)
  local conf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  if conf.bosspetbase_id_arry and #conf.bosspetbase_id_arry > 0 then
    return petbaseId
  else
    local petbaseConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PETBASE_CONF)
    local petbaseConfs = petbaseConf:GetAllDatas()
    for i, v in pairs(petbaseConfs) do
      if v.bosspetbase_id_arry and #v.bosspetbase_id_arry > 0 then
        for j, w in pairs(v.bosspetbase_id_arry) do
          if w == petbaseId then
            return v.id
          end
        end
      end
    end
  end
  return petbaseId
end

function UMG_EvolutionaryChainPanel_C:SetPetEvoDatas(petbaseId)
  local evoDataGroupList = {}
  if self.EvoConfs == nil then
    local EvoConf = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_EVOLUTION_CONF)
    if EvoConf then
      self.EvoConfs = EvoConf:GetAllDatas()
    end
  end
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  if nil == petbaseConf or nil == petbaseConf.pet_evolution_id or nil == petbaseConf.pet_evolution_id[1] then
    Log.Error(petbaseId, "petbaseconf error")
    return nil
  end
  local evoId = petbaseConf.pet_evolution_id[1]
  local handbookEvoGroup = self.EvoConfs[evoId] and self.EvoConfs[evoId].handbook_evolution_group or 0
  if 0 == handbookEvoGroup then
    Log.Error(petbaseId, evoId, "evoconf not handbook_evolution_group")
    return nil
  end
  for i, v in pairs(self.EvoConfs) do
    if v.handbook_evolution_group == handbookEvoGroup then
      table.insert(evoDataGroupList, v)
    end
  end
  self:CreateDataDic(evoDataGroupList)
  self:SetBossNodeData()
  self:SetNodeDatas()
  self:SetOneNodeData()
end

function UMG_EvolutionaryChainPanel_C:CreateDataDic(confs)
  local nodeData = require("NewRoco.Modules.System.BattlePass.NodeData")
  local groupData = require("NewRoco.Modules.System.BattlePass.GroupData")
  self.allNodeDic = {}
  self.allGroupDic = {}
  self.maxEvoStage = 0
  self.nodeNumber = 0
  for i, evoConf in pairs(confs) do
    for j = 1, #evoConf.evolution_chain do
      local chain = evoConf.evolution_chain[j]
      if self.maxEvoStage < chain.stage then
        self.maxEvoStage = chain.stage
      end
      if chain then
        local node, group
        if self.allNodeDic[chain.stage] == nil then
          self.allNodeDic[chain.stage] = {}
        end
        if nil == self.allNodeDic[chain.stage][chain.petbase_id] then
          node = nodeData.New()
          self.allNodeDic[chain.stage][chain.petbase_id] = node
          self.nodeNumber = self.nodeNumber + 1
        else
          node = self.allNodeDic[chain.stage][chain.petbase_id]
        end
        node.evolutionStage = chain.stage
        node.petbaseId = chain.petbase_id
        node.unLock = self.isUnlock
        local idx = 1 == #evoConf.evolution_chain and 1 or j - 1
        if evoConf.evolution_chain[idx] ~= nil then
          local groupId = evoConf.evolution_chain[idx].petbase_id
          if self.allGroupDic[chain.stage] == nil then
            self.allGroupDic[chain.stage] = {}
          end
          if self.allGroupDic[chain.stage][groupId] == nil then
            self.allGroupDic[chain.stage][groupId] = {}
            group = groupData.New()
            group.groupId = groupId
            group.evolutionStage = chain.stage
            self.allGroupDic[chain.stage][groupId] = group
          else
            group = self.allGroupDic[chain.stage][groupId]
          end
          table.insert(group.groupNodes, node)
          table.insert(node.parentbaseIds, groupId)
        end
      end
    end
  end
end

function UMG_EvolutionaryChainPanel_C:GetBossMaxEvoNodeCount()
  local groups = self.allGroupDic[self.maxEvoStage]
  local MaxEvoNodeCount = 0
  if groups then
    for _, group in pairs(groups) do
      if #group.groupNodes > 0 then
        for _, node in pairs(group.groupNodes) do
          local bossIds = self:GetBossIdArry(node:GetPetbascConf())
          if bossIds and #bossIds > 0 then
            for _, v in pairs(bossIds) do
              MaxEvoNodeCount = MaxEvoNodeCount + 1
            end
          end
        end
      end
    end
  end
  return MaxEvoNodeCount
end

function UMG_EvolutionaryChainPanel_C:SetBossNodeData()
  local groups = self.allGroupDic[self.maxEvoStage]
  local bossStage = self.maxEvoStage + 1
  local bossMaxEvoNodeCount = self:GetBossMaxEvoNodeCount()
  if groups then
    local idx = 0
    for _, group in pairs(groups) do
      if #group.groupNodes > 0 then
        for _, node in pairs(group.groupNodes) do
          local bossIds = self:GetBossIdArry(node:GetPetbascConf())
          if bossIds and #bossIds > 0 then
            self.isShowBoss = true
            for _, v in pairs(bossIds) do
              local bossId = v
              if bossId then
                local interval_y = self.ScreenSize.Y / (bossStage + 1)
                local nodeData = require("NewRoco.Modules.System.BattlePass.NodeData")
                local bossNode = nodeData.New()
                idx = idx + 1
                local maxEvoNodeCount = bossMaxEvoNodeCount
                local interval_x = self.ScreenSize.X / (maxEvoNodeCount + 1)
                local offset_x = 0
                if maxEvoNodeCount < 9 then
                  interval_x = self.ScreenSize.X / self.WidthRatio
                  local length = maxEvoNodeCount * interval_x
                  offset_x = (self.ScreenSize.X - length - interval_x) / 2 + self.leftOffset
                end
                local bossPos = UE4.FVector2D(offset_x + interval_x * idx, interval_y * bossStage)
                bossNode.evolutionStage = bossStage
                bossNode.petbaseId = bossId
                bossNode:SetPos(bossPos.X, bossPos.Y)
                bossNode.unLock = self.isUnlock
                bossNode:SetIsBoss(true)
                table.insert(bossNode.parentbaseIds, node.petbaseId)
                if self.allNodeDic[bossStage] == nil then
                  self.allNodeDic[bossStage] = {}
                end
                self.allNodeDic[bossStage][bossId] = bossNode
                local bossGroup
                if self.allGroupDic[bossStage] == nil then
                  self.allGroupDic[bossStage] = {}
                end
                if self.allGroupDic[bossStage][node.petbaseId] == nil then
                  self.allGroupDic[bossStage][node.petbaseId] = {}
                  local groupData = require("NewRoco.Modules.System.BattlePass.GroupData")
                  bossGroup = groupData.New()
                  bossGroup.groupId = node.petbaseId
                  bossGroup.evolutionStage = bossStage
                  bossGroup.groupNodes = {bossNode}
                  self.allGroupDic[bossStage][node.petbaseId] = bossGroup
                else
                  bossGroup = self.allGroupDic[bossStage][node.petbaseId]
                  table.insert(bossGroup.groupNodes, bossNode)
                end
              end
            end
          end
        end
      end
    end
  end
end

function UMG_EvolutionaryChainPanel_C:SetNodeDatas()
  self.maxEvoNodeCount = 0
  local nodes = self.allNodeDic[self.maxEvoStage]
  for id, node in pairs(nodes) do
    self.maxEvoNodeCount = self.maxEvoNodeCount + 1
  end
  local interval_y = self.isShowBoss and self.ScreenSize.Y / (self.maxEvoStage + 2) or self.ScreenSize.Y / (self.maxEvoStage + 1)
  local interval_x = self.ScreenSize.X / (self.maxEvoNodeCount + 1)
  local offset_x = 0
  if self.maxEvoNodeCount >= 9 then
    self.WidthRatio = 11
  end
  interval_x = self.ScreenSize.X / self.WidthRatio
  local length = self.maxEvoNodeCount * interval_x
  offset_x = (self.ScreenSize.X - length - interval_x) / 2 + self.leftOffset
  for i = self.maxEvoStage, 1, -1 do
    local groups = self.allGroupDic[i]
    local idx = 0
    if groups then
      for _, groupData in pairs(groups) do
        if self.maxEvoStage == i then
          for _, nodeData in pairs(groupData.groupNodes) do
            idx = idx + 1
            local x = offset_x + interval_x * idx
            local y = interval_y * nodeData.evolutionStage
            nodeData:SetPos(x, y)
          end
        end
        local parentId = groupData.groupId
        local parentStage = i - 1
        if self.allNodeDic[parentStage] and self.allNodeDic[parentStage][parentId] then
          local parentNode = self.allNodeDic[parentStage][parentId]
          local parentX = groupData:GetParentNodeCenterX()
          local parentY = interval_y * parentStage
          parentNode:SetPos(parentX, parentY)
        end
      end
    end
  end
end

function UMG_EvolutionaryChainPanel_C:SetOneNodeData()
  if 1 == self.nodeNumber then
    local nodes = self.allNodeDic[self.maxEvoStage]
    for i, node in pairs(nodes) do
      local y = self.ScreenSize.Y / 2
      if self.isShowBoss then
        y = self.ScreenSize.Y / 3
      end
      node:SetPos(self.ScreenSize.X / 2 + self.leftOffset, y)
    end
    return
  end
end

function UMG_EvolutionaryChainPanel_C:GetBossIdArry(petbaseConf)
  local array = petbaseConf.bosspetbase_id_arry or {}
  local dic = {}
  local lst = {}
  for i, baseId in pairs(array) do
    if nil == dic[baseId] then
      dic[baseId] = true
    end
  end
  for key, v in pairs(dic) do
    table.insert(lst, key)
  end
  return lst
end

function UMG_EvolutionaryChainPanel_C:SetIcons()
  for _, nodes in pairs(self.allNodeDic) do
    for _, node in pairs(nodes) do
      local iconWidget = self:CreateIconWidget()
      self.IconDic[node.petbaseId] = iconWidget
      iconWidget.Slot:SetPosition(node.pos)
      iconWidget:SetData(node, self.isShining)
    end
  end
end

function UMG_EvolutionaryChainPanel_C:SetLines()
  self.LineList = {}
  for Stage, nodes in pairs(self.allNodeDic) do
    for _, node in pairs(nodes) do
      if node.petbaseId and 0 ~= node.petbaseId then
        local parentIds = node.parentbaseIds
        if parentIds and self.allNodeDic[Stage - 1] then
          for i = 1, #parentIds do
            local parentId = parentIds[i]
            local parentNode = self.allNodeDic[Stage - 1][parentId]
            local lineLength = self:GetDistance(node.pos, parentNode.pos)
            local lineAngle = self:GetAngle(node.pos, parentNode.pos)
            local isLineDotted = true
            if parentNode:GetHandbookState() == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED and node:GetHandbookState() == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
              isLineDotted = false
            end
            local lineWidget = self:CreateLineWidget(node.pos, isLineDotted)
            table.insert(self.LineList, lineWidget)
            lineWidget:SetLine(lineLength, lineAngle)
          end
        end
      end
    end
  end
end

function UMG_EvolutionaryChainPanel_C:GetDistance(curPos, tarPos)
  local dx = tarPos.X - curPos.X
  local dy = tarPos.Y - curPos.Y
  return math.sqrt(dx * dx + dy * dy)
end

function UMG_EvolutionaryChainPanel_C:GetAngle(curPos, tarPos)
  local function atan2(y, x)
    if x > 0 then
      return math.atan(y / x)
    elseif x < 0 then
      return math.atan(y / x) + math.pi * (y >= 0 and 1 or -1)
    elseif y > 0 then
      return math.pi / 2
    elseif y < 0 then
      return -math.pi / 2
    else
      return 0
    end
  end
  
  local dx = tarPos.X - curPos.X
  local dy = tarPos.Y - curPos.Y
  local angle_rad = atan2(dy, dx)
  local angle_deg = angle_rad * 180 / math.pi
  if angle_deg < 0 then
    angle_deg = angle_deg + 360
  end
  return angle_deg
end

function UMG_EvolutionaryChainPanel_C:OnDeactive()
  _G.NRCEventCenter:UnRegisterEvent(self, BattlePassModuleEvent.UpdateSelectPetData, self.OnClickPetTreeItem)
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.OnShowEvolutionaryBtn, true)
end

function UMG_EvolutionaryChainPanel_C:OnAddEventListener()
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnCloseBtnClick)
  self:AddButtonListener(self.CloseBtn2, self.OnCloseBtnClick)
  _G.NRCEventCenter:RegisterEvent("UMG_EvolutionaryChainPanel_C", self, BattlePassModuleEvent.UpdateSelectPetData, self.OnClickPetTreeItem)
end

function UMG_EvolutionaryChainPanel_C:OnCloseBtnClick()
  if self:IsAnimationPlaying(self.Out) then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_EvolutionaryChainPanel_C:OnCloseBtnClick")
  self:PlayAnimation(self.Out)
  for i, item in pairs(self.IconDic) do
    item:PlayOutAnimation()
  end
  if self.LineList and #self.LineList > 0 then
    for i, item in pairs(self.LineList) do
      item:PlayOutAnimation()
    end
  end
end

function UMG_EvolutionaryChainPanel_C:OnClickPetTreeItem(petbaseId)
  self:OnCloseBtnClick()
end

function UMG_EvolutionaryChainPanel_C:SetTitle(petbaseId)
  local titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  local petbaseConf = _G.DataConfigManager:GetPetbaseConf(petbaseId)
  self.Title1.MainTitle:SetText(titleConf.title)
  self.Title1.Subtitle:SetText(petbaseConf.name)
end

function UMG_EvolutionaryChainPanel_C:OnChangeItemSelectState(petbaseId)
  if self.lastSelectPetId == petbaseId then
    return
  end
  if self.IconDic[petbaseId] then
    self.IconDic[petbaseId]:PlaySelectAnimation()
  end
  if self.lastSelectPetId then
    self.IconDic[self.lastSelectPetId]:PlayNomarlAnimation()
  end
  self.lastSelectPetId = petbaseId
end

function UMG_EvolutionaryChainPanel_C:CreateIconWidget()
  local iconWidget, iconSlot
  local scale = 200
  iconWidget = UE4.UWidgetBlueprintLibrary.Create(self, self.ChainIcon)
  if iconWidget then
    iconSlot = self.CanvasPanel_32:AddChild(iconWidget)
    iconSlot:SetAnchors(UE4.FAnchors(0.5))
    iconSlot:SetAlignment(UE4.FVector2D(0.5, 0.5))
    iconSlot:SetAutoSize(true)
    iconSlot:SetSize(UE4.FVector2D(scale, scale))
    iconSlot:SetZOrder(1)
    return iconWidget
  end
end

function UMG_EvolutionaryChainPanel_C:CreateLineWidget(pos, isLineDotted)
  local lineWidget, lineSlot
  local scale = 100
  lineWidget = nil
  if isLineDotted then
    lineWidget = UE4.UWidgetBlueprintLibrary.Create(self, self.ChainLine1)
  else
    lineWidget = UE4.UWidgetBlueprintLibrary.Create(self, self.ChainLine)
  end
  if lineWidget then
    lineSlot = self.CanvasPanel_32:AddChild(lineWidget)
    lineSlot:SetPosition(pos)
    lineSlot:SetAnchors(UE4.FAnchors(0.5))
    lineSlot:SetAlignment(UE4.FVector2D(0.5, 0.5))
    lineSlot:SetAutoSize(true)
    lineSlot:SetSize(UE4.FVector2D(scale, scale))
    return lineWidget
  end
end

function UMG_EvolutionaryChainPanel_C:OnAnimationFinished(aim)
  if aim == self.Out then
    self:DoClose()
  end
end

return UMG_EvolutionaryChainPanel_C
