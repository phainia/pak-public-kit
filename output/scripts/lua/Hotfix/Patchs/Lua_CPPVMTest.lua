local Lua_CPPVMTest = {}
local TestCase1_tag_1 = "CPPVMTest::TestPrimitiveValue(signed char, short, int, long long, unsigned char, unsigned short, unsigned int, unsigned long long, float, double, bool, FString, FName, FText, FMyHotfixStruct)"
local TestCase1_tag_2 = "CPPVMTest::TestPrimitiveRef(signed char&, short&, int&, long long&, unsigned char&, unsigned short&, unsigned int&, unsigned long long&, float&, double&, bool&, FString&, FMyHotfixStruct&)"
Lua_CPPVMTest[TestCase1_tag_1] = function(OutRet, InSelf, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15)
  local m_A1 = DynamicCast(A1, UE4.UEInt8)
  m_A1.Value = 128
  local m_A2 = DynamicCast(A2, UE4.UEInt16)
  m_A2.Value = 32768
  local m_A3 = DynamicCast(A3, UE4.UEInt32)
  m_A3.Value = 2147483648
  local m_A4 = DynamicCast(A4, UE4.UEInt64)
  m_A4.Value = -9223372036854775808
  local m_A5 = DynamicCast(A5, UE4.UEUInt8)
  m_A5.Value = 256
  local m_A6 = DynamicCast(A6, UE4.UEUInt16)
  m_A6.Value = 65536
  local m_A7 = DynamicCast(A7, UE4.UEUInt32)
  m_A7.Value = 4294967296
  local m_A8 = DynamicCast(A8, UE4.UEUInt64)
  m_A8.Value = 0
  local m_A9 = DynamicCast(A9, UE4.UEFloat)
  m_A9.Value = 0.1111
  local m_A10 = DynamicCast(A10, UE4.UEDouble)
  m_A10.Value = 0.111111111
  local m_A11 = DynamicCast(A11, UE4.UEBool)
  m_A11.Value = false
  local m_A12 = DynamicCast(A12, UE4.UEFString)
  m_A12.Value = "case1 \230\181\139\232\175\149 FString"
  local m_A15 = DynamicCast(A15, UE4.FMyHotfixStruct)
  m_A15.a = 10
  m_A15.b = 10
  return true
end
Lua_CPPVMTest[TestCase1_tag_2] = function(OutRet, InSelf, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A15)
  local m_A1 = DynamicCast(A1, UE4.UEInt8)
  m_A1.Value = 128
  local m_A2 = DynamicCast(A2, UE4.UEInt16)
  m_A2.Value = 32768
  local m_A3 = DynamicCast(A3, UE4.UEInt32)
  m_A3.Value = 2147483648
  local m_A4 = DynamicCast(A4, UE4.UEInt64)
  m_A4.Value = -9223372036854775808
  local m_A5 = DynamicCast(A5, UE4.UEUInt8)
  m_A5.Value = 256
  local m_A6 = DynamicCast(A6, UE4.UEUInt16)
  m_A6.Value = 65536
  local m_A7 = DynamicCast(A7, UE4.UEUInt32)
  m_A7.Value = 4294967296
  local m_A8 = DynamicCast(A8, UE4.UEUInt64)
  m_A8.Value = 0
  local m_A9 = DynamicCast(A9, UE4.UEFloat)
  m_A9.Value = 0.1111
  local m_A10 = DynamicCast(A10, UE4.UEDouble)
  m_A10.Value = 0.111111111
  local m_A11 = DynamicCast(A11, UE4.UEBool)
  m_A11.Value = false
  local m_A12 = DynamicCast(A12, UE4.UEFString)
  m_A12.Value = "case1 \230\181\139\232\175\149\229\143\130\230\149\176 FString"
  local m_A15 = DynamicCast(A15, UE4.FMyHotfixStruct)
  m_A15.a = 10
  m_A15.b = 10
  return true
end
local TestCase1_tag_3 = "CPPVMTest::TestRetInt8()"
local TestCase1_tag_4 = "CPPVMTest::TestRetInt16()"
local TestCase1_tag_5 = "CPPVMTest::TestRetInt32()"
local TestCase1_tag_6 = "CPPVMTest::TestRetInt64()"
local TestCase1_tag_7 = "CPPVMTest::TestRetUInt8()"
local TestCase1_tag_8 = "CPPVMTest::TestRetUInt16()"
local TestCase1_tag_9 = "CPPVMTest::TestRetUInt32()"
local TestCase1_tag_10 = "CPPVMTest::TestRetUInt64()"
local TestCase1_tag_11 = "CPPVMTest::TestRetFloat()"
local TestCase1_tag_12 = "CPPVMTest::TestRetDouble()"
local TestCase1_tag_13 = "CPPVMTest::TestRetbool()"
local TestCase1_tag_14 = "CPPVMTest::TestRetFString()"
local TestCase1_tag_15 = "CPPVMTest::TestRetCustomUClass()"
local TestCase1_tag_16 = "CPPVMTest::TestRetCustomStruct()"
Lua_CPPVMTest[TestCase1_tag_3] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEInt8)
  Ret.Value = 128
  return true
