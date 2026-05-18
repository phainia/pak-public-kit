require("UnLuaEx")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local ServerData = require("Common.LocalServer.LocalBattleRSPTable")
local UMG_LocalBattle_Debug_Panel_C = _G.NRCPanelBase:Extend("UMG_LocalBattle_Debug_Panel_C")

function UMG_LocalBattle_Debug_Panel_C:CheckSkillRes()
  local data = ""
  for _, v in ipairs(self.sortSkills) do
    if not v.Exist and v.Conf.res_id then
      local line = string.format("\230\163\128\230\181\139\230\138\128\232\131\189\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168  \230\138\128\232\131\189ID:%d   \232\181\132\230\186\144\232\183\175\229\190\132:%s", v.Conf.id, v.Conf.res_id)
      data = data .. line .. "\n"
      Log.Debug(line)
    end
  end
  self:SaveToFile(data, "CheckSkill")
end

function UMG_LocalBattle_Debug_Panel_C:CheckBuffRes()
  local data = ""
  for _, v in ipairs(self.sortBuffs) do
    local buff = v.Conf
    local line = ""
    if buff.res_id_0 and UE4.UNRCStatics.CheckAssetExists(buff.res_id_0) then
      line = string.format("\230\163\128\230\181\139buff\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168  \230\138\128\232\131\189ID:%d   \232\181\132\230\186\144\232\183\175\229\190\132:%s  \233\133\141\231\189\174\229\156\168 res_id_0", buff.id, buff.res_id_0)
    elseif buff.res_id_1 and UE4.UNRCStatics.CheckAssetExists(buff.res_id_1) then
      line = string.format("\230\163\128\230\181\139buff\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168  \230\138\128\232\131\189ID:%d   \232\181\132\230\186\144\232\183\175\229\190\132:%s  \233\133\141\231\189\174\229\156\168 res_id_1", buff.id, buff.res_id_1)
    elseif buff.res_id_2 and UE4.UNRCStatics.CheckAssetExists(buff.res_id_2) then
      line = string.format("\230\163\128\230\181\139buff\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168  \230\138\128\232\131\189ID:%d   \232\181\132\230\186\144\232\183\175\229\190\132:%s  \233\133\141\231\189\174\229\156\168 res_id_2", buff.id, buff.res_id_2)
    end
    if "" ~= line then
      data = data .. line .. "\n"
      Log.Debug(line)
    end
  end
  self:SaveToFile(data, "CheckBuff")
end

function UMG_LocalBattle_Debug_Panel_C:SaveToFile(Content, FileName)
  local File = string.format("%s%s.txt", UE4.UBlueprintPathsLibrary.ProjectSavedDir(), FileName)
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  os.remove(File)
  local Success = UE4.UNRCStatics.WriteToFile(File, Content)
  return Success
end

function UMG_LocalBattle_Debug_Panel_C:LoadOnly()
  UE4.USkillRecordLibrary.StartRecord()
  for _, v in pairs(self.sortSkills) do
    UE4.USkillRecordLibrary.AnalyzeSkill(v.Conf.res_id)
  end
  for _, v in pairs(self.sortBuffs) do
    UE4.USkillRecordLibrary.AnalyzeSkill(v.Conf.res_id)
  end
  UE4.USkillRecordLibrary.StopRecord()
end

function UMG_LocalBattle_Debug_Panel_C:LoadUnloadRecord()
  UE4.USkillRecordLibrary.StartRecord()
  for _, v in pairs(self.sortSkills) do
    UE4.USkillRecordLibrary.AnalyzeSkill(v.Conf.res_id)
    UE4.USkillRecordLibrary.ReleaseSkill(v.Conf.res_id)
  end
  for _, v in pairs(self.sortBuffs) do
    UE4.USkillRecordLibrary.AnalyzeSkill(v.Conf.res_id)
    UE4.USkillRecordLibrary.ReleaseSkill(v.Conf.res_id)
  end
  UE4.USkillRecordLibrary.StopRecord()
end

function UMG_LocalBattle_Debug_Panel_C:UnloadAll()
  Log.Error("Unload ALL")
  for _, v in pairs(self.sortSkills) do
    UE4.USkillRecordLibrary.ReleaseSkill(v.Conf.res_id)
  end
end

