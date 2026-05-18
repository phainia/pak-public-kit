local FarmModuleEnum = require("NewRoco.Modules.System.Farm.FarmModuleEnum")
local FarmConst = {}
FarmConst.SkillPath = {
  Sowing = "/Game/ArtRes/Effects/G6Skill/Home/G6_Home_Sowing",
  Harvesting = "/Game/ArtRes/Effects/G6Skill/Home/G6_Home_Caiji",
  Watering = "/Game/ArtRes/Effects/G6Skill/Home/G6_Home_JiaoShui",
  Fertilizing = "/Game/ArtRes/Effects/G6Skill/Home/G6_Home_ShiFei",
  UnlockEntrance = "/Game/ArtRes/Effects/G6Skill/Home/G6_Home_EnvCollected_Box"
}
FarmConst.SpecialNPCId = {FarmBoardNPCId = 700699, FarmEntranceNPCId = 520195}
FarmConst.UIColor = {
  Normal = "#FFFFFF",
  Harvest = "#D56C1F",
  LackCoin = "#CF3D3E",
  Pressed = "#272727"
}
FarmConst.LandNum = 15
return FarmConst
