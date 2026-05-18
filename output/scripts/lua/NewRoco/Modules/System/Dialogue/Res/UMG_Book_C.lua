local UMG_Book_C = _G.NRCPanelBase:Extend("UMG_Book_C")
local BookDelimiter = {Paging = "###", Hiding = "///"}

function UMG_Book_C:OnActive(ReadID, Text, Action)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  self.Action = Action
  self.ReadID = ReadID
  self.Text = Text
  self.PageHeight = self.Dialogue_L.Slot:GetSize().Y
  self.AutoSetting = _G.UserSettingManager:IsDialogueAutoPlayOn()
  self.Dialogue_L:SetText("")
  self.Dialogue_R:SetText("")
  self.Dialogue_L:ForceLayoutPrepass()
  self.Dialogue_R:ForceLayoutPrepass()
  self:PlayAnimationForward(self.In)
end

function UMG_Book_C:OnDeactive()
  if self.Action then
    self.Action:Finish(true)
    self.Action = nil
  end
  self:RemoveAllButtonListener()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  self:PauseAudio()
  _G.UserSettingManager:SetDialogueAutoPlay(self.AutoSetting)
end

function UMG_Book_C:OnAddEventListener()
  self:AddButtonListener(self.PageTurning_L, self.LastPage)
  self:AddButtonListener(self.PageTurning_R, self.NextPage)
  self:AddButtonListener(self.CloseBtn.btnClose, self.CloseSelf)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
end

function UMG_Book_C:OnDisconnect()
  self:DoClose()
end

function UMG_Book_C:InitBook()
  self:SetBook(self.Text)
  self:OnAddEventListener()
end

function UMG_Book_C:SetBook(Text)
  self:Paging(Text)
  self.PageCount = #self.Pages
  self:SetCurrentPage(1)
  local ReadConf = _G.DataConfigManager:GetReadConf(self.ReadID)
  local EventName = ReadConf and ReadConf.voice_data
  if EventName then
    self.EventName = EventName
    self.Autoplay:BindToAnimationFinished(self.Autoplay.Play, {
      self,
      self.PlayAudio
    })
    self.Autoplay:BindToAnimationStarted(self.Autoplay.Stop, {
      self,
      self.PauseAudio
    })
    if not self.AutoSetting then
      _G.UserSettingManager:SetDialogueAutoPlay(true)
    end
    self.Autoplay:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Book_C:SetCurrentPage(PageNum)
  if not self.Pages[PageNum] then
    return
  end
  self.CurrentPage = PageNum
  self:RefreshPage()
end

