local UMG_TypeWritter_C = _G.NRCViewBase:Extend("UMG_TypeWritter_C")

function UMG_TypeWritter_C:OnConstruct()
end

function UMG_TypeWritter_C:OnDestruct()
end

function UMG_TypeWritter_C:OnActive()
end

function UMG_TypeWritter_C:OnDeactive()
end

function UMG_TypeWritter_C:Clear()
  self.Dialogue:SetText("")
  self:ResetWrittenText()
end

function UMG_TypeWritter_C:ResetWrittenText()
  self.WrittenText = ""
end

function UMG_TypeWritter_C:Writer(txt, timeDelay, numberCharacter, IsEvo)
  self:Clear()
  numberCharacter = numberCharacter or 3
  self.Buffer = txt
  self.Delay = timeDelay
  self.numChar = numberCharacter
  self:SwitchToEvoText(IsEvo)
end

function UMG_TypeWritter_C:Init(timeDelay, numberCharacter, manualMode)
  self:Clear()
  if manualMode then
    self.ManualMode = true
  else
    self.ManualMode = false
  end
  numberCharacter = numberCharacter or 3
  self.Delay = timeDelay
  self.numChar = numberCharacter
end

function UMG_TypeWritter_C:Update()
  if self.Buffer ~= nil then
    self.Dialogue:AppendText(self.Buffer)
    self.WrittenText = self.WrittenText .. self.Buffer
  end
end

function UMG_TypeWritter_C:SetSpeed(timeDelay, numberCharacter)
  numberCharacter = numberCharacter or 3
  self.Delay = timeDelay
  self.numChar = numberCharacter
end

function UMG_TypeWritter_C:WriteOnSamePage(inText)
  self.Buffer = inText
  if self.ManualMode then
    self.Dialogue:AppendText(self.Buffer)
    self.WrittenText = self.WrittenText .. self.Buffer
  else
    self:Initiate()
  end
end

function UMG_TypeWritter_C:WriteOnSamePageWithTranslation(inText)
  self.Buffer = inText
  self.TranslateMode = true
end

function UMG_TypeWritter_C:Tick(MyGeometry, InDeltaTime)
  if self.TranslateMode then
    if not self.CurrentCharIdx then
      self.TimeUsed = 0
      self.CurrentCharIdx = 1
      self.IsLastShowHumanLanguage = true
    end
    self.TimeUsed = self.TimeUsed + InDeltaTime
    if self.CurrentCharIdx > #self.Buffer then
      self.CurrentCharIdx = nil
      self.TranslateMode = false
      self:OnTypeFinish()
      return
    end
    local CurChar = self.Buffer:sub(self.CurrentCharIdx, self.CurrentCharIdx)
    local CurrentShowHumanLanguage = 0 ~= math.floor(self.TimeUsed / 0.5) % 2
    if not self.CurrentShowHumanLanguage then
      CurChar = "%"
    end
    Log.Error("CurChar", CurChar)
    self.Dialogue:SetText(self.WrittenText .. CurChar)
    if CurrentShowHumanLanguage ~= self.IsLastShowHumanLanguage then
      self.CurrentCharIdx = self.CurrentCharIdx + 1
    end
    self.IsLastShowHumanLanguage = CurrentShowHumanLanguage
  end
end

function UMG_TypeWritter_C:SwitchToEvoText(_IsEvo)
  if _IsEvo then
    self.Dialogue:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Dialogue_Evo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Dialogue:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Dialogue_Evo:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

return UMG_TypeWritter_C
