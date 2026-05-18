require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local NPCAppearComponent = require("NewRoco.Modules.Core.NPC.ViewNPCComponent.NPCAppearComponent")
local BP_NPCAppear_C = Base:Extend("BP_NPCAppear_C")

function BP_NPCAppear_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCAppear_C:Init()
  Base.Init(self)
  self.bEmptyNPC = true
end

function BP_NPCAppear_C:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCAppear_C:LoadLockEffect()
end

function BP_NPCAppear_C:PlayUnlockEffect(lockNum)
end

function BP_NPCAppear_C:OnFrameLoad(distanceRatio)
  if self.HeadWidget then
    self:InitWidgetComponent(self.HeadWidget)
    local HeadWidget = self.HeadWidget
    local config = self.sceneCharacter and self.sceneCharacter.config
    local icon_height = config and config.icon_height or 0
    if 0 ~= icon_height then
      HeadWidget:K2_SetRelativeLocation(UE4.FVector(0, 0, icon_height), false, nil, false)
    end
  end
end

return BP_NPCAppear_C