function UMG_LocalBattle_Debug_Panel_C:OnConstruct()
  self.OpenBtn.OnClicked:Add(self, self.OnBtnOpenClick)
  self.ComboBoxTarget_0.OnSelectionChanged:Add(self, self.ChangePlayerSelectedPet)
  self.ComboBoxTarget_1.OnSelectionChanged:Add(self, self.ChangeEnemySelectedPet)
  self.ComboBoxString.OnSelectionChanged:Add(self, self.PlayerSkillChange)
  self.ComboBoxString_2.OnSelectionChanged:Add(self, self.EnemySkillChange)
  self.ComboBoxString_0.OnSelectionChanged:Add(self, self.PlayerPetChange)
  self.ComboBoxString_1.OnSelectionChanged:Add(self, self.EnemyPetChange)
  self.ComboBoxStringBuff_0.OnSelectionChanged:Add(self, self.PlayerBuffChange)
  self.ComboBoxStringBuff_1.OnSelectionChanged:Add(self, self.EnemyBuffChange)
  self.ComboBoxString.OnOpening:Add(self, self.FilterMySkill)
  self.ComboBoxString_2.OnOpening:Add(self, self.FilterEnemySkill)
  self.ComboBoxString_0.OnOpening:Add(self, self.FilterMyPet)
  self.ComboBoxString_1.OnOpening:Add(self, self.FilterEnemyPet)
  self.ComboBoxStringBuff_0.OnOpening:Add(self, self.FilterMyBuff)
  self.ComboBoxStringBuff_1.OnOpening:Add(self, self.FilterEnemyBuff)
  self.CatchButton.OnClicked:Add(self, self.OnCatchButton)
  self.AutoPlayButton.OnCheckStateChanged:Add(self, self.CheckStateChanged)
  self.EnemyAutoPlayButton.OnCheckStateChanged:Add(self, self.CheckStateChanged)
  self.AutoPlayButtonBuff_0.OnCheckStateChanged:Add(self, self.CheckStateChanged)
  self.AutoPlayButtonBuff_1.OnCheckStateChanged:Add(self, self.CheckStateChanged)
  self.EnablePATButton.OnCheckStateChanged:Add(self, self.OnPatChange)
  self.RecordSkillButton.OnCheckStateChanged:Add(self, self.OnSkillRecordChange)
  self.DebugButton1.OnClicked:Add(self, self.LoadOnly)
  self.DebugButton2.OnClicked:Add(self, self.LoadUnloadRecord)
  self.DebugButton1_1.OnClicked:Add(self, self.CheckSkillRes)
  self.DebugButton1_2.OnClicked:Add(self, self.CheckBuffRes)
  self.BattleManager = _G.BattleManager
  self.PawnManager = self.BattleManager.battlePawnManager
  _G.BattleEventCenter:Bind(self, BattleEvent.ROUND_STATE_SELECT)
  self.autoShow = true
  self.playerPlayed = false
  self.autoPlaying = false
  self.LastSkillPath = ""
  ServerData.LoadProto()
  if ServerData.values.battleMode == "single" or ServerData.values.battleMode == "bossfight" then
    self.TextBlock_17:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.TextBlock_16:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ComboBoxTarget_0:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ComboBoxTarget_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  ServerData.values.CurSelectedPetPlayer = 1
  ServerData.values.CurSelectedPetEnemy = 401
  ServerData.AutoTestOver = false
  self.AutoPlayCombo = {}
  table.insert(self.AutoPlayCombo, self.ComboBoxString)
  table.insert(self.AutoPlayCombo, self.ComboBoxString_2)
  table.insert(self.AutoPlayCombo, self.ComboBoxStringBuff_0)
  table.insert(self.AutoPlayCombo, self.ComboBoxStringBuff_1)
  self.LastPlayedId = 1
end

function UMG_LocalBattle_Debug_Panel_C:StartRecord()
  UE4.USkillRecordLibrary.StartRecord()
end

function UMG_LocalBattle_Debug_Panel_C:EndRecord()
  UE4.USkillRecordLibrary.StopRecord()
end

