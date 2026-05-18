local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local TaskModuleEvent = require("NewRoco.Modules.Core.Task.TaskModuleEvent")
local BattleShowHide = require("NewRoco.Modules.Core.NPC.ShowHide.BattleShowHide")
local BlockingArea = Class()
BlockingArea.BlockingAreaParam = {}

local function createBlockingAreaParam()
  return {
    location = nil,
    radius = 0,
    nav_moder = nil,
    request = nil,
    overlap_callback = nil,
    overlap_caller = nil,
    InBattle = false
  }
end

function BlockingArea:Ctor()
  self.area_dict = {}
end

function BlockingArea:Init()
end

function BlockingArea:UnInit()
  self.area_dict = {}
end

function BlockingArea:RegisterArea(from, location, radius, forceEnable, priority)
  Log.Debug("BlockingArea: \231\148\159\230\136\144\229\174\137\229\133\168\229\140\186 @ ", from, location)
  if self.area_dict[from] == nil then
    local newArea = createBlockingAreaParam()
    self.area_dict[from] = newArea
  end
  self.area_dict[from].location = location
  self.area_dict[from].radius = radius
  if BattleShowHide:IsBattleCreateArea(from) then
    self.area_dict[from].InBattle = true
  else
    self.area_dict[from].InBattle = false
  end
  self:CreateSafeAreaNavModifierAsync(self.area_dict[from], location, radius, forceEnable, priority)
  return self.area_dict[from]
end

function BlockingArea:UnregisterArea(from)
  local area = self.area_dict[from]
  if nil ~= area then
    Log.Debug("BlockingArea: \231\167\187\233\153\164\229\174\137\229\133\168\229\140\186 @ ", from)
    if area.nav_moder and UE4.UObject.IsValid(area.nav_moder) then
      area.nav_moder:K2_DestroyActor()
      area.nav_moder = nil
    end
    if area.request then
      NRCResourceManager:UnLoadRes(area.request)
      area.request = nil
    end
    area.overlap_caller = nil
    area.overlap_callback = nil
    self.area_dict[from] = nil
  end
end

function BlockingArea:CreateSafeAreaNavModifierAsync(parameter, pos, rad, forceEnable, priority)
  local trans = UE4.FTransform()
  trans.Translation = pos
  trans.Scale3D = UE4.FVector(rad / 50, rad / 50, 20)
  priority = priority or PriorityEnum.Passive_World_AI_BlockingArea
  parameter.request = NRCResourceManager:LoadResAsync(self, UEPath.NAV_MODER_AVOID, priority, 0, function(this, request, class)
    local nav_moder = UE4Helper.GetCurrentWorld():Abs_SpawnActor(class, trans)
    nav_moder.owner_area = parameter
    if forceEnable then
      nav_moder:SetForceDisperse(true)
    end
    parameter.nav_moder = nav_moder
    if nav_moder.OverlapOtherActorOnSpawn and UE.UObject.IsValid(nav_moder.OverlapOtherActorOnSpawn) then
      nav_moder:OnMeshOverlapImp(nav_moder.OverlapOtherActorOnSpawn)
    end
  end, function()
  end)
end

function BlockingArea:OnTick()
  for _, v in pairs(self.area_dict) do
    UE4.UKismetSystemLibrary.Abs_DrawDebugSphere(UE4Helper.GetCurrentWorld(), v.location, v.radius, 20, UE4.FLinearColor(math.rand(0, 0.1), 1, 0, 1), 0.2, 3)
  end
end

function BlockingArea:AddTestArea()
  local center = UE4.FVector(-887.381958, -236.648331, -3293.025879)
  self:RegisterArea(1, center, 1000)
end

return BlockingArea
