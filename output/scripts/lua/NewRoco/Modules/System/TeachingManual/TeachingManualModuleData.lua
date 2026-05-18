local TeachingManualModuleData = _G.NRCData:Extend("TeachingManualModuleData")

function TeachingManualModuleData:Ctor()
  NRCData.Ctor(self)
  self.SelectTeachManualIndex = 0
  self.TeachManualData = {}
  self.NewDataTableIndex = -1
end

function TeachingManualModuleData:InitializeInfo(ModuleCaller, ModuleCallBack, needOpenNew, teachId)
  table.clear(self.TeachManualList)
  local teachConf = _G.DataConfigManager:GetAllByName("TEACH_TAB_CONF")
  self.TeachManualList = {}
  for _ = 1, #teachConf do
    table.insert(self.TeachManualList, {
      TeachIndex = -1,
      TeachList = {},
      ScrollOffset = 0
    })
  end
  for _, index in ipairs(teachConf) do
    self:ScreenListByTeachGuideType(index.type)
  end
  if needOpenNew and self.TeachManualData and #self.TeachManualData > 0 then
    self:SortTeachData(self.TeachManualData)
    if teachId then
      for i, data in ipairs(self.TeachManualData) do
        if data.teach_id == teachId then
          local dataRec = self.TeachManualData[i]
          table.remove(self.TeachManualData, i)
          table.insert(self.TeachManualData, 1, dataRec)
        end
      end
    end
    local TeachConf = _G.DataConfigManager:GetTeachConf(self.TeachManualData[1].teach_id)
    if not TeachConf then
      Log.Error(self.TeachManualData[1].teach_id, "\228\184\141\229\173\152\229\156\168")
    else
      local newTeachList = self.TeachManualList[TeachConf.list_type].TeachList
      for i = 1, #newTeachList do
        if newTeachList[i].TeachList.id == self.TeachManualData[1].teach_id then
          self.TeachManualList[TeachConf.list_type].TeachIndex = i - 1
          break
        end
      end
      self.NewDataTableIndex = TeachConf.list_type
    end
  end
  if ModuleCaller then
    ModuleCallBack(ModuleCaller)
  end
end

function TeachingManualModuleData:IsPCMode()
  if RocoEnv.IS_EDITOR then
    return _G.GlobalConfig.bEditorAsPcInTeachManual or false
  else
    return RocoEnv.PLATFORM == "PLATFORM_WINDOWS"
  end
end

function TeachingManualModuleData:ScreenListByTeachGuideType(_TeachGuideType)
  if self.TeachManualData and #self.TeachManualData > 0 then
    for i, Teach in pairs(self.TeachManualData) do
      local TeachConf = _G.DataConfigManager:GetTeachConf(Teach.teach_id)
      if not TeachConf then
        Log.Error(Teach.teach_id, "teach_id\228\184\141\229\173\152\229\156\168")
      elseif TeachConf.list_type == _TeachGuideType then
        if not TeachConf.teach_platform or TeachConf.teach_platform == Enum.Teachplatform.PLAT_ALL or TeachConf.teach_platform == Enum.Teachplatform.PLAT_PC and self:IsPCMode() or TeachConf.teach_platform == Enum.Teachplatform.PLAT_MOBILE and not self:IsPCMode() then
          table.insert(self.TeachManualList[_TeachGuideType].TeachList, {
            TeachList = TeachConf,
            Unlock_Time = Teach.unlock_time,
            Status = Teach.status
          })
        end
        if TeachConf.teach_platform == Enum.Teachplatform.PLAT_PC and not self:IsPCMode() then
          _G.NRCModeManager:DoCmd(RedPointModuleCmd.InvalidPointData, 220, {
            TeachConf.list_type,
            Teach.teach_id
          })
        end
        if TeachConf.teach_platform == Enum.Teachplatform.PLAT_MOBILE and self:IsPCMode() then
          _G.NRCModeManager:DoCmd(RedPointModuleCmd.InvalidPointData, 220, {
            TeachConf.list_type,
            Teach.teach_id
          })
        end
      end
    end
    self:SortTeachList(self.TeachManualList[_TeachGuideType].TeachList)
  end
end

function TeachingManualModuleData:SetSelectTeachManualTab(_SelectTeachManualIndex)
  self.SelectTeachManualIndex = _SelectTeachManualIndex
end

function TeachingManualModuleData:SetCurTeachManualScrollOffset(ScrollOffset)
  if self.TeachManualList and self.TeachManualList[self.SelectTeachManualIndex] then
    self.TeachManualList[self.SelectTeachManualIndex].ScrollOffset = ScrollOffset
  end
end

function TeachingManualModuleData:GetSelectTeachManualIndex()
  return self.SelectTeachManualIndex
end

function TeachingManualModuleData:GetManualListByTeachManualIndex(_SelectTeachManualIndex)
  return self.TeachManualList[_SelectTeachManualIndex]
end

function TeachingManualModuleData:SortTeachList(TeachList)
  table.sort(TeachList, function(a, b)
    if a.TeachList.id < b.TeachList.id then
      return a.TeachList.id < b.TeachList.id
    end
  end)
end

function TeachingManualModuleData:SortTeachData(TeachDataList)
  table.sort(TeachDataList, function(a, b)
    return a.unlock_time > b.unlock_time
  end)
end

function TeachingManualModuleData:InitializeListSelect()
  self.SelectTeachManualIndex = 0
  for i, TeachManual in ipairs(self.TeachManualList) do
    TeachManual.TeachIndex = -1
  end
end

function TeachingManualModuleData:SetTeachSelectIndex(_TeachGuideType, _SelectIndex)
  self.TeachManualList[_TeachGuideType].TeachIndex = _SelectIndex - 1
end

return TeachingManualModuleData
