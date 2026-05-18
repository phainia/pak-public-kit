local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Information_Recording_C = _G.NRCPanelBase:Extend("UMG_Information_Recording_C")

function UMG_Information_Recording_C:OnConstruct()
  self.SendReqTime = 0
  self.hyperLinkIndex = -1
  self.maxRoundNumber = 0
  self.minRoundNumber = 0
  self.allBattleOpRecordItems = {}
  self.dotItemDataList = {}
  self:AddButtonListener(self.btnCloseRenamePanel, self.CloseRecord)
  self:AddButtonListener(self.btnClose.btnClose, self.CloseRecord)
  self.CloseHyperlink.OnClicked:Add(self, self.OnCloseHyperLink)
  self.CloseHyperlink_1.OnClicked:Add(self, self.OnCloseHyperLink)
  self.BtnNextRound.OnClicked:Add(self, self.SwitchToNextRound)
  self.BtnLastRound.OnClicked:Add(self, self.SwitchToLastRound)
  self:BindInputAction()
end

function UMG_Information_Recording_C:OnDestruct()
  self:RemoveAllButtonListener()
  self.BtnNextRound.OnClicked:Remove(self, self.SwitchToNextRound)
  self.BtnLastRound.OnClicked:Remove(self, self.SwitchToLastRound)
end

function UMG_Information_Recording_C:OnActive(curRound, preRoundData, myPos)
  if _G.GlobalConfig.DebugOpenUI then
    local fakeData = {}
    table.insert(fakeData, {})
    table.insert(fakeData, {})
    self.List:InitGridView(fakeData)
    return
  end
  self:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.IsClose = false
  self.MyPos = myPos
  self:RoundStart(curRound)
  if preRoundData then
    local titleText = LuaText.team_battle_skill_info or ""
    self.Title:SetText(titleText)
    self:RoundOpQueryRsp(preRoundData)
  else
    local titleText = LuaText.battle_log_info or ""
    self.Title:SetText(titleText)
    self:TryOpenRecord()
  end
  self:LoadAnimation(0)
  self:UpdateWeather()
  _G.BattleEventCenter:Bind(self, BattleEvent.BATTLE_WEATHER_CHANGED, BattleEvent.ROUND_START)
end

function UMG_Information_Recording_C:OnDeactive()
  self.IsClose = true
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Information_Recording_C:RoundStart(round)
  self.ShouldUpdate = true
  self.curRound = round
end

function UMG_Information_Recording_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_BattleRecord")
  if mappingContext then
    mappingContext:BindAction("IA_CloseSubPanel", self, "CloseRecord")
    self.extraKey = _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.GetMappingKey, "IA_BattleRecord")
    if self.extraKey then
      mappingContext:AddKey("IA_CloseSubPanel", self.extraKey)
    end
  end
end

function UMG_Information_Recording_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseSubPanel")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local BattleRecordIMC = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_BattleRecord")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, BattleRecordIMC)
end

function UMG_Information_Recording_C:OnPcClose()
  self:CloseRecord()
end

function UMG_Information_Recording_C:TryOpenRecord()
  _G.NRCAudioManager:PlaySound2DAuto(1292, "UMG_Information_Recording_C:ClickRecord")
  if self.ShouldUpdate or not self.PreRoundData then
    if UE4Helper.GetTime() - self.SendReqTime > 3 then
      self.SendReqTime = UE4Helper.GetTime()
      local req = _G.ProtoMessage:newZoneBattleRoundOpQueryReq()
      _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_BATTLE_ROUND_OP_QUERY_REQ, req, self, self.RoundOpQueryRsp, true, true)
    end
  else
    self:OpenRecord()
  end
end

function UMG_Information_Recording_C:GetPetInfo(id)
  if self.PetInfos then
    for _, v in ipairs(self.PetInfos) do
      if v.pet_id == id then
        return v
      end
    end
  end
end

