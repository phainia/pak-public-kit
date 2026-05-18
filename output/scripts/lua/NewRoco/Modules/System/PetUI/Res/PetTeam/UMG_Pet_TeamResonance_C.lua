local UMG_Pet_TeamResonance_C = _G.NRCPanelBase:Extend("UMG_Pet_TeamResonance_C")

function UMG_Pet_TeamResonance_C:OnActive(petTeam)
  self:RefreshUI(petTeam)
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:LoadAnimation(0)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400009, "UMG_Pet_TeamResonance_C:OnCloseBtnClick")
  self.UMG_Common_BIconPar:PlayAnimation(self.UMG_Common_BIconPar.open)
end

function UMG_Pet_TeamResonance_C:OnDeactive()
end

function UMG_Pet_TeamResonance_C:OnAddEventListener()
  self:AddButtonListener(self.BtnClose, self.OnCloseBtnClick)
end

function UMG_Pet_TeamResonance_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Pet_TeamResonance_C:OnDestruct()
end

function UMG_Pet_TeamResonance_C:OnCloseBtnClick()
  if self:IsAnimationPlaying(self.close) then
    return
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(41400010, "UMG_Pet_TeamResonance_C:OnCloseBtnClick")
  self:LoadAnimation(2)
  self.UMG_Common_BIconPar:PlayAnimation(self.UMG_Common_BIconPar.close)
end

function UMG_Pet_TeamResonance_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(2) then
    self:DoClose()
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.RefreshPetTeamPanel)
  elseif Animation == self:GetAnimByIndex(0) then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
  end
end

function UMG_Pet_TeamResonance_C:InitUI()
end

function UMG_Pet_TeamResonance_C:RefreshUI(team)
  local unityTypeDic = {}
  for _, petInfo in ipairs(team.pet_infos) do
    local petData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petInfo.pet_gid)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
    if petBaseConf then
      local unit_types = petBaseConf.unit_type
      for _, unitType in ipairs(unit_types) do
        if nil == unityTypeDic[unitType] then
          unityTypeDic[unitType] = {}
        end
        local reduplicated = false
        local petList = unityTypeDic[unitType]
        for _, t in ipairs(petList) do
          if t.petBaseConf.id == petBaseConf.id then
            reduplicated = true
            break
          end
        end
        if not reduplicated then
          local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
          local t = {
            gid = petInfo.pet_gid,
            petBaseConf = petBaseConf,
            modelConf = modelConf
          }
          table.insert(unityTypeDic[unitType], t)
        end
      end
    end
  end
  local listData = {}
  local allDatas = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.SKILL_COLOR_CONF):GetAllDatas()
  for unit_type, cfg in pairs(allDatas) do
    if unityTypeDic[unit_type] and #unityTypeDic[unit_type] > 0 then
      local t = {
        cfg = cfg,
        pets = unityTypeDic[unit_type] or {}
      }
      table.insert(listData, t)
    end
  end
  table.sort(listData, self.SortFunc)
  self.List:InitGridView(listData)
end

function UMG_Pet_TeamResonance_C:OnScrollCallback()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1083, " UMG_Pet_TeamResonance_C:OnScrollCallback")
end

function UMG_Pet_TeamResonance_C.SortFunc(a, b)
  local a_num = #a.pets
  local b_num = #b.pets
  if a_num == b_num then
    return a.cfg.id < b.cfg.id
  else
    return a_num > b_num
  end
end

return UMG_Pet_TeamResonance_C
