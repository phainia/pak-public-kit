local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local Base = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local DebugTabMaterial = Base:Extend("DebugTabMaterial")

function DebugTabMaterial:Ctor()
  Base.Ctor(self)
end

function DebugTabMaterial:SetupTabs()
  self:Add("\232\167\146\232\137\178\230\157\144\232\180\168\228\191\174\230\148\185\230\181\139\232\175\149", self.TogglePlayerMaterialModifyTest, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "TogglePlayerMaterialModifyTest")
end

local bUseDepthOffset = true
local bTestColor = false

function DebugTabMaterial:TogglePetPixelDepth(name, panel)
  Log.Debug("DebugTabMaterial:TogglePetPixelDepth")
  bUseDepthOffset = not bUseDepthOffset
  UE4.UNRCMaterialLibrary.ChangeGlobalSwitchParameterByBaseMaterialName("M_P_Eyes", "UseDepthOffset", bUseDepthOffset)
  UE4.UNRCMaterialLibrary.ChangeGlobalSwitchParameterByBaseMaterialName("M_P_Object", "UseDepthOffset", bUseDepthOffset)
end

function DebugTabMaterial:ToggleColorTest(name, panel)
  Log.Debug("DebugTabMaterial:TogglePetPixelDepth")
  bTestColor = not bTestColor
  UE4.UNRCMaterialLibrary.ChangeGlobalSwitchParameterByBaseMaterialNameAndInsName("M_P_Object", "XingGuang", "bTestColor", bTestColor)
end

local bPlayerMaterialTest = false

function DebugTabMaterial:TogglePlayerMaterialModifyTest(name, panel)
  bPlayerMaterialTest = not bPlayerMaterialTest
  Log.Debug("DebugTabMaterial:TogglePlayerMaterialTest " .. tostring(bPlayerMaterialTest))
  local player = UE4.UGameplayStatics.GetPlayerCharacter(UE4Helper.GetCurrentWorld(), 0)
  if player then
    local materialComponent = player:GetComponentByClass(UE4.URocoMaterialComponent)
    if materialComponent then
      if bPlayerMaterialTest then
        local meshComponents = player:K2_GetComponentsByClass(UE4.UMeshComponent)
        for idx = 1, meshComponents:Length() do
          local meshComponent = meshComponents:Get(idx)
          local materials = meshComponent:GetMaterials()
          for jdx = 1, materials:Length() do
            local MID = materialComponent:ModifyMaterialByIndexSingleMesh(materials:Get(jdx), jdx - 1, meshComponent, self)
            if MID then
              MID:SetVectorParameterValue("FresnelColor", UE4.FLinearColor(0.166667, 0.009958, 0.003325, 0.0))
              MID:SetScalarParameterValue("FresnelIntensity", 0.2)
              MID:SetScalarParameterValue("FresnelBaseMin", 1.0)
              MID:SetScalarParameterValue("FresnelExponent", 0.0)
              MID:SetScalarParameterValue("FresnelBoost", 15.0)
            end
          end
        end
      else
        materialComponent:UnmodifyMaterial(self)
      end
    end
  end
end

return DebugTabMaterial