function UMG_Information_Recording_C:RoundOpQueryRsp(rsp)
  if self.IsClose then
    return
  end
  if rsp and rsp.items and #rsp.items > 0 then
    if self.curRound - 1 == self:GetRoundData(rsp.items[1]).round then
      self.ShouldUpdate = false
    end
    self.IsInitData = false
    self.PreRoundData = {}
    self.allBattleOpRecordItems = rsp.items
    self.PetInfos = rsp.simple_pets or {}
    for i, info in ipairs(self.PetInfos) do
      BattleUtils.RefreshCliSimplePetMutationTypeDataByConfig(info)
    end
    self.maxRoundNumber = 0
    self.minRoundNumber = 999
    for _, v in ipairs(rsp.items) do
      local roundNumber = self:GetRoundNumberFromRecord(v)
      self.maxRoundNumber = math.max(self.maxRoundNumber, roundNumber)
      self.minRoundNumber = math.min(self.minRoundNumber, roundNumber)
      self.minRoundNumber = math.max(self.minRoundNumber, 0)
    end
  else
    self.IsInitData = false
    self.PreRoundData = {}
    self.allBattleOpRecordItems = {}
    self.maxRoundNumber = 0
    self.minRoundNumber = 0
  end
  local maxDisplayRoundCount = 10
  self.minRoundNumber = math.max(self.minRoundNumber, self.maxRoundNumber - maxDisplayRoundCount + 1)
  if self.maxRoundNumber ~= self.minRoundNumber then
    self.Sliding:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Sliding:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local newDotItemDataList = {}
  for roundIndex = self.minRoundNumber, self.maxRoundNumber do
    local data = {
      key = roundIndex,
      OnSelectedCallbackOwner = self,
      OnSelectedCallback = UMG_Information_Recording_C.OnDotItemSelected,
      Selected = false,
      roundIndex = roundIndex
    }
    table.insert(newDotItemDataList, data)
  end
  self:SetDotItemDataList(newDotItemDataList)
  self.Dot_List:ClearSelection()
  self:OpenRecord()
end

function UMG_Information_Recording_C:UpdatePreRoundData(currentDisplayBattleOpRecords)
  self.PreRoundData = {}
  local myPetIndex = 0
  local enemyPetIndex = 0
  for _, v in ipairs(currentDisplayBattleOpRecords) do
    local data = self:GetRoundData(v)
    local PetCard = self:GetPetInfo(data.caster or data.down_pet)
    if PetCard then
      v.selfPet = PetCard
      v.petInfos = self.PetInfos
      if PetCard.side ~= _G.BattleManager.battlePawnManager:GetMyServerSide() then
        enemyPetIndex = enemyPetIndex + 1
        self.PreRoundData[enemyPetIndex * 2] = v
      else
        myPetIndex = myPetIndex + 1
        self.PreRoundData[myPetIndex * 2 - 1] = v
      end
    end
  end
  local dataCount = math.max(myPetIndex * 2 - 1, enemyPetIndex * 2)
  for i = 1, dataCount do
    if not self.PreRoundData[i] then
      self.PreRoundData[i] = {}
    end
  end
  local preRoundDataNum = #self.PreRoundData
  if 0 == preRoundDataNum then
    self.Line_2:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasPanel_79:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SizeBox_List:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self:ModifyRoundData(self.PreRoundData[preRoundDataNum])
    self:ModifyRoundData(self.PreRoundData[preRoundDataNum - 1])
    self.Line_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanel_79:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SizeBox_List:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Information_Recording_C:ModifyRoundData(Data)
  if not Data then
    return
  end
  Data.HideDivider = true
end

function UMG_Information_Recording_C:GetRoundData(data)
  if data.type == ProtoEnum.BattleOpRecord.RoundOpType.TYPE_SKILL then
    return data.skill_op
  else
    return data.change_pet_op
  end
end

function UMG_Information_Recording_C:OpenRecord(roundNumber)
  _G.NRCAudioManager:PlaySound2DAuto(1291, "UMG_Information_Recording_C:OpenRecord")
  roundNumber = roundNumber or self.maxRoundNumber
  local currentDisplayRoundData = self:GetRoundDisplayData(roundNumber)
  self:UpdatePreRoundData(currentDisplayRoundData)
  local newDotItemDataList = self:GetNewDotListDataList(roundNumber)
  self:SetData(roundNumber, self.PreRoundData, newDotItemDataList)
end