end
Lua_CPPVMTest[TestCase1_tag_4] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEInt16)
  Ret.Value = 32768
  return true
end
Lua_CPPVMTest[TestCase1_tag_5] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEInt32)
  Ret.Value = 2147483648
  return true
end
Lua_CPPVMTest[TestCase1_tag_6] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEInt64)
  Ret.Value = -9223372036854775808
  return true
end
Lua_CPPVMTest[TestCase1_tag_7] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEUInt8)
  Ret.Value = 256
  return true
end
Lua_CPPVMTest[TestCase1_tag_8] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEUInt16)
  Ret.Value = 65536
  return true
end
Lua_CPPVMTest[TestCase1_tag_9] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEUInt32)
  Ret.Value = 4294967296
  return true
end
Lua_CPPVMTest[TestCase1_tag_10] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEUInt64)
  Ret.Value = 0
  return true
end
Lua_CPPVMTest[TestCase1_tag_11] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEFloat)
  Ret.Value = 0.1111
  return true
end
Lua_CPPVMTest[TestCase1_tag_12] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEDouble)
  Ret.Value = 0.111111111
  return true
end
Lua_CPPVMTest[TestCase1_tag_13] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEBool)
  Ret.Value = false
  return true
end
Lua_CPPVMTest[TestCase1_tag_14] = function(OutRet, InSelf)
  local Ret = DynamicCast(OutRet, UE4.UEFString)
  Ret.Value = "case1 ret FString"
  return true
end
Lua_CPPVMTest[TestCase1_tag_16] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.FMyHotfixStruct)
  local myStruct = UE4.FMyHotfixStruct()
  myStruct.a = 100
  myStruct.b = 200
  m_A1:CopyFrom(myStruct)
  return true
end
local TestCase2_tag_1 = "CPPVMTest::TestContainerValue(TArray<int, TSizedDefaultAllocator<32>>, TMap<int, int, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, int, false>>, TSet<int, DefaultKeyFuncs<int, false>, FDefaultSetAllocator>, TArray<FVector, TSizedDefaultAllocator<32>>, TMap<int, FVector, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, FVector, false>>, TSet<FVector, DefaultKeyFuncs<FVector, false>, FDefaultSetAllocator>, TArray<UObject*, TSizedDefaultAllocator<32>>, TMap<int, UObject*, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, UObject*, false>>, TSet<UObject*, DefaultKeyFuncs<UObject*, false>, FDefaultSetAllocator>)"
local TestCase2_tag_2 = "CPPVMTest::TestContainerRef(TArray<int, TSizedDefaultAllocator<32>>&, TMap<int, int, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, int, false>>&, TSet<int, DefaultKeyFuncs<int, false>, FDefaultSetAllocator>&, TArray<FVector, TSizedDefaultAllocator<32>>&, TMap<int, FVector, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, FVector, false>>&, TSet<FVector, DefaultKeyFuncs<FVector, false>, FDefaultSetAllocator>&, TArray<UObject*, TSizedDefaultAllocator<32>>&, TMap<int, UObject*, FDefaultSetAllocator, TDefaultMapHashableKeyFuncs<int, UObject*, false>>&, TSet<UObject*, DefaultKeyFuncs<UObject*, false>, FDefaultSetAllocator>&)"
Lua_CPPVMTest[TestCase2_tag_1] = function(ret, obj, A1, A2, A3, A4, A5, A6, A7, A8, A9)
  local m_A1 = DynamicCast(A1, UE4.TArray, 0)
  m_A1:Add(0)
  local m_A2 = DynamicCast(A2, UE4.TMap, 0, 0)
  m_A2:Add(3, 0)
  local m_A3 = DynamicCast(A3, UE4.TSet, 0)
  m_A3:Add(0)
  local m_A4 = DynamicCast(A4, UE4.TArray, UE4.FVector)
  m_A4:Add(UE4.FVector(1, 1, 1))
  local m_A5 = DynamicCast(A5, UE4.TMap, 0, UE4.FVector)
  m_A5:Add(3, UE4.FVector(1, 1, 1))
  local m_A6 = DynamicCast(A6, UE4.TSet, UE4.FVector)
  m_A6:Add(UE4.FVector(1, 1, 1))
  local m_A7 = DynamicCast(A7, UE4.TArray, UE4.UObject)
  m_A7:Add(nil)
  local m_A8 = DynamicCast(A8, UE4.TMap, 0, UE4.UObject)
  m_A8:Add(3, nil)
  local m_A9 = DynamicCast(A9, UE4.TSet, UE4.UObject)
  m_A9:Add(nil)
  return true