function UMG_LocalBattle_Debug_Panel_C:OnDestruct()
  self.OpenBtn.OnClicked:Remove(self, self.OnBtnOpenClick)
  self.ComboBoxString.OnSelectionChanged:Remove(self, self.PlayerSkillChange)
  self.ComboBoxString_2.OnSelectionChanged:Remove(self, self.EnemySkillChange)
  self.ComboBoxString_0.OnSelectionChanged:Remove(self, self.PlayerPetChange)
  self.ComboBoxString_1.OnSelectionChanged:Remove(self, self.EnemyPetChange)
  self.ComboBoxStringBuff_0.OnSelectionChanged:Remove(self, self.PlayerBuffChange)
  self.ComboBoxStringBuff_1.OnSelectionChanged:Remove(self, self.EnemyBuffChange)
  self.AutoPlayButton.OnCheckStateChanged:Remove(self, self.CheckStateChanged)
  self.EnemyAutoPlayButton.OnCheckStateChanged:Remove(self, self.CheckStateChanged)
  self.AutoPlayButtonBuff_0.OnCheckStateChanged:Remove(self, self.CheckStateChanged)
  self.AutoPlayButtonBuff_1.OnCheckStateChanged:Remove(self, self.CheckStateChanged)
  self.RecordStartButton.OnClicked:Remove(self, self.StartRecord)
  self.RecordEndButton.OnClicked:Remove(self, self.EndRecord)
  self.DebugButton1.OnClicked:Remove(self, self.LoadOnly)
  self.DebugButton2.OnClicked:Remove(self, self.LoadUnloadRecord)
  self.DebugButton3.OnClicked:Remove(self, self.UnloadAll)
  self.CatchButton.OnClicked:Remove(self, self.OnCatchButton)
  self.ComboBoxString.OnOpening:Remove(self, self.FilterMySkill)
  self.ComboBoxString_2.OnOpening:Remove(self, self.FilterEnemySkill)
  self.ComboBoxString_0.OnOpening:Remove(self, self.FilterMyPet)
  self.ComboBoxString_1.OnOpening:Remove(self, self.FilterEnemyPet)
  self.ComboBoxStringBuff_0.OnOpening:Remove(self, self.FilterMyBuff)
  self.ComboBoxStringBuff_1.OnOpening:Remove(self, self.FilterEnemyBuff)
  _G.BattleEventCenter:UnBind(self)
  self.PATEnable = false
end

function UMG_LocalBattle_Debug_Panel_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.ROUND_STATE_SELECT then
    self:DelayAutoShow()
    return true
  end
end

function UMG_LocalBattle_Debug_Panel_C:DelayAutoShow()
  _G.DelayManager:DelaySeconds(1, self.ShowAuto, self)
  local playerPet = self.BattleManager.vBattleField.BattlePawnManager.playerTeam.pets[1].model
  local enemyPet = self.BattleManager.vBattleField.BattlePawnManager.enemyTeam.pets[1].model
  local playerSkillComponent = playerPet:GetComponentByClass(UE4.USkillComponent)
  local enemySkillComponent = enemyPet:GetComponentByClass(UE4.USkillComponent)
  playerSkillComponent:ClearAllPassiveSkillObjs()
  enemySkillComponent:ClearAllPassiveSkillObjs()
  playerSkillComponent:ReleaseForLua()
  enemySkillComponent:ReleaseForLua()
end

function UMG_LocalBattle_Debug_Panel_C:ShowAuto()
  if self.autoShow then
    self:Show()
  end
  self.OpenBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self:DelayAutoPlaySkill()
end

function UMG_LocalBattle_Debug_Panel_C:OnPatChange()
  if self.EnablePATButton:GetCheckedState() == UE4.ECheckBoxState.Checked then
    UE4.USkillRecordLibrary.EnablePat()
  else
    UE4.USkillRecordLibrary.DisablePat()
  end
end

function UMG_LocalBattle_Debug_Panel_C:OnSkillRecordChange()
  if self.RecordSkillButton:GetCheckedState() == UE4.ECheckBoxState.Checked then
    self:StartRecord()
  else
    self:EndRecord()
  end
end

function UMG_LocalBattle_Debug_Panel_C:CheckStateChanged()
  if self.AutoPlayButton:GetCheckedState() ~= UE4.ECheckBoxState.Checked and self.EnemyAutoPlayButton:GetCheckedState() ~= UE4.ECheckBoxState.Checked and self.AutoPlayButtonBuff_0:GetCheckedState() ~= UE4.ECheckBoxState.Checked and self.AutoPlayButtonBuff_1:GetCheckedState() ~= UE4.ECheckBoxState.Checked then
    return
  end
  if not self.autoPlaying then
    self:AutoPlaySkill()
  end
end