function UMG_Information_Recording_C:SetData(newDisplayRound, recordData, newDotItemDataList)
  if self.currentDisplayRound == newDisplayRound then
    return
  end
  local previousDisplayRound = self.currentDisplayRound
  self.currentDisplayRound = newDisplayRound
  if not self.IsInitData then
    self.IsInitData = true
    self.List:Clear()
    local itemDataList = {}
    for i, record in ipairs(recordData) do
      local itemData = {
        record = record,
        currentDisplayRound = self.currentDisplayRound,
        maxRoundNumber = self.maxRoundNumber,
        currentDisplayRoundIsTheLatest = self.currentDisplayRound == self.maxRoundNumber
      }
      table.insert(itemDataList, itemData)
    end
    self.List:InitGridView(itemDataList)
  end
  self:SetVisibility(UE4.ESlateVisibility.Visible)
  if newDisplayRound - 1 < self.minRoundNumber then
    self.BtnLastRound:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BtnLastRound:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  if newDisplayRound + 1 > self.maxRoundNumber then
    self.BtnNextRound:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BtnNextRound:SetVisibility(UE4.ESlateVisibility.Visible)
  end
  self:SetDotItemDataList(newDotItemDataList)
end

function UMG_Information_Recording_C:CloseRecord()
  _G.NRCAudioManager:PlaySound2DAuto(1076, "UMG_Information_Recording_C:CloseRecord")
  _G.BattleEventCenter:Dispatch(BattleEvent.Show_RecordingBtn)
  self:LoadAnimation(2)
end

function UMG_Information_Recording_C:SwitchToNextRound()
  self:SwitchToRound(self.currentDisplayRound + 1)
end

function UMG_Information_Recording_C:SwitchToLastRound()
  self:SwitchToRound(self.currentDisplayRound - 1)
end

function UMG_Information_Recording_C:SwitchToRound(roundNumber)
  if not (roundNumber >= self.minRoundNumber) or not (roundNumber <= self.maxRoundNumber) then
    Log.ErrorFormat("UMG_Information_Recording_C:SwitchToRound %s \232\182\133\229\135\186\229\136\135\230\141\162\232\140\131\229\155\180 [%s, %s]\239\188\140\229\136\135\230\141\162\229\164\177\232\180\165", tostring(roundNumber), tostring(self.minRoundNumber), tostring(self.maxRoundNumber))
    return
  end
  local newDisplayRoundData = self:GetRoundDisplayData(roundNumber)
  if not next(newDisplayRoundData) then
    Log.WarningFormat("UMG_Information_Recording_C:SwitchToRound \231\172\172 %s \229\155\158\229\144\136\230\178\161\230\156\137\230\149\176\230\141\174\239\188\140\232\175\183\230\163\128\230\159\165", tostring(roundNumber))
  end
  self.IsInitData = false
  self:OpenRecord(roundNumber)
  self:CloseHyperLink()
end

function UMG_Information_Recording_C:CloseHyperLink()
  self:CloseHyperLinkState()
  self.CloseHyperlink:SetVisibility(UE4.ESlateVisibility.Collapsed)
end

function UMG_Information_Recording_C:HyperLinkClick(descText, index)
  local nounInterpretationTipsInfo = {}
  nounInterpretationTipsInfo.text = descText
  _G.NRCModuleManager:DoCmd(_G.CommonPopUpModuleCmd.OpenNounInterpretationTipsPanel, nounInterpretationTipsInfo)
end

function UMG_Information_Recording_C:OnCloseHyperLink()
  self:CloseHyperLink()
end

function UMG_Information_Recording_C:OpenHyperLinkState()
  self.btnCloseRenamePanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CloseHyperlink:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CloseHyperlink_1:SetVisibility(UE4.ESlateVisibility.Visible)
  local ChildrenCount = self.List:GetItemCount()
  for i = 0, ChildrenCount - 1 do
    local item = self.List:GetItemByIndex(i)
    item:OpenHyperLinkState()
  end
end

function UMG_Information_Recording_C:CloseHyperLinkState()
  self.btnCloseRenamePanel:SetVisibility(UE4.ESlateVisibility.Visible)
  self.CloseHyperlink:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CloseHyperlink_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local ChildrenCount = self.List:GetItemCount()
  for i = 0, ChildrenCount - 1 do
    local item = self.List:GetItemByIndex(i)
    item:CloseHyperLinkState()
  end
end

function UMG_Information_Recording_C:OnAnimationFinished(Anim)
  if Anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_Information_Recording_C:GetRoundNumberFromRecord(record)
  local recordData = self:GetRoundData(record)
  return recordData and recordData.round or -1
end

function UMG_Information_Recording_C:GetRoundDisplayData(roundNumber)
  local roundRecordList = {}
  if roundNumber < 0 then
    return roundRecordList
  end
  for i, v in ipairs(self.allBattleOpRecordItems) do
    local isActuallyCast = self:CheckActuallyCast(v)
    local recordRoundNumber = self:GetRoundNumberFromRecord(v)
    if recordRoundNumber == roundNumber and isActuallyCast then
      table.insert(roundRecordList, v)
    end
  end
  return roundRecordList