function UMG_Book_C:RefreshPage()
  self.bHiddenText = false
  local PageNum = self.CurrentPage
  self.Dialogue_L:SetText(self:RefreshText(PageNum))
  self.Text_PageNum_L:SetText(string.format("%d/%d", PageNum, self.PageCount))
  self.HorizontalBox_Page_L:SetVisibility(self.Pages[PageNum] and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  PageNum = PageNum + 1
  self.Dialogue_R:SetText(self:RefreshText(PageNum))
  self.Text_PageNum_R:SetText(string.format("%d/%d", PageNum, self.PageCount))
  self.HorizontalBox_Page_R:SetVisibility(self.Pages[PageNum] and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function UMG_Book_C:RefreshText(PageNum)
  if not self.bHiddenText then
    local Str = self.Pages[PageNum]
    if Str then
      local StartPos, EndPos = string.find(Str, BookDelimiter.Hiding, 1, true)
      if StartPos then
        local ShowText = string.sub(Str, 1, StartPos - 1)
        self.Pages[PageNum] = ShowText .. string.sub(Str, EndPos + 1, Str:len())
        Str = ShowText
        self.bHiddenText = true
      end
      return Str
    end
  end
  return ""
end

function UMG_Book_C:Paging(Text)
  local Pages = {}
  for i, Page in ipairs(self:SplitString(Text, BookDelimiter.Paging)) do
    for j, _Page in ipairs(self:PagingForText(Page)) do
      table.insert(Pages, _Page)
    end
  end
  self.Pages = Pages
end

function UMG_Book_C:PagingForText(Text)
  local Pages = {}
  local bLoop = true
  while bLoop do
    local Page = Text
    if self:IsLegalPage(Page) then
      bLoop = false
    else
      Page, Text = self:GetPageAndText(Text)
    end
    table.insert(Pages, Page)
  end
  return Pages
end

function UMG_Book_C:GetPageAndText(Text)
  local EndLayoutStr = "</>"
  local Page = ""
  local Str = Text
  while true do
    local StartPos, EndPos = string.find(Str, EndLayoutStr, 1, true)
    if StartPos then
      local _StartPos, _EndPos = string.find(Str, "<.->")
      local PageStr = string.sub(Str, 1, _StartPos - 1)
      if self:IsLegalPage(Page .. PageStr) then
        Page = Page .. PageStr
        PageStr = string.sub(Str, _StartPos, EndPos)
        if self:IsLegalPage(Page .. PageStr) then
          Page = Page .. PageStr
          if EndPos >= Str:len() then
            Str = ""
            break
          end
          Str = string.sub(Str, EndPos + 1)
        else
          local LayoutStr = string.sub(Str, _StartPos, _EndPos)
          PageStr = string.sub(Str, _EndPos + 1, StartPos - 1)
          local LeftStr, RightStr = self:BinarySearch(Page .. LayoutStr, PageStr, EndLayoutStr)
          Page = Page .. LayoutStr .. LeftStr .. EndLayoutStr
          Str = LayoutStr .. RightStr .. string.sub(Str, StartPos)
          break
        end
      else
        local LeftStr, RightStr = self:BinarySearch(Page, PageStr)
        Page = Page .. LeftStr
        Str = RightStr .. string.sub(Str, _StartPos)
        break
      end
    else
      local LeftStr, RightStr = self:BinarySearch(Page, Str)
      Page = Page .. LeftStr
      Str = RightStr
      break
    end
  end
  return Page, Str
end

function UMG_Book_C:BinarySearch(PageBase, Text, LayoutStr)
  local TempText = string.gsub(Text, BookDelimiter.Hiding, "")
  local len = utf8.len(TempText)
  local left = 1
  local right = len
  while left <= right do
    local Pos = math.floor((left + right) / 2)
    local Str = PageBase .. self:GetSubString(TempText, 1, Pos)
    if LayoutStr then
      Str = Str .. LayoutStr
    end
    if self:IsLegalPage(Str) then
      left = Pos + 1
    else
      right = Pos - 1
    end
  end
  if right < 1 then
    return "", Text
  end
  if right == len then
    return Text, ""
  end
  local TotalLen = 0
  local Offset = 0
  for i, Str in ipairs(self:SplitString(Text, BookDelimiter.Hiding)) do
    TotalLen = TotalLen + utf8.len(Str)
    if right >= TotalLen then
      Offset = Offset + utf8.len(BookDelimiter.Hiding)
    else
      break
    end
  end
  right = right + Offset
  return self:GetSubString(Text, 1, right), self:GetSubString(Text, right + 1, utf8.len(Text))
end

function UMG_Book_C:GetSubString(Str, i, j)
  return utf8.char(utf8.codepoint(Str, utf8.offset(Str, i), utf8.offset(Str, j)))
end

function UMG_Book_C:IsLegalPage(Page)
  Page = string.gsub(Page, BookDelimiter.Hiding, "")
  self.Dialogue_L:SetText(Page)
  self.Dialogue_L:ForceLayoutPrepass()
  return self.PageHeight >= self.Dialogue_L:GetDesiredSize().Y
end

function UMG_Book_C:SplitString(Str, Delimiter)
  local Result = {}
  for match in string.gmatch(Str, "[^" .. Delimiter .. "]+") do
    table.insert(Result, match)
  end
  return Result
end

function UMG_Book_C:NextPage()
  if self.bHiddenText then
    self:RefreshPage()
  else
    local PageNum = self.CurrentPage + 2
    if self.Pages[PageNum] and not self.bLockFlipPage then
      self.bLockFlipPage = true
      self:PlayAnimationForward(self.FlipPage)
      self:DelaySeconds(self.FlipPage:GetEndTime() / 2, self.SetCurrentPage, self, PageNum)
    end
  end
end

function UMG_Book_C:LastPage()
  if self.bHiddenText then
    self:RefreshPage()
  else
    local PageNum = self.CurrentPage - 2
    if self.Pages[PageNum] and not self.bLockFlipPage then
      self.bLockFlipPage = true
      self:PlayAnimationReverse(self.FlipPage)
      self:DelaySeconds(self.FlipPage:GetEndTime() / 2, self.SetCurrentPage, self, PageNum)
    end
  end
end

function UMG_Book_C:OnAnimFinished(Animation)
  if Animation == self.In then
    self:InitBook()
  elseif Animation == self.Out then
    self:DoCmd(DialogueModuleCmd.SendZoneReportTaskReq, _G.ProtoEnum.TaskClientTriggerType.TCTT_READ_BOOK, self.ReadID)
    self:DelayFrames(1, self.DoClose, self)
  elseif Animation == self.FlipPage then
    self.bLockFlipPage = false
  end
end

function UMG_Book_C:PlayAudio()
  if self.EventName then
    local MaxMs = _G.NRCAudioManager:GetMaxTimeFromEventName(self.EventName) * 1000
    self.SessionID = _G.NRCAudioManager:PlaySound2DByEventNameAuto(self.EventName, "UMG_Book_C:PlayAudio")
    if MaxMs > 0 and self.SessionID then
      local CurMs = self.CurMs and MaxMs > self.CurMs and self.CurMs or 0
      _G.NRCAudioManager:SeekOnEventBySession(self.SessionID, CurMs / MaxMs)
      _G.NRCAudioManager:AddSessionFinishCallback(self.SessionID, self, self.FinishAudio)
      Log.Debug("UMG_Book_C:PlayAudio", self.CurMs, CurMs, MaxMs)
    else
      _G.NRCAudioManager:ReleaseSession(self.SessionID, true, "UMG_Book_C:PlayAudio")
      self.SessionID = nil
      Log.Error("UMG_Book_C:PlayAudio Audio Time <= 0", MaxMs, self.SessionID)
    end
  end
end

function UMG_Book_C:PauseAudio()
  if self.SessionID then
    self.CurMs = _G.NRCAudioManager:GetPlayPositionInMs(self.SessionID)
    _G.NRCAudioManager:RemoveSessionFinishCallback(self.SessionID)
    _G.NRCAudioManager:ReleaseSession(self.SessionID, true, "UMG_Book_C:PauseAudio")
    self.SessionID = nil
    Log.Debug("UMG_Book_C:PauseAudio", self.CurMs)
  end
end

function UMG_Book_C:FinishAudio()
  self.Autoplay:OnPCKey()
end

function UMG_Book_C:CloseSelf()
  self:PlayAnimationForward(self.Out)
  if _G.GlobalConfig.DebugOpenUI then
    NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
    return
  end
end

function UMG_Book_C:Print()
  local TestText = "<Center>\230\152\168\230\153\154\229\164\170\230\191\128\229\138\168\228\186\134\239\188\140\229\164\167\229\141\138\229\164\156\228\185\159\230\178\161\229\144\136\231\156\188\226\128\166\226\128\166\230\136\145\231\154\132\233\187\145\231\156\188\229\156\136\226\128\166\226\128\166\229\147\173\226\128\166\226\128\166\229\176\143\233\185\172\228\185\159\230\178\161\230\156\137\231\157\161\231\157\128\239\188\129</>\n<Center>\228\184\138\229\177\177\231\154\132\230\151\182\229\128\153\239\188\140\229\165\185\229\176\177\232\182\180\229\156\168\230\136\145\231\154\132\232\130\169\232\134\128\228\184\138\232\161\165\232\167\137\227\128\130\229\165\185\230\156\128\232\191\145\231\156\159\231\154\132\229\144\131\229\164\154\228\186\134\239\188\129\228\184\128\232\182\159\228\184\139\230\157\165\230\136\145\231\154\132\232\133\176\233\131\189\232\166\129\230\150\173\228\186\134\227\128\130</>\n\230\151\169\229\176\177\229\144\172\233\155\133\229\167\144\229\167\144\232\175\180\232\191\135\239\188\140\229\136\176\230\151\182\229\128\153\230\149\153\230\136\145\228\187\172\233\173\148\230\179\149\231\154\132\229\143\175\230\152\175\231\178\190\231\129\181\229\147\159\239\188\140\228\189\134\228\186\178\231\156\188\232\167\129\229\136\176\232\191\152\230\152\175\232\162\171\229\144\147\228\186\134\228\184\128\232\183\179\227\128\130\n\232\142\142\232\142\142\232\128\129\229\184\136\226\128\166\226\128\166\230\188\130\228\186\174\226\128\166\226\128\166\229\152\191\229\152\191\226\128\166\226\128\166\230\175\143\229\189\147\230\136\145\229\173\166\228\188\154\230\150\176\232\175\141\232\175\173\231\154\132\230\151\182\229\128\153\239\188\140\232\142\142\232\142\142\232\128\129\229\184\136\229\176\177\228\188\154\231\148\168\230\159\148\232\189\175\231\154\132\232\186\171\228\189\147\232\185\173\232\185\173\230\136\145\231\154\132\229\164\180\239\188\140\229\131\143\230\158\156\229\134\187\228\184\128\230\160\183\226\128\166\226\128\166\232\189\175\230\180\187\230\180\187\226\128\166\226\128\166\n\232\162\171\233\184\173\232\128\129\229\184\136\230\131\169\231\189\154\228\186\134\239\188\140\229\176\143\233\185\172\231\154\132\231\191\133\232\134\128\230\160\185\230\156\172\230\178\161\229\138\158\230\179\149\233\155\149\229\135\186\229\165\189\231\156\139\231\154\132\232\163\133\233\165\176\239\188\140\233\184\173\232\128\129\229\184\136\232\175\180\232\166\129\229\143\145\230\140\165\231\178\190\231\129\181\228\184\142\230\180\155\229\133\139\231\154\132\233\149\191\229\164\132\239\188\140\233\129\191\229\188\128\231\159\173\229\164\132\227\128\130\n///\233\155\133\229\167\144\229\167\144\228\187\138\229\164\169\231\187\153\230\136\145\229\184\166\228\186\134\229\165\189\229\144\131\231\154\132\229\176\143\233\155\182\233\163\159\239\188\140\229\188\128\229\191\131\229\188\128\229\191\131~\229\144\172\232\175\180\233\155\133\229\167\144\229\167\144\230\152\175\232\191\153\233\135\140\229\173\166\231\154\132\230\156\128\229\165\189\231\154\132\233\173\148\230\179\149\229\184\136\229\145\162\239\188\140\229\134\141\232\191\135\228\184\128\230\174\181\230\151\182\233\151\180\233\155\133\229\167\144\229\167\144\229\143\175\232\131\189\229\176\177\232\166\129\229\142\187\229\177\177\229\183\133\230\142\165\229\143\151\232\175\149\231\130\188\228\186\134\227\128\130\n\230\136\145\229\165\189\231\172\168\226\128\166\226\128\166\230\136\145\232\131\140\228\184\141\228\184\139\230\157\165\233\130\163\228\186\155\233\154\190\230\135\130\231\154\132\231\178\190\231\129\181\232\175\141\230\177\135\239\188\140\228\187\138\229\164\169\229\176\143\233\185\172\230\191\128\229\138\168\229\156\176\232\175\180\228\186\134\228\184\128\233\149\191\228\184\178\239\188\140\230\136\145\229\143\170\232\131\189\229\144\172\230\135\130\228\184\128\231\130\185\231\130\185\226\128\166\226\128\166\232\142\142\232\142\142\232\128\129\229\184\136\233\188\147\229\138\177\228\186\134\230\136\145\239\188\140\229\152\191\229\152\191\226\128\166\226\128\166\n\233\155\133\229\167\144\229\167\144\231\156\159\231\154\132\229\190\136\229\165\189 \239\188\140\229\155\158\230\157\145\228\185\139\229\144\142\229\165\185\228\185\159\228\188\154\231\187\153\230\136\145\229\141\149\231\139\172\229\188\128\229\176\143\231\129\182\239\188\140\229\165\185\231\154\132\229\146\148\229\146\148\233\155\128\232\153\189\231\132\182\231\156\139\232\181\183\230\157\165\229\135\182\229\135\182\231\154\132\239\188\140\228\189\134\230\152\175\229\156\168\233\155\133\229\167\144\229\167\144\233\157\162\229\137\141\232\182\133\228\185\150\231\154\132\227\128\130\n\229\146\140\229\176\143\233\185\172\229\144\181\230\158\182\228\186\134\239\188\129\228\187\138\229\164\169\228\184\141\230\131\179\229\184\166\229\165\185\228\184\138\229\173\166\239\188\129\n\229\146\140\229\165\189\228\186\134\239\188\140\229\176\143\233\185\172\231\187\153\230\136\145\229\184\166\228\186\134\231\148\156\231\148\156\231\154\132\230\158\156\229\173\144\239\188\140\229\139\137\229\188\186\229\142\159\232\176\133\229\176\143\233\185\172\227\128\130\232\128\129\229\184\136\232\175\180\239\188\140\229\175\134\229\136\135\231\154\132\228\188\153\228\188\180\233\156\128\232\166\129\230\156\137\232\135\170\229\183\177\231\139\172\231\137\185\231\154\132\231\167\176\229\145\188\239\188\140\230\136\145\230\131\179\228\186\134\229\190\136\228\185\133\239\188\140\228\189\134\230\152\175\228\184\141\231\159\165\233\129\147\232\175\165\230\128\142\228\185\136\231\187\153\229\176\143\233\185\172\229\143\150\229\144\141\239\188\140\232\142\142\232\142\142\232\128\129\229\184\136\232\175\180\230\136\145\229\143\175\228\187\165\229\142\187\233\151\174\229\176\143\233\185\172\232\135\170\229\183\177\231\154\132\230\132\143\230\128\157\227\128\130\232\142\142\232\142\142\232\128\129\229\184\136\231\156\159\231\154\132\229\165\189\232\129\170\230\152\142\239\188\129\229\176\143\233\185\172\229\165\189\230\178\161\229\147\129\239\188\140\229\165\185\232\175\180\229\165\185\232\166\129\229\143\171\228\184\189\232\142\142\232\180\157\230\139\137\230\156\181\232\156\156\229\174\137\229\141\161\231\137\185\229\184\140\229\168\156\226\128\166\226\128\166\231\191\188\231\159\165\233\129\147\230\136\145\231\191\187\232\175\145\228\186\134\229\164\154\228\185\133\230\137\141\229\144\172\230\135\130\226\128\166\226\128\166\233\169\179\229\155\158\233\169\179\229\155\158\239\188\129\233\155\133\229\167\144\229\167\144\228\187\138\229\164\169\232\166\129\228\184\138\229\177\177\229\149\166\239\188\129\229\184\140\230\156\155\231\191\188\231\142\139\229\164\167\228\186\186\232\131\189\232\174\169\229\165\185\229\146\140\229\146\148\229\146\148\233\155\128\230\136\144\229\138\159\229\165\145\231\186\166\230\152\159\228\185\139\231\187\147\239\188\129\228\184\141\229\143\175\232\131\189\229\144\167\226\128\166\226\128\166\233\155\133\229\167\144\229\167\144\229\164\177\232\180\165\228\186\134\239\188\159\229\165\185\232\175\180\229\165\185\232\181\176\229\174\140\228\186\134\230\156\157\229\156\163\228\185\139\232\183\175\239\188\140\229\156\168\229\165\185\231\171\153\229\136\176\229\177\177\229\183\133\231\165\173\229\143\176\231\154\132\230\151\182\229\128\153\239\188\140\231\191\188\231\142\139\229\164\167\228\186\186\230\178\161\230\156\137\231\187\153\229\165\185\228\187\187\228\189\149\229\155\158\229\186\148\239\188\159\239\188\129\228\184\141\229\143\175\232\131\189\226\128\166\226\128\166\232\142\142\232\142\142\232\128\129\229\184\136\229\146\140\233\184\173\232\128\129\229\184\136\233\131\189\232\175\180</>\n\228\184\141\229\143\175\232\131\189\239\188\140\232\191\158\228\188\138\233\135\140\230\150\175\229\164\167\228\186\186\228\185\159\232\175\180\230\152\175\228\184\141\230\152\175\230\144\158\233\148\153\228\186\134\239\188\140\228\187\150\232\166\129\229\142\187\229\184\174\233\155\133\229\167\144\229\167\144\233\151\174\233\151\174\227\128\130\228\188\138\233\135\140\230\150\175\229\164\167\228\186\186\229\155\158\230\157\165\228\186\134\239\188\140\228\187\150\228\187\128\228\185\136\233\131\189\230\178\161\232\175\180\239\188\140\229\143\170\230\152\175\230\145\135\228\186\134\230\145\135\229\164\180\239\188\140\230\136\145\231\156\139\229\136\176\233\155\133\229\167\144\229\167\144\229\165\189\229\131\143\229\147\173\228\186\134\226\128\166\226\128\166\229\166\130\230\158\156\233\155\133\229\167\144\229\167\144\233\131\189\230\151\160\230\179\149\231\173\190\232\174\162\230\152\159\228\185\139\231\187\147\239\188\140\233\130\163\228\185\136\230\136\145\228\187\172\232\191\153\228\186\155\230\178\161\230\156\137\229\165\185\228\188\152\231\167\128\231\154\132\230\180\155\229\133\139\229\143\136\230\128\142\228\185\136\229\143\175\232\131\189\230\136\144\229\138\159\229\145\162\226\128\166\226\128\166\n\232\142\142\232\142\142\232\128\129\229\184\136\230\156\128\232\191\145\230\152\190\229\190\151\230\156\137\228\186\155\229\191\131\228\184\141\229\156\168\231\132\137\239\188\140\233\184\173\232\128\129\229\184\136\228\185\159\230\128\170\230\128\170\231\154\132\231\154\132\239\188\140\228\187\150\228\187\172\232\175\180\228\186\134\228\184\128\228\186\155\230\136\145\231\142\176\229\156\168\232\191\152\230\178\161\230\179\149\229\144\172\230\135\130\231\154\132\231\178\190\231\129\181\232\175\173\239\188\140\232\175\180\229\174\140\229\144\142\228\187\150\228\191\169\231\154\132\232\132\184\233\131\189\233\187\145\228\184\139\229\142\187\228\186\134\226\128\166\226\128\166\230\156\137\230\151\182\229\128\153\232\191\152\230\140\186\229\186\134\229\185\184\230\136\145\229\144\172\228\184\141\230\135\130\239\188\140\228\184\141\231\132\182\230\136\145\231\154\132\232\132\184\228\185\159\232\166\129\233\187\145\228\186\134\227\128\130\n\233\155\133\229\167\144\229\167\144\231\170\129\231\132\182\230\157\165\230\137\190\230\136\145\239\188\140\229\165\185\232\175\180\229\165\185\232\166\129\228\184\139\229\177\177\227\128\130\n"
  self.PageHeight = self.Dialogue_L.Slot:GetSize().Y
  self:SetBook(self.Text)
end

return UMG_Book_C
