local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local AreaAndZone = require("NewRoco.Modules.Core.Scene.Map.AreaAndZoneModule")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = DebugTabBase
local DebugTabAudio = Base:Extend("DebugTabAudio")

function DebugTabAudio:Ctor()
  Base.Ctor(self)
end

function DebugTabAudio:SetupTabs()
  self:Add("\230\137\185\233\135\143\232\174\190\231\189\174BGM-State", self.SetBGMState, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SetBGMState")
  self:Add("\229\155\158\229\189\146\230\153\174\233\128\154BGM", self.EnterCommonBGM, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "EnterCommonBGM")
  self:Add("\231\187\153\230\136\145\229\148\177\230\173\140", self.SingASong, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SingASong")
  self:Add("\229\136\171\229\148\177\228\186\134", self.StopSkill, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "StopSkill")
  self:Add("\232\174\190\231\189\174\231\178\190\231\129\181\232\175\173\233\159\179\230\146\173\230\148\190\233\162\145\231\142\135", self.SetPetVoiceLimit, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SetPetVoiceLimit")
  self:Add("\232\174\190\231\189\174\231\178\190\231\129\181\232\175\173\233\159\179\229\134\183\229\141\180\230\151\182\233\151\180", self.SetPetVoiceCoolDownRange, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "SetPetVoiceCoolDownRange")
end

function DebugTabAudio:SetBGMState()
  local InputText = self:GetInputString()
  _G.NRCAudioManager:BatchSetState(InputText)
end

function DebugTabAudio:EnterCommonBGM()
  _G.NRCAudioManager:BatchSetState("Battle;None")
end

function DebugTabAudio:NPCPlaySound()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    _G.NRCAudioManager:PlaySound3DWithActorAuto(4054, npc.viewObj)
  end
end

function DebugTabAudio:MuteNPC()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    _G.NRCAudioManager:SetEmitterRTPC("GameObj_Volume", 0, npc.viewObj, 0)
  end
end

function DebugTabAudio:CancelMuteNPC()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    _G.NRCAudioManager:SetEmitterRTPC("GameObj_Volume", 100, npc.viewObj, 0)
  end
end

function DebugTabAudio:OpenPetReport(name, panel)
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetReportPanel)
end

function DebugTabAudio:PlaySound2D(name, panel, id)
  if panel then
    local SoundId = panel:GetInputNumber()
    if SoundId <= 0 then
      Log.Warning("\232\175\183\232\190\147\229\133\165\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132\233\159\179\233\162\145ID")
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(SoundId)
  elseif id then
    local SoundId = id
    if SoundId <= 0 then
      Log.Warning("\232\175\183\232\190\147\229\133\165\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132\233\159\179\233\162\145ID")
      return
    end
    _G.NRCAudioManager:PlaySound2DAuto(SoundId)
  end
end

function DebugTabAudio:StopSound2D(name, panel, id)
  if panel then
    local SoundId = panel:GetInputNumber()
    if SoundId <= 0 then
      Log.Warning("\232\175\183\232\190\147\229\133\165\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132\233\159\179\233\162\145ID")
      return
    end
    _G.NRCAudioManager:StopWwiseEventForActor(SoundId)
  elseif id then
    local SoundId = id
    if SoundId <= 0 then
      Log.Warning("\232\175\183\232\190\147\229\133\165\228\184\128\228\184\170\229\144\136\230\179\149\231\154\132\233\159\179\233\162\145ID")
      return
    end
    _G.NRCAudioManager:StopWwiseEventForActor(SoundId)
  end
end

function DebugTabAudio:ShowUIUnlock(name, panel)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowUIUnlock, 1)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowUIUnlock, 5)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.ShowUIUnlock, 6)
end

function DebugTabAudio:DumpBGMArea(name, panel)
  _G.NRCModuleManager:DoCmd(_G.AreaAndZoneModuleCmd.DumpBGMArea)
end

function DebugTabAudio:OpenMagicReward(name, panel)
  _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.FinishNPCOpenLevelUpAwards, self)
end

function DebugTabAudio:KuzhiLevelUp1(name, panel)
end

function DebugTabAudio:PrintData(name, panel)
  Log.Debug("Show Tip")
end

function DebugTabAudio:KuzhiLevelUp2(name, panel)
end

function DebugTabAudio:KuzhiLevelUp3(name, panel)
end