end

function UMG_Information_Recording_C:DebugAddFakeDataToAllRecords()
  if 0 == #self.allBattleOpRecordItems then
    return
  end
  for i = 1, 20 do
    local randomIndex = math.random(#self.allBattleOpRecordItems)
    local newItem = {}
    table.deepCopy(self.allBattleOpRecordItems[randomIndex], newItem)
    local recordData = self:GetRoundData(newItem)
    recordData.round = recordData.round + 1
    table.insert(self.allBattleOpRecordItems, newItem)
  end
end

function UMG_Information_Recording_C:OnDotItemSelected(key)
  local roundIndex = -1
  for i, data in ipairs(self.dotItemDataList) do
    if data.key == key then
      roundIndex = data.roundIndex
    end
  end
  self:SwitchToRound(roundIndex)
end

function UMG_Information_Recording_C:GetNewDotListDataList(roundNumber)
  local newDotItemDataList = {}
  for i, data in ipairs(self.dotItemDataList) do
    local newData = {}
    table.copy(data, newData)
    if newData.roundIndex == roundNumber then
      newData.Selected = true
    else
      newData.Selected = false
    end
    table.insert(newDotItemDataList, newData)
  end
  return newDotItemDataList
end

function UMG_Information_Recording_C:SetDotItemDataList(newDotItemDataList)
  local previousDotItemDataList = self.dotItemDataList
  if #previousDotItemDataList ~= #newDotItemDataList then
    self.dotItemDataList = newDotItemDataList
    self.Dot_List:InitGridView(newDotItemDataList)
  else
    for i, data in ipairs(newDotItemDataList) do
      table.copy(data, previousDotItemDataList[i])
      self.Dot_List:RefreshItemDataByIndex(i - 1)
    end
  end
end

function UMG_Information_Recording_C:CheckActuallyCast(record)
  if record.type == ProtoEnum.BattleOpRecord.RoundOpType.TYPE_SKILL and not record.skill_op.is_real_cast then
    return false
  end
  return true
end

function UMG_Information_Recording_C:OnBattleEvent(eventName)
  if eventName == BattleEvent.BATTLE_WEATHER_CHANGED or eventName == BattleEvent.ROUND_START then
    self:UpdateWeather()
  end
end

function UMG_Information_Recording_C:UpdateWeather()
  local weatherId = _G.BattleManager.battleRuntimeData.curWeatherID
  local remainRound = _G.BattleManager.battleRuntimeData:GetWeatherRemainRound()
  self:DoUpdateWeather(weatherId, remainRound)
end

local weatherIDToDesc = {}
weatherIDToDesc[3] = {
  id = "weather_desc_id_3",
  name = "weather_name_id_3",
  sprite = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_xiayutian2_png.img_xiayutian2_png'"
}
weatherIDToDesc[5] = {
  id = "weather_desc_id_2",
  name = "weather_name_id_2",
  sprite = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_xuetian2_png.img_xuetian2_png'"
}
weatherIDToDesc[6] = {
  id = "weather_desc_id_1",
  name = "weather_name_id_1",
  sprite = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/Combat/Frames/img_shabaotian2_png.img_shabaotian2_png'"
}
weatherIDToDesc[4] = weatherIDToDesc[3]
weatherIDToDesc[9] = weatherIDToDesc[5]

function UMG_Information_Recording_C:DoUpdateWeather(weatherId, remainRound)
  local desc
  if remainRound > 0 then
    desc = weatherIDToDesc[weatherId]
  end
  if desc then
    self.CanvasPanel_Weather:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local descText, descName
    do
      local i18n = _G.DataConfigManager:GetLocalizationConf(desc.id)
      descText = i18n and i18n.msg or "(" .. desc.id .. ")"
    end
    do
      local i18n = _G.DataConfigManager:GetLocalizationConf(desc.name)
      descName = i18n and i18n.msg or "(" .. desc.name .. ")"
    end
    self.NameText_0:SetText(descName)
    self.Desc_12:SetText(descText)
    self.CountDownText:SetText(tostring(remainRound))
    self.IconImage_34:SetPath(desc.sprite)
  else
    self.CanvasPanel_Weather:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_Information_Recording_C
