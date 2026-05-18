local UMG_Skill_C = NRCUmgClass:Extend("")
local _PressTime = 0.5
local _timer = 0
local _pressed = false
local _Detailed = false

function UMG_Skill_C:Construct()
  self.LongPressedButton.OnPressed:Add(self, UMG_Skill_C.OnPressed_Timer)
  self.LongPressedButton.OnReleased:Add(self, UMG_Skill_C.OnReleased_Timer)
end

function UMG_Skill_C:OnPressed_Timer()
  _pressed = true
end

function UMG_Skill_C:OnReleased_Timer()
  _timer = 0
  _pressed = false
  _Detailed = false
end

function UMG_Skill_C:Tick(MyGeometry, InDeltaTime)
  if _pressed then
    _timer = _timer + 0.01
    if _timer > _PressTime and false == _Detailed then
      UMG_Skill_C:ShowDetail()
      _Detailed = true
    end
  end
end

function UMG_Skill_C:ShowDetail()
  Log.Debug("------------------------------------------Detail")
end

return UMG_Skill_C
