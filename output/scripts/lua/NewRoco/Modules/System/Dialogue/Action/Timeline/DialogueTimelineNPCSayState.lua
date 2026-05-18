local DialogueUtils = require("NewRoco.Modules.System.Dialogue.DialogueUtils")
local FsmUtils = require("NewRoco.Modules.Core.Fsm.FsmUtils")
local Base = require("NewRoco.Modules.System.Dialogue.Action.Timeline.DialogueTimelineActionState")
local DialogueTimelineNPCSayState = Base:Extend("DialogueTimelineNPCSayState")
FsmUtils.MergeMembers(Base, DialogueTimelineNPCSayState, {
  {
    name = "PlayFacialAnim",
    type = "bool",
    default = true,
    display_name = "\230\152\175\229\144\166\230\146\173\230\148\190\229\143\163\229\158\139\229\138\168\231\148\187"
  }
})

function DialogueTimelineNPCSayState:Ctor(name, properties)
  Base.Ctor(self, name, properties)
  self.SoundFileName = ""
end

function DialogueTimelineNPCSayState:OnPreload()
  Base.OnPreload(self)
  self:InjectProperties()
  self.SoundFileName = ""
  self.AudioData = nil
  self.AudioDataRef = nil
  self.ResRequest = nil
  local CurrentTimeline = self.fsm:GetProperty("CurrentTimeline")
  local play_dialogue_sound_when_say_action_without_data = nil == CurrentTimeline.play_dialogue_sound_when_say_action_without_data or CurrentTimeline.play_dialogue_sound_when_say_action_without_data
  if string.IsNilOrEmpty(self.SoundFileName) and play_dialogue_sound_when_say_action_without_data then
    local CurrentDialogueConf = self.fsm:GetProperty("CurrentDialogue")
    if CurrentDialogueConf then
      self.SoundFileName = CurrentDialogueConf.dialogue_sound
      self:SetProperty("SoundFileName", CurrentDialogueConf.dialogue_sound)
      if 0 == self.OwnerActorID and CurrentDialogueConf.speaker then
        self:SetProperty("OwnerActorID", CurrentDialogueConf.speaker)
        self.OwnerActorID = CurrentDialogueConf.speaker
      end
    end
  end
  local SpeakContent = self.SoundFileName
  if string.IsNilOrEmpty(SpeakContent) then
    return
  end
  if nil == self.OwnerActorID or nil == self.PlayFacialAnim then
    return
  end
  if 0 == self.OwnerActorID then
    self.PlayFacialAnim = false
    self:SetProperty("PlayFacialAnim", false)
  end
  if self.PlayFacialAnim then
    if 0 == self.OwnerActorID then
      Log.Debug("\229\175\185\232\175\157SpeakerId\228\184\1860")
    end
    if not _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.CheckLipSyncExists, SpeakContent) then
      Log.Debug("\229\143\163\229\158\139\232\181\132\230\186\144\228\184\141\229\173\152\229\156\168...", SpeakContent)
      return
    end
    local AssetPath = string.format("/Game/ArtRes/BP/Lipsync/%s.%s", SpeakContent, SpeakContent)
    self.ResRequest = _G.NRCResourceManager:LoadResAsync(self, AssetPath, 1, 0, self.OnPreloadFinish, self.OnPreloadFailed)
    self.state:AddPreloadingAction(self)
  end
end

function DialogueTimelineNPCSayState:OnPreloadFinish(resRequest, asset)
  self.AudioData = asset
  self.AudioDataRef = asset and UnLua.Ref(asset)
  if self.state.RemovePreloadingAction then
    self.state:RemovePreloadingAction(self)
  end
end

function DialogueTimelineNPCSayState:OnPreloadFailed()
  self.ResRequest = nil
  self.AudioData = nil
  self.AudioDataRef = nil
  if self.state.RemovePreloadingAction then
    self.state:RemovePreloadingAction(self)
  end
end

function DialogueTimelineNPCSayState:OnEnter()
  Base.OnEnter(self)
  if DialogueUtils.SkipDialogue then
    self:Finish()
    return
  end
  if string.IsNilOrEmpty(self.SoundFileName) or self.PlayFacialAnim == nil then
    return
  end
  local ParentModule = self.fsm:GetProperty("ParentModule")
  if ParentModule then
    ParentModule:PlayDialogueAudio(self.SoundFileName)
  end
  if self.fsm.LastSpeaker then
    DialogueUtils.StopTalk(self.fsm.LastSpeaker, 0.1)
    self.fsm.LastSpeaker = nil
  end
  if self.PlayFacialAnim then
    if not self.ResRequest then
      return
    end
    if not self.AudioData then
      return
    end
    local Speaker = self:GetActor(self.OwnerActorID)
    if not Speaker then
      return
    end
    local View = DialogueUtils.ExtraActorView(Speaker)
    local MeshComp = View and View.Mesh
    local AnimInstance = MeshComp and MeshComp:GetAnimInstance()
    if not AnimInstance then
      Log.Error("\230\151\160\230\179\149\230\137\190\229\136\176\232\167\146\232\137\178\232\186\171\228\184\138\231\154\132AnimInstance", View and UE.UObject.GetName(View) or "\230\178\161\230\156\137ViewObject")
      return
    end
    if not AnimInstance:IsA(UE.UCharacterEmotionAnimInstance) then
      Log.Error("\232\191\153\228\184\170NPC\232\174\178\228\184\141\228\186\134\232\175\157 ", View and UE.UObject.GetName(View) or "\230\178\161\230\156\137ViewObject")
      return
    end
    Log.Debug(UE.UObject.GetName(View), "\232\166\129\229\188\128\229\167\139\232\174\178\232\175\157\228\186\134", UE.UObject.GetName(self.AudioData))
    self.fsm.LastSpeaker = Speaker
    AnimInstance:PlayEmotion(self.AudioData, 0.1)
  end
end

function DialogueTimelineNPCSayState:OnFinish()
  if self.Request then
    _G.NRCResourceManager:UnLoadRes(self.Request)
    self.Request = nil
  end
  self.AudioDataRef = nil
  Base.OnFinish(self)
end

return DialogueTimelineNPCSayState
