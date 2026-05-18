local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Json = require("Common.JsonUtils")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = DebugTabBase
local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local PSOScanDungeon = require("NewRoco.Modules.System.Debug.PSO.PSOScanDungeon")
local PSOScanBigWorld = require("NewRoco.Modules.System.Debug.PSO.PSOScanBigWorld")
local PSOScanPets = require("NewRoco.Modules.System.Debug.PSO.PSOScanPets")
local PSOScanAvatar = require("NewRoco.Modules.System.Debug.PSO.PSOScanAvatar")
local PSOScanNPC = require("NewRoco.Modules.System.Debug.PSO.PSOScanNPC")
local DebugTabPSOCollection = Base:Extend("DebugTabPSOCollection")

function DebugTabPSOCollection:Ctor()
  Base.Ctor(self)
end

function DebugTabPSOCollection:SetupTabs()
  self:Add("PSO_Scan_Dungeon(\229\137\175\230\156\172)", self.PSO_Scan_Dungeon, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_L_BigWorld_01_Release(\229\164\167\228\184\150\231\149\140)", self.PSO_Scan_BigWorld, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Pets(\231\130\171\229\189\169)", self.PSO_Scan_Pets_Colorful, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Pets(\229\188\130\232\137\178)", self.PSO_Scan_Pets_Shining, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Pets(\231\142\187\231\146\131)", self.PSO_Scan_Pets_Glass, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Pets(\229\153\169\230\162\166)", self.PSO_Scan_Pets_Chaos, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Pets(\229\153\169\230\162\1662)", self.PSO_Scan_Pets_Chaos2, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Avatar(\230\141\162\232\163\133)", self.PSO_Scan_Avatar, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_NPC", self.PSO_Scan_NPC, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
  self:Add("PSO_Scan_Model", self.PSO_Scan_Model, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "")
end

function DebugTabPSOCollection:PSO_Scan_Dungeon(name, panel)
  PSOScanDungeon:Start()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_BigWorld(name, panel)
  PSOScanBigWorld:Start()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Pets_Colorful(name, panel)
  PSOScanPets:Scan_PetColorful()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Pets_Shining(name, panel)
  PSOScanPets:Scan_PetShining()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Pets_Glass(name, panel)
  PSOScanPets:Scan_PetGlass()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Pets_Chaos(name, panel)
  PSOScanPets:Scan_PetChaos()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Pets_Chaos2(name, panel)
  PSOScanPets:Scan_PetChaos2()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Avatar(name, panel)
  PSOScanAvatar:Start()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_NPC(name, panel)
  PSOScanNPC:Start()
  if panel then
    panel:DoClose()
  end
end

function DebugTabPSOCollection:PSO_Scan_Model(name, panel)
  PSOScanNPC:StartModel()
  if panel then
    panel:DoClose()
  end
end

return DebugTabPSOCollection