function UMG_LocalBattle_Debug_Panel_C:DelayAutoPlaySkill()
  UE4.USkillRecordLibrary.ReleaseSkill(self.LastSkillPath)
  _G.DelayManager:DelaySeconds(2, self.AutoPlaySkill, self)
end

function UMG_LocalBattle_Debug_Panel_C:AutoPlaySkill()
  local playerAutoPlay = self.AutoPlayButton:GetCheckedState() == UE4.ECheckBoxState.Checked
  local enemyAutoPlay = self.EnemyAutoPlayButton:GetCheckedState() == UE4.ECheckBoxState.Checked
  local playerAutoPlayBuff = self.AutoPlayButtonBuff_0:GetCheckedState() == UE4.ECheckBoxState.Checked
  local EnemyAutoPlayBuff = self.AutoPlayButtonBuff_1:GetCheckedState() == UE4.ECheckBoxState.Checked
  local AutoList = {}
  table.insert(AutoList, playerAutoPlay)
  table.insert(AutoList, enemyAutoPlay)
  table.insert(AutoList, playerAutoPlayBuff)
  table.insert(AutoList, EnemyAutoPlayBuff)
  local fxPerfStartCmd = string.format("FxPerf.Start")
  local fxPerfStopCmd = string.format("FxPerf.Stop")
  if playerAutoPlay then
    UE4.UNRCStatics.ExecConsoleCommand(fxPerfStartCmd)
  else
    UE4.UNRCStatics.ExecConsoleCommand(fxPerfStopCmd)
  end
  local CurrentPlayedId = self.LastPlayedId
  for i = CurrentPlayedId + 1, CurrentPlayedId + 5 do
    local RealPlayId = i
    if RealPlayId >= 5 then
      RealPlayId = i - 4
    end
    if true == AutoList[RealPlayId] and self.AutoPlayCombo[RealPlayId]:GetSelectedIndex() < self.AutoPlayCombo[RealPlayId]:GetOptionCount() - 1 then
      self:ComboBoxAdvance(self.AutoPlayCombo[RealPlayId])
      self.autoPlaying = true
      ServerData.AutoTestOver = false
      self.LastPlayedId = RealPlayId
      return
    end
  end
  self.autoPlaying = false
  ServerData.AutoTestOver = true
end

