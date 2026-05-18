local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_PetEvolutionTask_C = _G.NRCPanelBase:Extend("UMG_PetEvolutionTask_C")

function UMG_PetEvolutionTask_C:OnConstruct()
  self.uiData = {}
  self.uiItem = {}
end

function UMG_PetEvolutionTask_C:OnDestruct()
  table.clear(self.uiData)
  table.clear(self.uiItem)
  self.uiData = nil
  self.uiItem = nil
end

function UMG_PetEvolutionTask_C:OnActive(_param, ...)
  _G.NRCPanelBase.OnActive(self, _param, ...)
  local uiData = self.uiData
  uiData.petData = _param.petData
  uiData.petBaseConf = _param.petBaseConf
  uiData.curEvolutionIndex = _param.curEvolutionIndex
  self:OnAddEventListener()
  self:updatePanelInfo()
end

function UMG_PetEvolutionTask_C:OnDeactive()
end

function UMG_PetEvolutionTask_C:OnAddEventListener()
  self:AddButtonListener(self.btnCancel, self.OnBtnCancelClick)
  self:AddButtonListener(self.btnOK, self.OnBtnOKClick)
end

function UMG_PetEvolutionTask_C:OnRemoveEventListener()
end

function UMG_PetEvolutionTask_C:updatePanelInfo()
  local uiData = self.uiData
  local petData = uiData.petData
  local curPetBaseConf = uiData.petBaseConf
  local curEvolutionIndex = uiData.curEvolutionIndex
  if not (curPetBaseConf and curPetBaseConf.evolution_pet_id) or not curEvolutionIndex then
    return
  end
  local evolutionPetId = curPetBaseConf.evolution_pet_id[curEvolutionIndex]
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(evolutionPetId)
  if not petBaseConf then
    return
  end
  
  local function getTaskDesc(_taskId)
    if _taskId > 0 then
      local taskInfo = _G.DataConfigManager:GetTaskConf(_taskId)
      if taskInfo and taskInfo.paragraph_id and taskInfo.paragraph_id > 0 then
        local pgCfg = _G.DataConfigManager:GetParagraphConf(taskInfo.paragraph_id)
        if pgCfg and pgCfg.description then
          return pgCfg.description
        end
      end
    end
    return ""
  end
  
  self.Panel_Desc1:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self.Panel_Desc2:SetVisibility(UE4.ESlateVisibility.Hidden)
  if petBaseConf then
    self.taskTitle:SetText(string.format(LuaText.umg_petevolutiontask_1, petBaseConf.name))
    self.taskDesc1:SetText(getTaskDesc(petBaseConf.evolution_task_id))
  else
    self.taskTitle:SetText("")
    self.taskDesc1:SetText("")
  end
end

function UMG_PetEvolutionTask_C:OnBtnCancelClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_PetEvolutionTask_C:OnBtnCancelClick")
  self:DoClose()
end

function UMG_PetEvolutionTask_C:OnBtnOKClick()
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1008, "UMG_PetEvolutionTask_C:OnBtnOKClick")
  local uiData = self.uiData
  local petData = uiData.petData
  local taskId = petData.evolution_task
  _G.NRCModuleManager:DoCmd(TaskModuleCmd.setTrack, taskId, true)
  self:DoClose()
  _G.NRCModuleManager:DoCmd(MainUIModuleCmd.ClosePanelGameInfo)
end

return UMG_PetEvolutionTask_C