end
Lua_CPPVMTest[TestCase2_tag_2] = function(ret, obj, A1, A2, A3, A4, A5, A6, A7, A8, A9)
  local m_A1 = DynamicCast(A1, UE4.TArray, 0)
  m_A1:Add(0)
  local m_A2 = DynamicCast(A2, UE4.TMap, 0, 0)
  m_A2:Add(3, 0)
  local m_A3 = DynamicCast(A3, UE4.TSet, 0)
  m_A3:Add(0)
  local m_A4 = DynamicCast(A4, UE4.TArray, UE4.FVector)
  m_A4:Add(UE4.FVector(1, 1, 1))
  local m_A5 = DynamicCast(A5, UE4.TMap, 0, UE4.FVector)
  m_A5:Add(3, UE4.FVector(1, 1, 1))
  local m_A6 = DynamicCast(A6, UE4.TSet, UE4.FVector)
  m_A6:Add(UE4.FVector(1, 1, 1))
  local m_A7 = DynamicCast(A7, UE4.TArray, UE4.UObject)
  m_A7:Add(nil)
  local m_A8 = DynamicCast(A8, UE4.TMap, 0, UE4.UObject)
  m_A8:Add(3, nil)
  local m_A9 = DynamicCast(A9, UE4.TSet, UE4.UObject)
  m_A9:Add(nil)
  return true
end
local TestCase2_tag_3 = "CPPVMTest::TestRetTArrayInt()"
local TestCase2_tag_4 = "CPPVMTest::TestRetTArrayFStruct()"
local TestCase2_tag_5 = "CPPVMTest::TestRetTArrayUObject()"
local TestCase2_tag_6 = "CPPVMTest::TestRetTMapIntInt()"
local TestCase2_tag_7 = "CPPVMTest::TestRetTMapIntStruct()"
local TestCase2_tag_8 = "CPPVMTest::TestRetTMapIntUObject()"
local TestCase2_tag_9 = "CPPVMTest::TestRetTSetInt()"
local TestCase2_tag_10 = "CPPVMTest::TestRetTSetFStruct()"
local TestCase2_tag_11 = "CPPVMTest::TestRetTSetUObject()"
Lua_CPPVMTest[TestCase2_tag_3] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TArray, 0)
  m_A1:Init()
  m_A1:Add(6)
  return true
end
Lua_CPPVMTest[TestCase2_tag_4] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TArray, UE4.FVector)
  m_A1:Init()
  m_A1:Add(UE4.FVector(0, 0, 0))
  return true
end
Lua_CPPVMTest[TestCase2_tag_5] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TArray, UE4.UObject)
  m_A1:Init()
  m_A1:Add(nil)
  return true
end
Lua_CPPVMTest[TestCase2_tag_6] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TMap, 0, 0)
  m_A1:Init()
  m_A1:Add(10, 11)
  return true
end
Lua_CPPVMTest[TestCase2_tag_7] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TMap, 0, UE4.FVector)
  m_A1:Init()
  m_A1:Add(3, UE4.FVector(0, 0, 0))
  return true
end
Lua_CPPVMTest[TestCase2_tag_8] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TMap, 0, UE4.UObject)
  m_A1:Init()
  m_A1:Add(5, nil)
  return true
end
Lua_CPPVMTest[TestCase2_tag_9] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TSet, 0)
  m_A1:Init()
  m_A1:Add(0)
  return true
end
Lua_CPPVMTest[TestCase2_tag_10] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TSet, UE4.FVector)
  m_A1:Init()
  m_A1:Add(UE4.FVector(0, 0, 0))
  return true
end
Lua_CPPVMTest[TestCase2_tag_11] = function(ret, obj)
  local m_A1 = DynamicCast(ret, UE4.TSet, UE4.UObject)
  m_A1:Init()
  m_A1:Add(nil)
  return true
end
return Lua_CPPVMTest
