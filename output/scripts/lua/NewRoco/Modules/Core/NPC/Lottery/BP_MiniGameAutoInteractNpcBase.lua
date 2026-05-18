local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local ResObject = require("NewRoco.Utils.ResObject")
local BP_MiniGameAutoInteractNpcBase = Base:Extend("BP_MiniGameAutoInteractNpcBase")

function BP_MiniGameAutoInteractNpcBase:Initialize(Initializer)
  Base.Initialize(self, Initializer)
  self.DieRes = false
end

function BP_MiniGameAutoInteractNpcBase:OnFirstVisible()
  self.DieRes = false
  Base.OnFirstVisible(self)
  if not self.DieRes then
    self.DieRes = ResObject.MakeUClass("/Game/ArtRes/Effects/G6Skill/SceneEffect/MiniGame/G6_Scene_Minigame_TreatFx.G6_Scene_Minigame_TreatFx_C", 100)
    if self.DieRes and self.DieRes.StartLoad then
      self.DieRes:StartLoad()
    else
      self.DieRes = nil
      Log.Debug("Failed to create DieRes object")
    end
  end
end

function BP_MiniGameAutoInteractNpcBase:ReceiveEndPlay()
  if self.DieRes then
    self.DieRes:Release()
    self.DieRes = nil
  end
  Base.ReceiveEndPlay(self)
end

function BP_MiniGameAutoInteractNpcBase:OnVisible()
  Base.OnVisible(self)
  self:SwitchOpaque(false)
  _G.UpdateManager:Register(self)
end

function BP_MiniGameAutoInteractNpcBase:OnOptionChange()
end

function BP_MiniGameAutoInteractNpcBase:OnInVisible()
  _G.UpdateManager:UnRegister(self)
  Base.OnInVisible(self)
end

function BP_MiniGameAutoInteractNpcBase:OnTick(DeltaSeconds)
  if not self then
    _G.UpdateManager:UnRegister(self)
  end
  local OriginalRot = self:K2_GetActorRotation()
  if not OriginalRot then
    _G.UpdateManager:UnRegister(self)
    return
  end
  OriginalRot.Yaw = OriginalRot.Yaw + DeltaSeconds * 90
  self:K2_SetActorRotation(OriginalRot, true)
end

function BP_MiniGameAutoInteractNpcBase:ReceiveDestroyed()
  _G.UpdateManager:UnRegister(self)
  Base.ReceiveDestroyed(self)
end

function BP_MiniGameAutoInteractNpcBase:UpdateOpacity(bEnabled)
  if self.bEnabled == bEnabled then
    return
  end
  self.bEnabled = bEnabled
  self:SwitchOpaque(not bEnabled)
end

return BP_MiniGameAutoInteractNpcBase
