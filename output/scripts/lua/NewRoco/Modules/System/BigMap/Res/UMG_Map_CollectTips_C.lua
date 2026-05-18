local UMG_Map_CollectTips_C = _G.NRCPanelBase:Extend("UMG_Map_CollectTips_C")

function UMG_Map_CollectTips_C:OnConstruct()
  self.data = self.module:GetData("BigMapModuleData")
end

function UMG_Map_CollectTips_C:OnActive(areaId)
  self:PlayAnimation(self.Appear)
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "UMG_Map_CollectTips_C:OnActive")
  self.campRefreshId = self.data.AreaIdToRefreshId[areaId]
  self:OnAddEventListener()
  self:UpdatePanelInfo()
end

function UMG_Map_CollectTips_C:OnDeactive()
end

function UMG_Map_CollectTips_C:OnAddEventListener()
  self:AddButtonListener(self.btnCloseTips, self.OnCloseBtnClicked)
end

function UMG_Map_CollectTips_C:OnDestruct()
end

function UMG_Map_CollectTips_C:OnCloseBtnClicked()
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "UMG_Map_CollectTips_C:OnCloseBtnClicked")
  self:PlayAnimation(self.Disappear)
end

function UMG_Map_CollectTips_C:OnPcClose()
  self:OnCloseBtnClicked()
end

function UMG_Map_CollectTips_C:UpdatePanelInfo()
  local exploredInfo = {}
  local campConf = _G.DataConfigManager:GetCampConf(self.campRefreshId)
  if campConf then
    self.Name:SetText(campConf.camp_name)
  end
  local showTable = {}
  for name, value in pairs(Enum.WorldExploringStatisticType) do
    exploredInfo = self.module:GetExploredInfo(self.campRefreshId, value)
    local itemName = ""
    local exploreConf = _G.DataConfigManager:GetWorldExploringStatisticConf(value + 1)
    itemName = exploreConf.display_name
    if exploredInfo then
      if exploreConf.Type ~= Enum.WorldExploringStatisticType.WEST_CHALLENGER then
        if (exploredInfo.total_num or 0) > 0 then
          table.insert(showTable, {
            npc_id = exploredInfo.npc_id,
            belong_camp = exploredInfo.belong_camp,
            exploreType = value,
            exploreName = itemName,
            explore_num = exploredInfo.explore_num,
            total_num = exploredInfo.total_num,
            order = exploreConf.map_order
          })
        end
      else
        local exploreNum = 0
        local totalNum = 0
        local npcId = 0
        for k, val in pairs(exploredInfo) do
          if val then
            local status = self.data.campChallengeNpcInfo[val.npc_id]
            if status == ProtoEnum.LockStatus.ENUM.LOCKED then
              exploreNum = exploreNum + 1
            end
            totalNum = totalNum + 1
            npcId = val.npc_id
          end
        end
        if totalNum > 0 then
          table.insert(showTable, {
            npc_id = npcId,
            belong_camp = self.campRefreshId,
            exploreType = value,
            exploreName = itemName,
            explore_num = exploreNum,
            total_num = totalNum,
            order = exploreConf.map_order
          })
        end
      end
    end
  end
  table.sort(showTable, function(a, b)
    return a.order < b.order
  end)
  self.List:InitList(showTable)
end

function UMG_Map_CollectTips_C:OnAnimationFinished(Anim)
  if Anim == self.Disappear then
    self:DoClose()
  end
end

return UMG_Map_CollectTips_C
