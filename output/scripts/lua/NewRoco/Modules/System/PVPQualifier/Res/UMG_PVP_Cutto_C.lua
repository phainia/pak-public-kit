local PVPRankedMatchModuleEvent = require("NewRoco.Modules.System.PVPQualifier.PVPRankedMatchModuleEvent")
local UMG_PVP_Cutto_C = _G.NRCPanelBase:Extend("UMG_PVP_Cutto_C")
local Step1TimeOut = 5
local Step2TimeOut = 120
local Step3TimeOut = 10
local Step23To4TimeOut = 5

function UMG_PVP_Cutto_C:OnConstruct()
  self.caller = nil
  self.callBack = nil
  self.stepTimer = nil
  self.curStep = 0
  self.bStoppingAnimation = false
  self.bInAnimFinished = false
  self.bPanelPreloaded = false
  self.audioSessionId = nil
end

function UMG_PVP_Cutto_C:OnActive(callName, Caller, CallBack, bSkipShowSeaon, bUObjectCaller)
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnActive(setup callback)", callName, Caller, CallBack, bSkipShowSeaon, bUObjectCaller)
  self.caller = Caller
  self.callBack = CallBack
  self.bSkipShowSeaon = bSkipShowSeaon
  self.bUObjectCaller = bUObjectCaller
  self:Step1()
end

function UMG_PVP_Cutto_C:OnDeactive()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnDeactive")
  if self.caller or self.callBack then
    Log.Error("SeasonOpen Progress: UMG_PVP_Cutto_C Deactive but callback not nil", self.caller, self.callBack)
  end
  self.caller = nil
  self.callBack = nil
  self.bUObjectCaller = nil
  self:_CleanStepTimer()
  self:TryStopAudio()
  self:UnRegisterAllEvents()
end

function UMG_PVP_Cutto_C:UnRegisterAllEvents()
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnStep1_1_OnEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationLoaded, self.Step2_2_OnEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationFinished, self.Step3)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonResetRankAnimationFinished, self.Step3To4)
end

function UMG_PVP_Cutto_C:_CleanStepTimer()
  DelayManager:CancelDelayByIdEx(self.stepTimer)
  self.stepTimer = nil
end

function UMG_PVP_Cutto_C:Step1()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step1")
  self:_CleanStepTimer()
  local bOK = self:DoStep_ShowFadeIn()
  if bOK then
    self:Step1_1()
    local animLength = self.In:GetEndTime() - self.In:GetStartTime()
    self.stepTimer = DelayManager:DelaySeconds(animLength + Step1TimeOut, self.OnStep1Timeout, self)
  else
    self:Step4()
  end
end

function UMG_PVP_Cutto_C:OnStep1Timeout()
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnStep1_1_OnEnd)
  self.bStoppingAnimation = true
  self:StopAnimation(self.In)
  self.bStoppingAnimation = false
  self:Step2()
end

function UMG_PVP_Cutto_C:Step1_1()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step1_1", self.bSkipShowSeaon)
  if self.bSkipShowSeaon then
    self:OnStep1_1_OnEnd()
  else
    _G.NRCEventCenter:RegisterEvent("UMG_PVP_Cutto_C", self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnStep1_1_OnEnd)
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.TryOpenPVPRankedMatch)
  end
end

function UMG_PVP_Cutto_C:OnStep1_1_OnEnd()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnStep1_1_OnEnd")
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.SetPvpInfoQueryData, self.OnStep1_1_OnEnd)
  self:TryStep2()
end

function UMG_PVP_Cutto_C:TryStep2()
  local bRspReceived = self.module.data:HasPvpSeasonData()
  local bAnimFinished = self.bInAnimFinished
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:TryStep2", self.bSkipShowSeaon, bRspReceived, self.bInAnimFinished)
  if (self.bSkipShowSeaon or bRspReceived) and bAnimFinished then
    self:Step2()
  end
end

function UMG_PVP_Cutto_C:Step2()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step2", self.bSkipShowSeaon)
  self:_CleanStepTimer()
  if self.bSkipShowSeaon then
    self:Step4()
  else
    local bOK = self:DoStep_ShowSeasonOpen()
    if bOK then
      self:Step2_1()
      self.stepTimer = DelayManager:DelaySeconds(Step2TimeOut, self.OnStep2Timeout, self)
    else
      self:Step4()
    end
  end
end

function UMG_PVP_Cutto_C:OnStep2Timeout()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnStep2Timeout")
  self:Step3()
end

function UMG_PVP_Cutto_C:Step2_1()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step2_1(PlayAnimation(self.In_SeasonOpen))")
  self:PlayAnimation(self.In_SeasonOpen)
end

function UMG_PVP_Cutto_C:OnAnimationFinished_In_SeasonOpen()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnAnimationFinished_In_SeasonOpen")
  self:Step2_1_OnEnd()
end

function UMG_PVP_Cutto_C:Step2_1_OnEnd()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step2_1_OnEnd(self.bIn_SeasonOpenEnded = true)")
  self.bIn_SeasonOpenEnded = true
  self:TryStep2_3()