function DebugTabAudio:OnHeavyRain()
  _G.NRCAudioManager:SetGlobalRTPC("GameObjVolume", 0, 1)
end

function DebugTabAudio:OnLightRain()
  _G.NRCAudioManager:SetGlobalRTPC("GameObjVolume", 100, 1)
end

function DebugTabAudio:OnStopRain()
  _G.NRCAudioManager:PlaySound2DAuto(3007, "OnChangeWeather")
end

function DebugTabAudio:EnableLog(name, panel)
  _G.NRCAudioManager:SetAudioLogEnable(true)
end

function DebugTabAudio:DisableLog(name, panel)
  _G.NRCAudioManager:SetAudioLogEnable(false)
end

function DebugTabAudio:ShutUp(name, panel)
  UE4.UAudioManager.MuteAll()
end

function DebugTabAudio:Continue(name, panel)
  UE4.UAudioManager.AllowAll()
end

function DebugTabAudio:TearDown(name, panel)
  _G.NRCAudioManager:TearDownSoundEngine()
end

function DebugTabAudio:Suspend(name, panel)
  _G.NRCAudioManager:Suspend()
end

function DebugTabAudio:Resume(name, panel)
  _G.NRCAudioManager:Resume()
end

function DebugTabAudio:EnableAudioSession(name, panel)
  _G.NRCAudioManager:SetAudioSessionEnable(true)
end

function DebugTabAudio:DisableAudioSession(name, panel)
  _G.NRCAudioManager:SetAudioSessionEnable(false)
end

function DebugTabAudio:PlayVoice(name, panel)
  _G.NRCAudioManager:PlaySound2DAuto(3002, "Language test")
end

function DebugTabAudio:ChangeToChinese(name, panel)
  _G.NRCAudioManager:ChangeLanguage("Chinese")
end

function DebugTabAudio:ChangeToEnglish(name, panel)
  _G.NRCAudioManager:ChangeLanguage("English")
end

function DebugTabAudio:RegisterTime(name, panel)
  self.timeCallback = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.RegisterTime, 0)
end

function DebugTabAudio:ReleaseTime(name, panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ReleaseTime, self.timeCallback)
  self.timeCallback = nil
end

function DebugTabAudio:SkipTwoHoursEnv(name, panel)
  self.timeCallback:UpdateTime(self.timeCallback:GetTime() + 2.0)
end

function DebugTabAudio:SetVolumeMin(name, panel)
  _G.NRCAudioManager:SetOutputVolume(0)
end

function DebugTabAudio:SetVolumeMax(name, panel)
  _G.NRCAudioManager:SetOutputVolume(1)
end

function DebugTabAudio:SetVolume(name, panel, id)
  if panel then
    local volume = tonumber(panel.InputBox:GetText())
    _G.NRCAudioManager:SetOutputVolume(volume)
  elseif id then
    local volume = id
    _G.NRCAudioManager:SetOutputVolume(volume)
  end
end

function DebugTabAudio:LoopPlay(name, panel)
  _G.NRCAudioManager:PlaySound2D(4018, "DebugTabAudio", true, false)
end

function DebugTabAudio:EndLoop(name, panel)
  _G.NRCAudioManager:PlaySound2D(4017, "DebugTabAudio", true, false)
end

function DebugTabAudio:SkipTwoHours(name, panel)
  local currentTime = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, math.floor(currentTime + 7200))
  Log.Debug("EnvSystemModule ", (currentTime + 7200) / 3600)
end

function DebugTabAudio:LoadUnloadTest(name, panel)
  local bank_id1 = AreaAndZone:LoadBank()
  local bank_id2 = AreaAndZone:LoadBank()
  local bank_id3 = AreaAndZone:LoadBank()
  AreaAndZone:UnLoadBank(bank_id1)
  AreaAndZone:UnLoadBank(bank_id2)
  AreaAndZone:UnLoadBank(bank_id3)
end

function DebugTabAudio:BlingBling(name, panel)
  _G.NRCAudioManager:PlaySound2DAuto(1001, "DebugTabAudio")
end

function DebugTabAudio:JumpOneDay(name, panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.SkipOneDay)
end

function DebugTabAudio:SetState(name, panel)
  _G.NRCModuleManager:DoCmd(LevelUpUIModuleCmd.SendQueryLevelAwardReq)