function UMG_LocalBattle_Debug_Panel_C:OnActive()
  self.DebugPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.OpenBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ComboBoxTarget_0Op = {}
  self.ComboBoxTarget_1Op = {}
  self.ComboBoxString_0Op = {}
  self.ComboBoxStringOp = {}
  self.ComboBoxString_2Op = {}
  self.ComboBoxStringBuff_0Op = {}
  self.ComboBoxStringBuff_1Op = {}
  self.ComboBoxString_1Op = {}
  self.ComboBoxTarget_0Op["\228\189\141\231\189\1741"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_TEAM, 1)
  self.ComboBoxTarget_0Op["\228\189\141\231\189\1742"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_TEAM, 2)
  self.ComboBoxTarget_1Op["\228\189\141\231\189\1741"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_ENEMY, 1)
  self.ComboBoxTarget_1Op["\228\189\141\231\189\1742"] = ServerData.GetPetGuidByPos(BattleEnum.Team.ENUM_ENEMY, 2)
  self.ComboBoxTarget_0:AddOption("\228\189\141\231\189\1741")
  self.ComboBoxTarget_0:AddOption("\228\189\141\231\189\1742")
  self.ComboBoxTarget_1:AddOption("\228\189\141\231\189\1741")
  self.ComboBoxTarget_1:AddOption("\228\189\141\231\189\1742")
  self.ComboBoxTarget_0:SetSelectedIndex(0)
  self.ComboBoxTarget_1:SetSelectedIndex(0)
  self.sortPets = {}
  local AllPet = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.PET_CONF):GetAllDatas()
  for _, v in pairs(AllPet) do
    local PetBase = _G.DataConfigManager:GetPetbaseConf(v.base_id)
    local Model = PetBase and _G.DataConfigManager:GetModelConf(PetBase.model_conf)
    if Model then
      Log.Debug("Model.path:", Model.path)
    end
    local Exist = PetBase and Model and UE4.UNRCStatics.CheckAssetExists(Model.path)
    table.insert(self.sortPets, {Conf = v, Exist = Exist})
  end
  table.sort(self.sortPets, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortPets) do
    local data = string.format("[%s] %d %s", v.Exist and "O" or "X", v.Conf.id, v.Conf.name)
    self.ComboBoxString_0Op[data] = v.Conf.id
    self.ComboBoxString_1Op[data] = v.Conf.id
    self.ComboBoxString_0:AddOption(data)
    self.ComboBoxString_1:AddOption(data)
  end
  self.sortSkills = {}
  local AllSkill = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.SKILL_CONF):GetAllDatas()
  for _, v in pairs(AllSkill) do
    if UE4.UNRCStatics.CheckAssetExists(v.res_id) then
      table.insert(self.sortSkills, {Conf = v, Exist = true})
    end
  end
  table.sort(self.sortSkills, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortSkills) do
    local short_res = v.Conf.res_id
    if nil ~= short_res then
      local str_array = short_res:split("/")
      short_res = str_array[#str_array]
    end
    local Option = string.format("[%s] %s %s %d", v.Exist and "O" or "X", short_res, v.Conf.name, v.Conf.id)
    self.ComboBoxStringOp[Option] = v.Conf.id
    self.ComboBoxString_2Op[Option] = v.Conf.id
    self.ComboBoxString:AddOption(Option)
    self.ComboBoxString_2:AddOption(Option)
  end
  self.sortBuffs = {}
  local AllBuffs = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.BUFF_CONF):GetAllDatas()
  for _, v in pairs(AllBuffs) do
    table.insert(self.sortBuffs, {
      Conf = v,
      Exist = UE4.UNRCStatics.CheckAssetExists(v.res_id)
    })
  end
  table.sort(self.sortBuffs, function(a, b)
    if a.Exist ~= b.Exist then
      local anum = a.Exist and 1 or 0
      local bnum = b.Exist and 1 or 0
      return anum > bnum
    else
      return a.Conf.id < b.Conf.id
    end
  end)
  for _, v in ipairs(self.sortBuffs) do
    local short_res = v.Conf.res_id
    if nil ~= short_res then
      local str_array = short_res:split("/")
      short_res = str_array[#str_array]
    end
    local Option = string.format("[%s] %s %s %d", v.Exist and "O" or "X", short_res, v.Conf.name, v.Conf.id)
    self.ComboBoxStringBuff_0Op[Option] = v.Conf.id
    self.ComboBoxStringBuff_1Op[Option] = v.Conf.id
    self.ComboBoxStringBuff_0:AddOption(Option)
    self.ComboBoxStringBuff_1:AddOption(Option)
  end
end

function UMG_LocalBattle_Debug_Panel_C:Hide()
  self.DebugPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_LocalBattle_Debug_Panel_C:Show()
  self.DebugPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_LocalBattle_Debug_Panel_C:OnBtnOpenClick()
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl:OnBtnOpenClick")
  if self.DebugPanel:GetVisibility() == UE4.ESlateVisibility.Hidden then
    self:Show()
    self.autoShow = true
  else
    self:Hide()
    self.autoShow = false
  end
end

function UMG_LocalBattle_Debug_Panel_C:GetSkillCMDReq(skillComBox, skillOps)
  ServerData.SetKill(self.EnableSkill:GetCheckedState() == UE4.ECheckBoxState.Checked)
  local op = skillComBox:GetSelectedOption()
  local skillId = skillOps[op]
  local petId
  local logName = "\230\136\145\230\150\185"
  if skillComBox == self.ComboBoxString then
    petId = ServerData.GetPlayerBattlePetID()
  else
    petId = ServerData.GetEnemyBattlePetID()
    logName = "\230\149\140\230\150\185"
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = skillId
  BattleRoundFlowReq.cast_skill.caster_pet_id = petId
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  local SkillConf = _G.DataConfigManager:GetSkillConf(skillId, true)
  self.LastSkillPath = SkillConf.res_id
  Log.Warning("UMG_LocalBattle_Debug_Panel_Ctrl play skill ", logName, SkillConf.res_id)
  return req
end

function UMG_LocalBattle_Debug_Panel_C:EnemySkillChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_2:GetSelectedIndex() then
    return
  end
  local req = self:GetSkillCMDReq(self.ComboBoxString_2, self.ComboBoxString_2Op)
  req.__local_isEnemy = true
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  self:Hide()
  self.OpenBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.playerPlayed = false
end

function UMG_LocalBattle_Debug_Panel_C:PlayerBuffChange()
  if -1 == self.ComboBoxStringBuff_0:GetSelectedIndex() then
    return
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  req.__local_isBuff = true
  req.__local_isEnemy = false
  local op = self.ComboBoxStringBuff_0:GetSelectedOption()
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = self.ComboBoxStringBuff_0Op[op]
  BattleRoundFlowReq.cast_skill.caster_pet_id = ServerData.GetPlayerBattlePetID()
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function UMG_LocalBattle_Debug_Panel_C:EnemyBuffChange()
  if -1 == self.ComboBoxStringBuff_1:GetSelectedIndex() then
    return
  end
  local BattleRoundFlowReqList = {}
  local BattleRoundFlowReq = {}
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  req.__local_isBuff = true
  req.__local_isEnemy = false
  local op = self.ComboBoxStringBuff_1:GetSelectedOption()
  BattleRoundFlowReq.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CAST_SKILL
  BattleRoundFlowReq.cast_skill = {}
  BattleRoundFlowReq.cast_skill.skill_id = self.ComboBoxStringBuff_1Op[op]
  BattleRoundFlowReq.cast_skill.caster_pet_id = ServerData.GetEnemyBattlePetID()
  table.insert(BattleRoundFlowReqList, BattleRoundFlowReq)
  req.req = BattleRoundFlowReqList
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
end

function UMG_LocalBattle_Debug_Panel_C:PlayerSkillChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString:GetSelectedIndex() then
    return
  end
  local req = self:GetSkillCMDReq(self.ComboBoxString, self.ComboBoxStringOp)
  ServerData.ChangeBattleType("self")
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  ServerData.ChangeBattleType("enemy")
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, req)
  self:Hide()
  self.OpenBtn:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.playerPlayed = true
