require("UnLuaEx")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local a = require("Common.Coroutine.async")
local au = require("Common.Coroutine.async_util")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_Scene_Miaomiao_C = Base:Extend("BP_Scene_Miaomiao_C")

function BP_Scene_Miaomiao_C:RecycleNPC(npc)
  self:ResetActionState()
  self.req = nil
end

local HUD_CLASS_PATH = "WidgetBlueprint'/Game/NewRoco/Modules/System/MainUI/Res/UMG_Hud_Pet.UMG_Hud_Pet_C'"

function BP_Scene_Miaomiao_C:OnFrameLoad(distanceRatio)
  if not SceneUtils.debugCloseNPCFacialAndWidget then
    local Character = self.sceneCharacter
    if Character then
      local task = a.task(function()
        local isSuccess, request, asset_or_message = au.LoadResource(HUD_CLASS_PATH, 4, 10)
        if isSuccess and not Character.isDestroy then
          local hudClass = asset_or_message
          local hud = UE4.UWidgetBlueprintLibrary.Create(self, hudClass)
          self.HeadWidget:SetWidget(hud)
          if UE.UObject.IsValid(hud) then
            hud:SetParentHUD(self.HeadWidget)
          end
          self.req = request
          if Character.PetHUDComponent then
            Character.PetHUDComponent:OnFrameLoaded()
          end
        end
      end)
      local context = task()
    end
  end
  Base.OnFrameLoad(self, distanceRatio)
end

function BP_Scene_Miaomiao_C:ResetActionState()
  self.Throw_Done = false
end

return BP_Scene_Miaomiao_C
