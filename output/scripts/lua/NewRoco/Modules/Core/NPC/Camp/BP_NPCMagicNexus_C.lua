local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local MagicCreationUtils = require("NewRoco.Modules.System.MagicCreation.MagicCreationUtils")
local BP_NPCMagicNexus_C = Base:Extend("BP_NPCMagicNexus_C")

function BP_NPCMagicNexus_C:Ctor()
  Base.Ctor(self)
  self.SoundSource = "BP_NPCMagicNexus_C"
  self.SoundIdLoop = 202703
end

function BP_NPCMagicNexus_C:OnFirstVisible()
  local bIsLocal = true
  if self.sceneCharacter then
    bIsLocal = self.sceneCharacter:IsLocal()
  end
  self.Overridden.Initialize(self, bIsLocal)
end

function BP_NPCMagicNexus_C:ReceiveEndPlay()
  self:EndLoopSound()
  Base.ReceiveEndPlay(self)
end

function BP_NPCMagicNexus_C:PlayLoopSound()
  self.AudioIdLoop = _G.NRCAudioManager:PlaySound3DWithActorAuto(self.SoundIdLoop, self, self.SoundSource)
end

function BP_NPCMagicNexus_C:EndLoopSound()
  if self.AudioIdLoop ~= nil then
    _G.NRCAudioManager:ReleaseSession(self.AudioIdLoop, true, self.SoundSource)
  end
end

function BP_NPCMagicNexus_C:UpdateData(ServerData, bIsReconnect)
  if bIsReconnect and self.hasRecycled and self.sceneCharacter.updateEnable then
    MagicCreationUtils.UndoDeleteEffect(self.sceneCharacter)
  end
end

return BP_NPCMagicNexus_C