end

function UMG_LocalBattle_Debug_Panel_C:GetChangePetCMDReq(skillComBox, skillOps)
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl:GetChangePetCMDReq")
  local op = skillComBox:GetSelectedOption()
  local petId = skillOps[op]
  local baseConfId = _G.DataConfigManager:GetPetConf(petId).base_id
  local req = BattleNetManager:BuildBattleCmdPushbackReq()
  req.__debugChange = true
  req.__monsterConfId = monsterConfId
  req.__baseConfId = baseConfId
  return req
end

function UMG_LocalBattle_Debug_Panel_C:ChangeModel(req, isPlayer)
  local battle_pet_id, battle_pet_info, pet
  if req.__isplayer then
    battle_pet_id = ServerData.GetPlayerBattlePetID()
    battle_pet_info = ServerData.GetPlayerBattlePetInfo()
    pet = self.PawnManager.playerTeam:GetPetByGuid(battle_pet_id)
  else
    battle_pet_id = ServerData.GetEnemyBattlePetID()
    battle_pet_info = ServerData.GetEnemyBattlePetInfo()
    Log.Debug("show me pet:", battle_pet_id, battle_pet_info)
    pet = self.PawnManager.enemyTeam:GetPetByGuid(battle_pet_id)
  end
  local oldModel = pet.model
  local baseconf = _G.DataConfigManager:GetPetbaseConf(req.__baseConfId)
  local ModelConf = _G.DataConfigManager:GetModelConf(baseconf.model_conf)
  local petClass = _G.NRCResourceManager:LoadForDebugOnly(ModelConf.path)
  local pos = 1
  if isPlayer then
    pos = ServerData.values.CurSelectedPlayerPetPos
  else
    pos = ServerData.values.CurSelectedEnemyPetPos
  end
  local petPos
  if req.__isplayer then
    petPos = self.PawnManager.VBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_TEAM)
  else
    petPos = self.PawnManager.VBattleField:GetTeamPositionMap(BattleEnum.Team.ENUM_ENEMY)
  end
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl change pet:", pos, petPos)
  local petPosMap = petPos:Get(pos)
  local params = {}
  params.inBattle = true
  local model = _G.UE4Helper.GetCurrentWorld():Abs_SpawnActor(petClass, petPosMap:Abs_GetTransform(), UE4.ESpawnActorCollisionHandlingMethod.AlwaysSpawn, nil, nil, nil, params)
  model:InitOutScene()
  model.EnableHeadLookAt = true
  model:InitHeadLookAt()
  pet:SetModel(model)
  oldModel:K2_DestroyActor()
  pet = self.PawnManager.playerTeam.pets[1]
  if pet then
    local CameraManger = self.BattleManager.vBattleField.battleCameraManager
    pet.card.petBaseConf.pet_scale = baseconf.pet_scale
    if self.BattleManager.battleRuntimeData.operateType == BattleEnum.Operation.ENUM_SKILL then
      if req.__isplayer then
        CameraManger:CalcPos()
      else
        CameraManger:CalcPos()
      end
      CameraManger:ChangeToPlayerPet()
    end
  end
