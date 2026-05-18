local SKILL_PATH = "/Game/ArtRes/Effects/G6Skill/Pet_Hide/Pet_Hide"
local Base = require("NewRoco.Modules.Core.Scene.Component.Hidden.Actions.HiddenActionDrill")
local HiddenActionHide = Base:Extend("HiddenActionHide")

function HiddenActionHide:Init(comp)
  Base.Init(self, comp)
  self.skillPath = _G.NRCUtils.FormatBlueprintAssetPath(SKILL_PATH)
end

function HiddenActionHide:LoopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:PlayAnimByName("HideLoop", 1, 0, 0, 0.2, -1)
  end
end

function HiddenActionHide:StopAnim()
  local animComp = self.owner:GetAnimComponent()
  if animComp and UE.UObject.IsValid(animComp) then
    animComp:StopAnimByName("HideLoop", 0.2)
  end
end

return HiddenActionHide
