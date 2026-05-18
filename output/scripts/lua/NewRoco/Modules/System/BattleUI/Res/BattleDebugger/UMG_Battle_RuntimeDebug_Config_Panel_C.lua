local UMG_Battle_RuntimeDebug_Config_Panel_C = _G.NRCPanelBase:Extend("UMG_Battle_RuntimeDebug_Config_Panel_C")

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnConstruct()
  self.debugControl = _G.BattleManager.battleRuntimeData.battleDebugControl
  self.CheckBoxMale:SetCheckedState(1)
  self.CheckBoxShowHp:SetCheckedState(0)
  self.ComboBoxNPC:ClearOptions()
  self:FilterNpc()
  self.ComboBoxNPC:SetSelectedIndex(0)
  self.ComboBoxNPC.OnOpening:Add(self, self.FilterNpc)
  for i, v in pairs(self.debugControl.BattleTypeName) do
    self.ComboBoxStringBattleType:AddOption(v)
  end
  for i, v in pairs(self.debugControl.BattlePosCache) do
    self.ComboBoxStringPosition:AddOption(i)
  end
  self.ComboBoxStringPosition.OnSelectionChanged:Add(self, self.OnSelectPos)
  self.NRCButtonEnterBattle.OnClicked:Add(self, self.EnterBattle)
  local tempList = self.debugControl:GetTempList()
  for i, v in pairs(tempList) do
    self.ComboBoxStringTemplate:AddOption(v)
  end
  self.ComboBoxStringTemplate.OnSelectionChanged:Add(self, self.OnSelectTemp)
  self.NRCButtonSaveTemp.OnClicked:Add(self, self.SaveTemplate)
  self.CloseButton.OnClicked:Add(self, self.OnCloseClick)
  self.List_title_1:InitList({
    true,
    true,
    true,
    true,
    true,
    true
  })
  self.List_title:InitList({
    false,
    false,
    false,
    false,
    false,
    false
  })
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnActive(...)
  local temp = self.debugControl.cacheBattleParams
  if not temp then
    local defaultTemp = "DefaultTemp"
    if 0 == #self.debugControl.tempList then
      temp = self.debugControl:GetTestData()
      self.debugControl:SaveTemplate(defaultTemp, temp)
    else
      self.ComboBoxStringTemplate:SetSelectedOption(defaultTemp)
      return
    end
  end
  self:ApplyTempData(temp)
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnDestruct()
  self.ComboBoxStringTemplate.OnSelectionChanged:Remove(self, self.OnSelectTemp)
  self.ComboBoxStringPosition.OnSelectionChanged:Remove(self, self.OnSelectPos)
  self.ComboBoxNPC.OnOpening:Remove(self, self.FilterNpc)
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:FilterNpc()
  local npcList = self.debugControl:GetAllNpcList()
  local filter = self.EditableTextBoxNpc:GetText()
  for i, v in pairs(npcList) do
    if string.IsNilOrEmpty(filter) or v:find(filter) then
      if self.ComboBoxNPC:FindOptionIndex(v) < 0 then
        self.ComboBoxNPC:AddOption(v)
      end
    elseif self.ComboBoxNPC:FindOptionIndex(v) >= 0 then
      self.ComboBoxNPC:RemoveOption(v)
    end
  end
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnCloseClick()
  self:DoClose()
  if _G.AppMain:HasDebug() then
    NRCModeManager:DoCmd(DebugModuleCmd.OpenOrClosePanel, true)
  end
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:EnterBattle()
  local BattleDebugParam = self:FormatToBattleDebugParam()
  self.debugControl:EnterDebugBattle(BattleDebugParam)
  Log.Dump(BattleDebugParam, 3, "UMG_Battle_RuntimeDebug_Config_Panel_C:EnterBattle")
  self:DoClose()
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:FormatToBattleDebugParam()
  local BattleDebugParam = {}
  local battleType = self.ComboBoxStringBattleType:GetSelectedOption()
  BattleDebugParam.battleType = self.debugControl.BattleType[battleType]
  local positionTemp = self.ComboBoxStringPosition:GetSelectedOption()
  BattleDebugParam.battlePosTempName = positionTemp
  local position = self.debugControl.BattlePosCache[positionTemp]
  if "\232\191\155\233\153\132\232\191\145\230\136\152\230\150\151" == positionTemp then
    local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    local PlayerLocation = player.viewObj:Abs_K2_GetActorLocation()
    position = {
      x = math.floor(PlayerLocation.X),
      y = math.floor(PlayerLocation.Y),
      z = math.floor(PlayerLocation.Z)
    }
  end
  local positionStr = self.EditableTextBoxPosition:GetText()
  if not string.IsNilOrEmpty(positionStr) then
    local posVecs = string.Split(positionStr, ",")
    if #posVecs < 3 then
      posVecs = string.Split(positionStr, ";")
    end
    if 3 == #posVecs then
      position.x = math.floor(tonumber(posVecs[1]))
      position.y = math.floor(tonumber(posVecs[2]))
      position.z = math.floor(tonumber(posVecs[3]))
    end
  end
  BattleDebugParam.battlePos = position
  Log.Debug("FormatToBattleDebugParam ", BattleDebugParam.battlePos.x, BattleDebugParam.battlePos.y, BattleDebugParam.battlePos.z)
  local isShowHP = self.CheckBoxShowHp:IsChecked()
  BattleDebugParam.isShowHP = isShowHP
  local isMale = self.CheckBoxMale:IsChecked()
  BattleDebugParam.player_team = {}
  BattleDebugParam.player_team.playerSex = isMale
  for i = 1, self.List_title_1:GetItemCount() do
    local item = self.List_title_1:GetItemByIndex(i - 1)
    BattleDebugParam.player_team["pet" .. i] = item:GetSelectOption()
  end
  local npc = self.ComboBoxNPC:GetSelectedOption()
  BattleDebugParam.enemy_team = {}
  BattleDebugParam.enemy_team.npcName = npc
  for i = 1, self.List_title:GetItemCount() do
    local item = self.List_title:GetItemByIndex(i - 1)
    BattleDebugParam.enemy_team["pet" .. i] = item:GetSelectOption()
  end
  return BattleDebugParam
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:SaveTemplate()
  local tempName = self.EditableTextBoxTempName:GetText()
  if not string.IsNilOrEmpty(tempName) then
    local BattleDebugParam = self:FormatToBattleDebugParam()
    BattleDebugParam.name = tempName
    self.debugControl:SaveTemplate(tempName, BattleDebugParam)
  end
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnSelectTemp(SelectedItem, SelectionType)
  local temp = self.debugControl:GetTempByTempName(self.ComboBoxStringTemplate:GetSelectedOption())
  self:ApplyTempData(temp)
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:ApplyTempData(temp)
  self.ComboBoxStringBattleType:SetSelectedIndex(temp.battleType - 1)
  self.ComboBoxStringPosition:SetSelectedOption(temp.battlePosTempName)
  self.CheckBoxShowHp:SetCheckedState(temp.isShowHP and 1 or 0)
  self.CheckBoxMale:SetCheckedState(temp.player_team.playerSex and 1 or 0)
  for i = 1, self.List_title_1:GetItemCount() do
    local item = self.List_title_1:GetItemByIndex(i - 1)
    item:SetSelectOption(temp.player_team["pet" .. i])
  end
  self.ComboBoxNPC:SetSelectedOption(temp.enemy_team.npcName)
  for i = 1, self.List_title:GetItemCount() do
    local item = self.List_title:GetItemByIndex(i - 1)
    item:SetSelectOption(temp.enemy_team["pet" .. i])
  end
end

function UMG_Battle_RuntimeDebug_Config_Panel_C:OnSelectPos(SelectedItem, SelectionType)
  self.EditableTextBoxPosition:SetText("")
end

return UMG_Battle_RuntimeDebug_Config_Panel_C
