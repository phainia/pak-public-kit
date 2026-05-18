local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local CameraAdditiveParamStatus = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamStatus")
local CameraAdditiveParamType = require("NewRoco.Modules.Core.Character.WorldCamera.CameraAdditiveParamType")
local Base = NPCActionBase
local NPCActionDungeonGate = Base:Extend("NPCActionDungeonGate")

function NPCActionDungeonGate:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
end

function NPCActionDungeonGate:Execute()
  Base.Execute(self)
  self:Finish(true)
end

function NPCActionDungeonGate:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
end

function NPCActionDungeonGate:OnNpcAction()
  if self:GetLayerVisiblePanelCount(_G.Enum.UILayerType.UI_LAYER_LEVEL_LOADING) > 0 then
    Log.Debug("NPCActionDungeonGate:OnNpcAction: UI_LAYER_LEVEL_LOADING exists!")
    return false
  end
  Log.Debug("NPCActionDungeonGate:OnNpcAction: pass!")
  return Base.OnNpcAction(self)
end

function NPCActionDungeonGate:GetLayerVisiblePanelCount(panelLayer)
  local Ctrl = _G.NRCPanelManager.layerCenter:GetLayerCtrl(panelLayer)
  local Panels = Ctrl:GetAllWindow()
  local Count = 0
  if Panels then
    for _, Panel in ipairs(Panels) do
      if Panel.enableView then
        Count = Count + 1
        Log.Debug("NPCActionDungeonGate:GetLayerVisiblePanelCount: Visible!", table.getKeyName(_G.Enum.UILayerType, panelLayer), Panel.panelName)
      end
    end
  end
  return Count
end

return NPCActionDungeonGate