end

function UMG_PVP_Cutto_C:Step2_2_OnEnd()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step2_2_OnEnd(self.bVideoLoaded = true)")
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationLoaded, self.Step2_2_OnEnd)
  self.bVideoLoaded = true
  self:TryStep2_3()
end

function UMG_PVP_Cutto_C:TryStep2_3()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:TryStep2_3(CmdPlaySeasonOpen)", "self.bVideoLoaded", self.bVideoLoaded, "self.bIn_SeasonOpenEnded", self.bIn_SeasonOpenEnded)
  if self.bVideoLoaded and self.bIn_SeasonOpenEnded then
    _G.NRCEventCenter:RegisterEvent("UMG_PVP_Cutto_C", self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationFinished, self.Step3)
    _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdPlaySeasonOpen)
    self:TryPlayAudio()
  end
end

function UMG_PVP_Cutto_C:Step3()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step3(Try SeasonOpen)")
  self:_CleanStepTimer()
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationLoaded, self.Step2_2_OnEnd)
  _G.NRCEventCenter:UnRegisterEvent(self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationFinished, self.Step3)
  local currentSeasonId = self.module.data:GetCurSeasonId()
  local firstSeasonId = self.module.data:GetFirstSeasonId()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step3(Try SeasonOpen) - 2 (currentSeasonId, firstSeasonId)", currentSeasonId, firstSeasonId)
  local bFirstSeason = currentSeasonId == firstSeasonId
  if self.module.__debugFirstSeason ~= nil then
    bFirstSeason = self.module.__debugFirstSeason
  end
  if bFirstSeason then
    self:Step2To4()
    return
  end
  local bOK = self:DoStep_ShowSeasonRank()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step3(Try SeasonOpen) - 3 (bOK)", bOK)
  if bOK then
    self.stepTimer = DelayManager:DelaySeconds(Step3TimeOut, self.OnStep3Timeout, self)
  else
    self:Step4()
  end
end

function UMG_PVP_Cutto_C:OnStep3Timeout()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnStep3Timeout")
  self:Step3To4()
end

function UMG_PVP_Cutto_C:Step2To4()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step2To4(PlayAnimation(SeasonOpen.Out))")
  self:Step23To4()
end

function UMG_PVP_Cutto_C:Step3To4()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step3To4(PlayAnimation(SeasonRank.Out))")
  self:Step23To4()
end

function UMG_PVP_Cutto_C:Step23To4()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step23To4(PlayAnimation(self.Out_SeasonOpen))")
  self:_CleanStepTimer()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonOpen, false)
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonRank, false)
  self:PlayAnimation(self.Out_SeasonOpen)
  self.stepTimer = DelayManager:DelaySeconds(Step23To4TimeOut, self.OnStep23To4TimeOut, self)
end

function UMG_PVP_Cutto_C:OnAnimationFinished_Out_SeasonOpen()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnAnimationFinished_Out_SeasonOpen")
  self:Step23To4_OnEnd()
end

function UMG_PVP_Cutto_C:OnStep23To4TimeOut()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnStep23To4TimeOut(warning!)")
  self:StopAllAnimations()
  self:Step23To4_OnEnd()
end

function UMG_PVP_Cutto_C:Step23To4_OnEnd()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step23To4_OnEnd")
  self:Step4()
end

function UMG_PVP_Cutto_C:Step4()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:Step4")
  self:_CleanStepTimer()
  self:UnRegisterAllEvents()
  self:TryStopAudio()
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonOpen, false)
  _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonRank, false)
  self:DoStep_ShowFadeOut()
end

function UMG_PVP_Cutto_C:DoStep_ShowFadeIn()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoStep_ShowFadeIn")
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(BattleConst.SoundId.BattleLoading, "UMG_PVP_Cutto_C")
  self:PlayAnimation(self.In)
  _G.BattleBudget:GC(true)
  return true
end

function UMG_PVP_Cutto_C:OnAnimationFinished_In()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnAnimationFinished_In")
  self.bInAnimFinished = true
  if not self.bStoppingAnimation then
    self:TryStep2()
  end
end

function UMG_PVP_Cutto_C:DoStep_ShowSeasonOpen()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoStep_ShowSeasonOpen")
  local bOpened = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonOpen, true)
  if bOpened then
    _G.NRCEventCenter:RegisterEvent("UMG_PVP_Cutto_C", self, PVPRankedMatchModuleEvent.UI_SeasonOpenAnimationLoaded, self.Step2_2_OnEnd)
    return true
  end
  return false
end

function UMG_PVP_Cutto_C:DoStep_ShowSeasonRank()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoStep_ShowSeasonRank")
  local bOpened = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdTrySwitch_UMG_SeasonRank, true)
  if bOpened then
    _G.NRCEventCenter:RegisterEvent("UMG_PVP_Cutto_C", self, PVPRankedMatchModuleEvent.UI_SeasonResetRankAnimationFinished, self.Step3To4)
    return true
  end
  return false
end

