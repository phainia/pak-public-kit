local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local UMG_SelectionOfBranchColleges_C = _G.NRCPanelBase:Extend("UMG_SelectionOfBranchColleges_C")

function UMG_SelectionOfBranchColleges_C:OnActive(NPCAction)
  self.NPCAction = NPCAction
  local CSConf = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.COLLEGE_SELECTION_CONF)
  if CSConf then
    local allConf = CSConf:GetAllDatas()
    local list = {}
    for i, v in pairs(allConf) do
      table.insert(list, {conf = v, parent = self})
    end
    table.sort(list, function(a, b)
      return a.conf.id < b.conf.id
    end)
    for i = 1, #list do
      self.Items[i]:OnShowItemUpdate(list[i], i - 1)
    end
    self.TextDescribe:SetText(LuaText.CollegeSelection_tips)
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(1)
  end
  self:PlayAnimation(self.In)
end

function UMG_SelectionOfBranchColleges_C:OnSelectItem(index, itemData)
  if itemData and itemData.conf then
    self.index = index
    self.curSelectItemData = itemData
    self.TextDescribe:SetText(itemData.conf.text)
    self.NRCSwitcher_Btn:SetActiveWidgetIndex(0)
    for i = 1, #self.Items do
      if i - 1 == index then
        self.Items[i]:OnSelectItem()
      else
        self.Items[i]:OnUnSelectItem()
      end
    end
  end
end

function UMG_SelectionOfBranchColleges_C:OnBtnClick()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_SelectionOfBranchColleges_C:OnBtnClick")
  if self.curSelectItemData == nil then
    return
  end
  self.NRCSwitcher_Btn:SetActiveWidgetIndex(2)
  self:PlayAnimation(self.Out)
end

function UMG_SelectionOfBranchColleges_C:OnDeactive()
end

function UMG_SelectionOfBranchColleges_C:OnAddEventListener()
  self:AddButtonListener(self.JoinBtn.btnLevelUp, self.OnBtnClick)
end

function UMG_SelectionOfBranchColleges_C:OnConstruct()
  self.curSelectItemData = nil
  self:SetChildViews(self.BranchColleges_Item, self.BranchColleges_Item_1, self.BranchColleges_Item_2, self.BranchColleges_Item_3)
  self.Items = {
    self.BranchColleges_Item,
    self.BranchColleges_Item_1,
    self.BranchColleges_Item_2,
    self.BranchColleges_Item_3
  }
  self:OnAddEventListener()
end

function UMG_SelectionOfBranchColleges_C:OnDestruct()
end

function UMG_SelectionOfBranchColleges_C:OnAnimationFinished(Anim)
  if Anim == self.Out and not self.bPaperG6PerformSuccess then
    self:DoSendCollegesChoice()
  end
end

function UMG_SelectionOfBranchColleges_C:PerformPaperG6()
  self.bPaperG6PerformSuccess = self:PerformPaperFlyAway()
  if not self.bPaperG6PerformSuccess then
    Log.Error("UMG_SelectionOfBranchColleges_C:PerformPaperG6 failed")
  end
end

function UMG_SelectionOfBranchColleges_C:PerformPaperFlyAway()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not (localPlayer and localPlayer.viewObj) or not localPlayer.viewObj.RocoSkill then
    return false
  end
  local skillComp = localPlayer.viewObj.RocoSkill
  local skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Scene_CollegeSelected_Paper.G6_Scene_CollegeSelected_Paper", skillComp)
  skill:SetWithLoadAndPlay(true)
  skill:SetCaster(localPlayer.viewObj)
  skill:SetPassive(true)
  skill:RegisterEventCallback("PreEnd", self, self.OnSkillComplete)
  skill:RegisterEventCallback("End", self, self.OnSkillComplete)
  skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupted)
  skill:PlaySkill(self, self.OnSkillStart)
  return true
end

function UMG_SelectionOfBranchColleges_C:OnSkillStart(skill, result)
  if result == UE.ESkillStartResult.Success then
  else
    self:DoSendCollegesChoice()
  end
end

function UMG_SelectionOfBranchColleges_C:OnSkillComplete()
  self:DoSendCollegesChoice()
end

function UMG_SelectionOfBranchColleges_C:OnSkillInterrupted()
  self:DoSendCollegesChoice()
end

function UMG_SelectionOfBranchColleges_C:DoSendCollegesChoice()
  if self.NPCAction and self.curSelectItemData and self.curSelectItemData.conf and self.curSelectItemData.conf.select_to_dialo then
    self.NPCAction:Commit(nil, tostring(self.curSelectItemData.conf.select_to_dialo))
  end
  self:DoClose()
end

return UMG_SelectionOfBranchColleges_C
