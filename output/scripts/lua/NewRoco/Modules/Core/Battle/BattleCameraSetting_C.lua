local BattleCameraSetting_C = _G.NRCPanelBase:Extend("BattleCameraSetting_C")

function BattleCameraSetting_C:OnConstruct()
  BattleResourceManager:LoadClassAsync(self, "/Game/NewRoco/Modules/Core/Battle/BattleCameraSettingItem.BattleCameraSettingItem", self.OnSettingItemLoad)
  self.CameraRef = BattleManager.vBattleField.battleCameraManager
  self.apply.OnReleased:Add(self, self.RefreshCamera)
  self.save.OnReleased:Add(self, self.SaveCamera)
  self.widgCollection = {}
end

function BattleCameraSetting_C:OnSettingItemLoad(settingItemClass)
  self.ChildKlass = settingItemClass
  self.ChildKlassRef = settingItemClass and UnLua.Ref(settingItemClass)
end

function BattleCameraSetting_C:RefreshCamera()
  self.CameraRef:ChangeByOperateType(self.CameraRef.CurOperateType)
end

function BattleCameraSetting_C:SaveCamera()
  self.CameraRef:SaveCameraSettings()
end

function BattleCameraSetting_C:ChangeCameraSetting()
  self.sb:ClearChildren()
  for k, setting in pairs(self.widgCollection) do
    setting:Destruct()
  end
  for k, setting in pairs(self.CameraRef.Settings[self.CameraRef.CurrentTag]) do
    if "BodyTypeOverride" == k then
      for v, innersetting in pairs(setting[self.CameraRef.CurBodyType]) do
        local widg = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), self.ChildKlass, UE4.UGameplayStatics:GetPlayerController(0))
        table.insert(self.widgCollection, widg)
        self.sb:AddChild(widg)
        widg.CurTag = self.CameraRef.CurrentTag
        widg.key = k
        widg.key2 = v
        widg.bodykey = self.CameraRef.CurBodyType
        widg.dbox:SetText(v)
        widg.tbox:SetText(innersetting)
      end
    elseif "XOffset" == k or "YOffset" == k or "Use" == k then
    elseif self.CameraRef.Settings[self.CameraRef.CurrentTag].BodyTypeOverride and ("Height" == k or "FOV" == k or "Degrees" == k) then
    else
      local widg = UE4.UWidgetBlueprintLibrary.Create(UE4Helper.GetCurrentWorld(), self.ChildKlass, UE4.UGameplayStatics:GetPlayerController(0))
      table.insert(self.widgCollection, widg)
      self.sb:AddChild(widg)
      widg.CurTag = self.CameraRef.CurrentTag
      widg.key = k
      widg.dbox:SetText(k)
      widg.tbox:SetText(setting)
    end
  end
end

return BattleCameraSetting_C
