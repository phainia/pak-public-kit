local BattleCameraSettingItem_C = _G.NRCPanelBase:Extend("BattleCameraSettingItem_C")

function BattleCameraSettingItem_C:OnConstruct()
  self.tbox.OnTextCommitted:Add(self, self.ApplyChanges)
  self.CameraRef = BattleManager.vBattleField.battleCameraManager
end

function BattleCameraSettingItem_C:OnDestruct()
end

function BattleCameraSettingItem_C:OnActive()
end

function BattleCameraSettingItem_C:OnDeactive()
end

function BattleCameraSettingItem_C:ApplyChanges()
  if self.key and self.CurTag then
    if self.bodykey and self.key2 then
      self.CameraRef.Settings[self.CurTag][self.key][self.bodykey][self.key2] = tonumber(self.tbox:GetText())
    else
      self.CameraRef.Settings[self.CurTag][self.key] = tonumber(self.tbox:GetText())
    end
  end
end

return BattleCameraSettingItem_C
