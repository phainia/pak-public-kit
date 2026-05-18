local UMG_MiniGame_TaskComponentItem_C = _G.NRCPanelBase:Extend("UMG_MiniGame_TaskComponentItem_C")
local MiniGameModuleEvent = reload("NewRoco.Modules.System.MiniGame.MiniGameModuleEvent")

function UMG_MiniGame_TaskComponentItem_C:OnActive()
end

function UMG_MiniGame_TaskComponentItem_C:OnDeactive()
end

function UMG_MiniGame_TaskComponentItem_C:OnMouseDown()
  NRCEventCenter:DispatchEvent(MiniGameModuleEvent.OnTaskClick)
  _G.NRCAudioManager:PlaySound2DAuto(1220002022, "MiniGameModule show beam")
end

return UMG_MiniGame_TaskComponentItem_C
