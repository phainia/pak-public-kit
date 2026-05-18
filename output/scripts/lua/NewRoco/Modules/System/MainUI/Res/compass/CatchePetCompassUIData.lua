local NPCCompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.NPCCompassUIData")
local Base = NPCCompassUIData
local CatchePetCompassUIData = Base:Extend("CatchePetCompassUIData")

function CatchePetCompassUIData:InitData(Info, worldMap, ViewField)
  Base.InitData(self, Info, worldMap, ViewField)
  self.IsCathPetNpc = true
  self.IsFinshCatchAnimation = false
  self:SetIsShow(true)
  self:DisableDistanceLevel()
  if self.CompWidget then
    self.CompWidget:PlayAnimationIn4()
  end
end

function CatchePetCompassUIData:SetIcon()
  if self.CompWidget then
    self.CompWidget:SetIcon()
  end
end

function CatchePetCompassUIData:UpdateData(Info, worldMap, ViewField)
  self:SetPos(Info.Position)
  self.WorldMapConfig = worldMap
  self.IsUnLock = Info.IsUnLock
  self.NpcConfig = Info.NpcConfig
  self.NPC_level = Info.NPC_Level
  if self.CompWidget then
    self.CompWidget:PlayAnimation(self.Light4_loop, 0, 0)
    self.CompWidget:PlayAnimationLoop4()
  end
end

return CatchePetCompassUIData