end

function DebugTabAudio:SetState2(name, panel)
  UE4.UAudioManager.SetStateByName("World_Time", "night", self)
end

function DebugTabAudio:SetGlobal(name, panel)
  _G.NRCAudioManager:SetGlobalRTPC("Fly_Speed", 1.5, 0, "Source")
end

function DebugTabAudio:ResetGlobal(name, panel)
  _G.NRCAudioManager:ResetGlobalRTPC("Fly_Speed", 0, "Source")
end

function DebugTabAudio:PrintGlobal(name, panel)
  Log.Debug("PrintGlobal", _G.NRCAudioManager:GetGlobalRTPC("Fly_Speed", "Source"))
end

function DebugTabAudio:UnloadBGM(name, panel, id)
  if panel then
    local idRec = tonumber(panel.InputBox:GetText())
    AreaAndZone:UnLoadBank(idRec)
  elseif id then
    local idRec = id
    AreaAndZone:UnLoadBank(idRec)
  end
end

function DebugTabAudio:StopBGM(name, panel)
  AreaAndZone:OnBGMStop()
end

function DebugTabAudio:ShowRegisterInfo(name, panel)
  _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.ShowRegisterArray)
end

function DebugTabAudio:GetCurrentTime(name, panel)
  local CurrentGameTime, ref_game_time, ref_real_time = _G.NRCModuleManager:DoCmd(EnvSystemModuleCmd.GetCurrentTime)
  Log.Error("GetCurrentTime: ", CurrentGameTime)
  Log.Error("ref_game_time: ", ref_game_time, "ref_real_time: ", ref_real_time)
end

function DebugTabAudio:GoToMorning(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, 21600)
end

function DebugTabAudio:GoToNoon(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, 43200)
end

function DebugTabAudio:GoToNight(name, panel)
  NRCModuleManager:DoCmd(EnvSystemModuleCmd.GMChangeGameTime, 72000)
end

function DebugTabAudio:OpenLevelUp(name, panel)
end

function DebugTabAudio:OpenMagicUp(name, panel)
end

function DebugTabAudio:OpenMagicUpVolume(name, panel)
end

function DebugTabAudio:OpenMagicUpHpMax(name, panel)
end

function DebugTabAudio:ReduceRoleHp(name, panel)
end

function DebugTabAudio:OpenCampingBuild(name, panel)
end

function DebugTabAudio:OpenPetTeam(name, panel)
  _G.IsOpenNewPetTeamReplaceMessage = true
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenPetTeamPanel, Enum.PlayerTeamType.PTT_PVP_BATTLE_1)
end

function DebugTabAudio:OpenPetWarehouseMain()
  _G.NRCModuleManager:DoCmd(PetUIModuleCmd.OpenPetwarehousePanel)
end

function DebugTabAudio:PlayMiracleExchangeSkill(name, panel)
  _G.NRCModuleManager:DoCmd(_G.MiracleExchangeModuleCmd.PlayFinishSkill)
end

function DebugTabAudio:SingASong()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    local skillProxy = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/PetScenePerform/G6_BWC_700018_CG1M", npc.viewObj.RocoSkill)
    skillProxy:SetCaster(npc.viewObj)
    skillProxy:SetPassive(false)
    skillProxy:PlaySkill()
    npc.AIComponent:ForceLockForReason(true, false, 1)
  end
end

function DebugTabAudio:StopSkill()
  local npc = _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.GetNearestNPC)
  if npc then
    npc.viewObj.RocoSkill:StopCurrentSkill()
    npc.AIComponent:ForceLockForReason(false, false, 1)
  end
end

function DebugTabAudio:SetPetVoiceLimit(name, panel)
  local params
  if panel then
    params = string.split(panel.InputBox:GetText(), " ")
  else
    params = ""
  end
  _G.NRCAudioManager:SetPetSoundLimit(tonumber(params[1]), tonumber(params[2] or "1"), tonumber(params[3] or "1"))
end

function DebugTabAudio:SetPetVoiceCoolDownRange(name, panel)
  local params
  if panel then
    params = string.split(panel.InputBox:GetText(), " ")
  else
    params = ""
  end
  _G.NRCAudioManager:SetCommonRandomCoolDown(tonumber(params[1] or "3"), tonumber(params[2] or "10"))
end

return DebugTabAudio