function UMG_PVP_Cutto_C:DoStep_ShowFadeOut()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoStep_ShowFadeOut")
  _G.NRCEventCenter:DispatchEvent(PVPRankedMatchModuleEvent.UI_OpenPVPCuttoPanelEvent)
  self:DoCallBack()
  return true
end

function UMG_PVP_Cutto_C:DoStep_ShowFadeOut2()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoStep_ShowFadeOut2", self.bPlayingOut)
  if not self.bPlayingOut then
    self.bPlayingOut = true
    self:PlayAnimation(self.Out)
  end
end

function UMG_PVP_Cutto_C:OnAnimationFinished_Out()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:OnAnimationFinished_Out")
  self.bPlayingOut = false
  _G.NRCEventCenter:DispatchEvent(PVPRankedMatchModuleEvent.UI_ClosePVPCuttoPanelEvent)
  self:TryClose()
end

function UMG_PVP_Cutto_C:DoCallBack()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:DoCallBack")
  UMG_PVP_Cutto_C.SafeDoCallBackImpl(self.caller, self.callBack, self.bUObjectCaller)
  self.caller = nil
  self.callBack = nil
  self.bUObjectCaller = nil
end

function UMG_PVP_Cutto_C.SafeDoCallBackImpl(caller, callback, bUObjectCaller)
  if bUObjectCaller then
    if caller and UE4.UObject.IsValid(caller) then
      Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(UObject)", caller, callback, bUObjectCaller)
      if callback then
        Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(UObject) callback", caller, callback, bUObjectCaller)
        callback(caller)
      else
        Log.Warning("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(UObject) callback is nil!!", caller, callback, bUObjectCaller)
      end
    else
      Log.Warning("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(UObject) caller is nil or already destroyed!!", caller, callback, bUObjectCaller)
    end
  elseif caller then
    if callback then
      Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(LuaTable)", caller, callback, bUObjectCaller)
      callback(caller)
    else
      Log.Warning("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(LuaTable) callback is nil!!", caller, callback, bUObjectCaller)
    end
  elseif callback then
    Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(LuaTable)", caller, callback, bUObjectCaller)
    callback()
  else
    Log.Warning("SeasonOpen Progress: UMG_PVP_Cutto_C.SafeDoCallBackImpl(LuaTable) callback is nil!!", caller, callback, bUObjectCaller)
  end
end

function UMG_PVP_Cutto_C:ReplaceCallBack(callName, Caller, CallBack, bSkipShowSeaon, bUObjectCaller)
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:ReplaceCallBack", callName, Caller, CallBack, bSkipShowSeaon, bUObjectCaller)
  self:DoCallBack()
  self.caller = Caller
  self.callBack = CallBack
  self.bSkipShowSeaon = bSkipShowSeaon
  self.bUObjectCaller = bUObjectCaller
end

function UMG_PVP_Cutto_C:TryClose()
  self:DoClose()
end

function UMG_PVP_Cutto_C:OnTouchEnded(MyGeometry, InTouchEvent)
  if _G.GlobalConfig.DebugOpenUI then
    self:DoStep_ShowFadeOut2()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_PVP_Cutto_C:PlayCloseAnim()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:PlayCloseAnim(setup out callback)")
  self:DoStep_ShowFadeOut2()
end

function UMG_PVP_Cutto_C:TryPlayAudio()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:TryPlayAudio")
  local seasonConf
  local curSeasonId = _G.NRCModuleManager:DoCmd(_G.PVPRankedMatchModuleCmd.CmdGetCurSeasonId)
  if curSeasonId then
    seasonConf = _G.DataConfigManager:GetPvpRankSeasonConf(curSeasonId)
  end
  if not seasonConf then
    return false
  end
  local soundId = seasonConf.sound_id
  if not soundId then
    return false
  end
  if soundId and not self.audioSessionId then
    self.audioSessionId = _G.NRCAudioManager:PlaySound2DAuto(soundId, "UMG_PVP_Cutto_C:TryPlayAudio")
    _G.NRCAudioManager:SetStateByName("Story_Movie", "Story")
  end
  return true
end

function UMG_PVP_Cutto_C:TryStopAudio()
  Log.Debug("SeasonOpen Progress: UMG_PVP_Cutto_C:TryStopAudio")
  if self.audioSessionId then
    local asidToRelease = self.audioSessionId
    self.audioSessionId = nil
    _G.NRCAudioManager:ReleaseSession(asidToRelease, true, "UMG_PVP_Cutto_C:TryStopAudio", false, 2)
    _G.NRCAudioManager:SetStateByName("Story_Movie", "None")
  end
end

function UMG_PVP_Cutto_C:OnAnimationFinished(anim)
  if anim == self.In then
    self:OnAnimationFinished_In()
  elseif anim == self.Out then
    self:OnAnimationFinished_Out()
  elseif anim == self.In_SeasonOpen then
    self:OnAnimationFinished_In_SeasonOpen()
  elseif anim == self.Out_SeasonOpen then
    self:OnAnimationFinished_Out_SeasonOpen()
  end
end

return UMG_PVP_Cutto_C