end

function UMG_LocalBattle_Debug_Panel_C:ChangePlayerSelectedPet(SelectedItem, SelectionType)
  if -1 == self.ComboBoxTarget_0:GetSelectedIndex() then
    return
  end
  ServerData.values.CurSelectedPetPlayer = self.ComboBoxTarget_0Op[SelectedItem]
  ServerData.values.CurSelectedPlayerPetPos = ServerData.values.CurSelectedPetPlayer
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl CurSelectedPetPlayer:", ServerData.values.CurSelectedPetPlayer)
end

function UMG_LocalBattle_Debug_Panel_C:ChangeEnemySelectedPet(SelectedItem, SelectionType)
  if -1 == self.ComboBoxTarget_1:GetSelectedIndex() then
    return
  end
  ServerData.values.CurSelectedPetEnemy = self.ComboBoxTarget_1Op[SelectedItem]
  ServerData.values.CurSelectedEnemyPetPos = ServerData.values.CurSelectedPetEnemy - 400
  Log.Debug("UMG_LocalBattle_Debug_Panel_Ctrl CurSelectedPetPlayer:", ServerData.values.CurSelectedPetEnemy)
end

function UMG_LocalBattle_Debug_Panel_C:PlayerPetChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_0:GetSelectedIndex() then
    return
  end
  local req = self:GetChangePetCMDReq(self.ComboBoxString_0, self.ComboBoxString_0Op)
  req.__isplayer = true
  self:ChangeModel(req, true)
end

function UMG_LocalBattle_Debug_Panel_C:EnemyPetChange(SelectedItem, SelectionType)
  if -1 == self.ComboBoxString_1:GetSelectedIndex() then
    return
  end
  local req = self:GetChangePetCMDReq(self.ComboBoxString_1, self.ComboBoxString_1Op)
  req.__isplayer = false
  self:ChangeModel(req, false)
end

function UMG_LocalBattle_Debug_Panel_C:OnCatchButton()
  local Catch = BattleNetManager:BuildBattleCmdPushbackReq()
  Catch.req_type = _G.ProtoEnum.BATTLE_REQ_TYPE.CMD_CATCH_PET
  _G.ZoneServer:Send(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_CMD_PUSHBACK_REQ, Catch)
end

function UMG_LocalBattle_Debug_Panel_C:ComboBoxAdvance(box)
  local Index = box:GetSelectedIndex()
  if Index < box:GetOptionCount() then
    box:SetSelectedIndex(Index + 1)
  end
end

function UMG_LocalBattle_Debug_Panel_C:FilterCaster()
end

function UMG_LocalBattle_Debug_Panel_C:FilterMyPet()
  self:FilterOptions(self.ComboBoxString_0Op, self.ComboBoxString_0, self.ComboBoxString_0ET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterEnemyPet()
  self:FilterOptions(self.ComboBoxString_1Op, self.ComboBoxString_1, self.ComboBoxString_1ET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterMySkill()
  self:FilterOptions(self.ComboBoxStringOp, self.ComboBoxString, self.ComboBoxStringET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterEnemySkill()
  self:FilterOptions(self.ComboBoxString_2Op, self.ComboBoxString_2, self.ComboBoxString_2ET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterMyBuff()
  self:FilterOptions(self.ComboBoxStringBuff_0Op, self.ComboBoxStringBuff_0, self.ComboBoxStringBuff_0ET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterEnemyBuff()
  self:FilterOptions(self.ComboBoxStringBuff_1Op, self.ComboBoxStringBuff_1, self.ComboBoxStringBuff_1ET:GetText())
end

function UMG_LocalBattle_Debug_Panel_C:FilterOptions(AllOptions, comboBox, filter)
  for i, v in pairs(AllOptions) do
    if i:find(filter) then
      if comboBox:FindOptionIndex(i) < 0 then
        comboBox:AddOption(i)
      end
    elseif comboBox:FindOptionIndex(i) >= 0 then
      comboBox:RemoveOption(i)
    end
  end
end

return UMG_LocalBattle_Debug_Panel_C
