local UMG_DialogueTypewritter_C = _G.NRCViewBase:Extend("UMG_DialogueTypewritter_C")

function UMG_DialogueTypewritter_C:OnConstruct()
end

function UMG_DialogueTypewritter_C:OnDestruct()
end

function UMG_DialogueTypewritter_C:OnActive()
end

function UMG_DialogueTypewritter_C:OnDeactive()
end

function UMG_DialogueTypewritter_C:Clear()
  if not UE.UObject.IsValid(self) then
    return
  end
  if not self.Dialogue then
    return
  end
  self.Dialogue:SetText("")
  self:ResetWrittenText()
end

function UMG_DialogueTypewritter_C:ResetWrittenText()
  self.WrittenText = ""
end

function UMG_DialogueTypewritter_C:Writer(txt, timeDelay, numberCharacter)
  self:Clear()
  numberCharacter = numberCharacter or 3
  self.Buffer = txt
  self.Delay = timeDelay
  self.numChar = numberCharacter
end

function UMG_DialogueTypewritter_C:Init(timeDelay, numberCharacter, manualMode)
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

function UMG_DialogueTypewritter_C:Update()
  if self.Buffer ~= nil then
    self.Dialogue:AppendText(self.Buffer)
    self.WrittenText = self.WrittenText .. self.Buffer
  end
end

function UMG_DialogueTypewritter_C:SetSpeed(timeDelay, numberCharacter)
  numberCharacter = numberCharacter or 3
  self.Delay = timeDelay
  self.numChar = numberCharacter
end

function UMG_DialogueTypewritter_C:WriteOnSamePage(inText)
  self.Buffer = inText
  if self.ManualMode then
    self.Dialogue:AppendText(self.Buffer)
    self.WrittenText = self.WrittenText .. self.Buffer
  elseif self.Initiate then
    self:Initiate()
  else
    Log.Error("UMG_DialogueTypewritter_C:WriteOnSamePage\230\151\160\230\179\149\232\176\131\231\148\168WriteOnSamePage\239\188\140\229\143\175\232\131\189\228\188\154\229\141\161\230\173\187")
  end
end

function UMG_DialogueTypewritter_C:WriteOnSamePageWithTranslation(inText, TranslationGapMap, StartPosition, EndPosition)
  self.Buffer = inText
  self.TranslateMode = true
  self.TranslationGapMap = TranslationGapMap
  self.TranslationStartPosition = tonumber(StartPosition) or 1
  self.TranslationEndPosition = tonumber(EndPosition) or #self.Buffer
  self.LastUpdateNonTranslationGap = 0
  local DefaultInterval = 0.2
  if not self.TranslationGapMap then
    self.TranslationGapMap = {
      1,
      0.75,
      0.5,
      0.25,
      0.1
    }
  end
  self.TranslationPhaseMap = {}
  local Current = 0
  for i = 1, #self.TranslationGapMap do
    Current = Current + tonumber(self.TranslationGapMap[i])
    table.insert(self.TranslationPhaseMap, Current)
    Current = Current + DefaultInterval
    table.insert(self.TranslationPhaseMap, Current)
  end
end

function UMG_DialogueTypewritter_C:ShouldShowHumanLanguage(SumTime)
  if not SumTime then
    return
  end
  local DefaultInterval = 0.2
  for i = 1, #self.TranslationPhaseMap do
    if SumTime < self.TranslationPhaseMap[i] then
      return not (i % 2 > 0)
    end
  end
  local ExceedTime = SumTime - (table.len(self.TranslationPhaseMap) > 0 and self.TranslationPhaseMap[table.len(self.TranslationPhaseMap)] or 0.0)
  return not (math.floor(ExceedTime / DefaultInterval) % 2 < 1)
end

function UMG_DialogueTypewritter_C:GetRandomAncientCharacter(InIndex, InCurCharHuman)
  if not self.AncientCharacterMap then
    self.AncientCharacterMap = {}
  end
  local LockMap = false
  if self.LastPos == InIndex then
    if 0 == self.AncientHaltCount then
      LockMap = false
    else
      self.AncientHaltCount = self.AncientHaltCount - 1
      LockMap = true
    end
  else
    self.AncientHaltCount = 4
  end
  if not self.AncientCharacterMap[InCurCharHuman] then
    local ascii_code = math.random(97, 122)
    self.AncientCharacterMap[InCurCharHuman] = string.char(ascii_code)
  end
  if LockMap then
    local ascii_code = math.random(97, 122)
    return string.char(ascii_code)
  else
    return self.AncientCharacterMap[InCurCharHuman]
  end
end

function UMG_DialogueTypewritter_C:Tick(MyGeometry, InDeltaTime)
  if self.TranslateMode then
    if not self.CurrentCharIdx then
      self.TimeUsed = 0
      self.CurrentCharIdx = 1
      self.IsLastShowHumanLanguage = nil
    end
    self.TimeUsed = self.TimeUsed + InDeltaTime
    local CurCharHuman = string.SubStringUTF8(self.Buffer, self.CurrentCharIdx, self.CurrentCharIdx)
    local CurrentShowHumanLanguage = self:ShouldShowHumanLanguage(self.TimeUsed)
    local bBeforeTranslation = self.CurrentCharIdx < self.TranslationStartPosition
    local bAfterTranslation = self.CurrentCharIdx > self.TranslationEndPosition
    local bOutTranslationRange = bBeforeTranslation or bAfterTranslation
    if bOutTranslationRange then
      self.LastUpdateNonTranslationGap = self.LastUpdateNonTranslationGap + InDeltaTime
      if self.LastUpdateNonTranslationGap >= self.Delay then
        self.LastUpdateNonTranslationGap = 0
      else
        return
      end
      local MaxNofCharsToShow = self.numChar
      if bBeforeTranslation then
        MaxNofCharsToShow = math.min(self.TranslationStartPosition - self.CurrentCharIdx, MaxNofCharsToShow)
      else
        MaxNofCharsToShow = math.min(string.SubStringGetTotalIndex(self.Buffer) - self.CurrentCharIdx, MaxNofCharsToShow)
      end
      local NextCharIdx = self.CurrentCharIdx + math.max(MaxNofCharsToShow, 1)
      CurCharHuman = string.SubStringUTF8(self.Buffer, self.CurrentCharIdx, NextCharIdx - 1)
      self.CurrentCharIdx = NextCharIdx
      self.WrittenText = self.WrittenText .. CurCharHuman
    else
      if not CurrentShowHumanLanguage and self.IsLastShowHumanLanguage then
        self.CurrentCharIdx = self.CurrentCharIdx + 1
        self.WrittenText = self.WrittenText .. CurCharHuman
      end
      if not CurrentShowHumanLanguage then
        CurCharHuman = self:GetRandomAncientCharacter(self.CurrentCharIdx, CurCharHuman)
      end
      self.IsLastShowHumanLanguage = CurrentShowHumanLanguage
    end
    if self.CurrentCharIdx > string.SubStringGetTotalIndex(self.Buffer) then
      self.CurrentCharIdx = nil
      self.TranslateMode = false
      self.Dialogue:SetText(self.WrittenText)
      self:TypeDone()
      return
    end
    if bOutTranslationRange then
      self.Dialogue:SetText(self.WrittenText)
    else
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(4072, "UMG_DialogueTypewritter_C")
      self.Dialogue:SetText(self.WrittenText .. CurCharHuman)
    end
  end
end

return UMG_DialogueTypewritter_C
