// c 2024-03-19
// m 2024-03-19

const uint16 O_AIR_MODE_BOOL = GetMemberOffset("CGameCtnEditorFree", "GridColor") - 0x34;  // 0xBD4 - 0xC08 (GridColor)

bool AirBlockModeActive(CGameCtnEditorFree@ Editor) {
    return Dev::GetOffsetUint8(Editor, O_AIR_MODE_BOOL) > 0;
}

uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for \"" + className + "\"");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + className + "\"");

    return member.Offset;
}

const uint16 GetMemberOffset(CMwNod@ nod, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::TypeOf(nod);

    if (type is null)
        throw("Unable to find reflection info for nod");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + type.Name + "\"");

    return member.Offset;
}

void Tab_Offsets() {
    if (!UI::BeginTabItem("Map Block Offsets"))
        return;

    UI::BeginDisabled(loadingMapBlocks);
    if (UI::Button("Load Map Blocks"))
        startnew(LoadMapBlocks);
    UI::EndDisabled();

    UI::BeginTabBar("offset-tabs");
        for (uint i = 0; i < mapBlocks.Length; i++) {
            Block@ block = mapBlocks[i];

            if (UI::BeginTabItem(block.id.GetName() + " " + i)) {
                Table_Offsets(block.block);
                UI::EndTabItem();
            }
        }
        if (tempNod !is null && UI::BeginTabItem("tempNod")) {
            Table_Offsets(tempNod);
            UI::EndTabItem();
        }
    UI::EndTabBar();

    UI::EndTabItem();
}

const uint[] knownOffsets = {
    40, 72, 96, 100, 104, 144, 560, 808
};

void Table_Offsets(CMwNod@ nod) {
    if (nod is null)
        return;

    UI::Text("refs: " + Reflection::GetRefCount(nod));

    const uint64 ptr = Dev_GetPointerForNod(nod);
    UI::Text("nod ptr: " + ptr + " (" + FormatPointer(ptr) + ")");

    if (UI::Button("Explore"))
        ExploreNod("nod", nod, Reflection::TypeOf(nod));

    if (nod is tempNod) {
        UI::SameLine();
        if (UI::Button("Nullify"))
            @tempNod = null;
    }

    if (!UI::BeginTable("##table-offsets", 3, UI::TableFlags::RowBg | UI::TableFlags::ScrollY))
        return;

    UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

    UI::TableSetupScrollFreeze(0, 1);
    UI::TableSetupColumn("Offset (dec)", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
    UI::TableSetupColumn("Offset (hex)", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
    UI::TableSetupColumn("Value (" + tostring(S_OffsetType) + ")");
    UI::TableHeadersRow();

    UI::ListClipper clipper((S_OffsetMax / S_OffsetSkip) + 1);
    while (clipper.Step()) {
        for (int j = clipper.DisplayStart; j < clipper.DisplayEnd; j++) {
            const int offset = j * S_OffsetSkip;
            const string color = nod !is tempNod && knownOffsets.Find(offset) > -1 ? WHITE : RED;

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::Text(color + (offset));

            UI::TableNextColumn();
            UI::Text(color + IntToHex(offset));

            UI::TableNextColumn();
            string value;
            try {
                switch (S_OffsetType) {
                    case DataType::Bool:   value = Round(    Dev::GetOffsetInt8(  nod, offset) == 1); break;
                    case DataType::Int8:   value = Round(    Dev::GetOffsetInt8(  nod, offset));      break;
                    case DataType::Uint8:  value = RoundUint(Dev::GetOffsetUint8( nod, offset));      break;
                    case DataType::Int16:  value = Round(    Dev::GetOffsetInt16( nod, offset));      break;
                    case DataType::Uint16: value = RoundUint(Dev::GetOffsetUint16(nod, offset));      break;
                    case DataType::Int32:  value = Round(    Dev::GetOffsetInt32( nod, offset));      break;
                    case DataType::Uint32: value = RoundUint(Dev::GetOffsetUint32(nod, offset));      break;
                    case DataType::Int64:  value = Round(    Dev::GetOffsetInt64( nod, offset));      break;
                    case DataType::Uint64: value = RoundUint(Dev::GetOffsetUint64(nod, offset));      break;
                    case DataType::Float:  value = Round(    Dev::GetOffsetFloat( nod, offset));      break;
                    case DataType::Vec2:   value = Round(    Dev::GetOffsetVec2(  nod, offset));      break;
                    case DataType::Vec3:   value = Round(    Dev::GetOffsetVec3(  nod, offset));      break;
                    case DataType::Vec4:   value = Round(    Dev::GetOffsetVec4(  nod, offset));      break;
                    case DataType::Iso4:   value = Round(    Dev::GetOffsetIso4(  nod, offset));      break;
                    default:               value = "Unsupported!";
                }
            } catch {
                UI::Text(YELLOW + getExceptionInfo());
            }
            const bool maybePointer = PointerLooksGood(Dev::GetOffsetUint64(nod, offset)) && offset % 8 == 0;
            if (maybePointer) {
                const string raw = StripFormatCodes(value).Replace("\\", "");
                value = PURPLE + raw + " (" + FormatPointer(Text::ParseUInt64(raw)) + ")";
            }
            if (UI::Selectable(value, false))
                SetClipboard(value);
            if (UI::IsItemHovered() && maybePointer) {
                if (UI::IsMouseClicked(UI::MouseButton::Right)) {
                    print("clicked pointer");
                    @tempNod = Dev::GetOffsetNod(nod, offset);
                }
                if (UI::IsMouseClicked(UI::MouseButton::Middle))
                    print(Dev::GetOffsetString(nod, offset));
            }
        }
    }

    UI::PopStyleColor();
    UI::EndTable();
}

CMwNod@ tempNod;

bool PointerLooksGood(uint64 ptr) {
    if (ptr < 0xFFFFFFFF || ptr >> 48 > 0)
        return false;
    return ptr >= 0x10000000000 && ptr % 8 == 0 && ptr <= Dev::BaseAddressEnd();
}

const string BLUE   = "\\$09D";
const string CYAN   = "\\$2FF";
const string GRAY   = "\\$888";
const string GREEN  = "\\$0D2";
const string ORANGE = "\\$F90";
const string PURPLE = "\\$F0F";
const string RED    = "\\$F00";
const string WHITE  = "\\$FFF";
const string YELLOW = "\\$FF0";

enum DataType {
    Bool,
    Int8,
    Uint8,
    Int16,
    Uint16,
    Int32,
    Uint32,
    Int64,
    Uint64,
    Float,
    // Double,
    Vec2,
    Vec3,
    Vec4,
    // Iso3,
    Iso4,
    // Nat2,
    // Nat3,
    // String
    Enum
}

[Setting category="Dev" name="Float precision" min=0 max=9]
uint S_Precision = 3;

[Setting category="Dev" name="Offset data type"]
DataType S_OffsetType = DataType::Int32;

[Setting category="Dev" name="Offset bytes skip" min=1 max=12]
uint S_OffsetSkip = 4;

[Setting category="Dev" name="Offset max distance" min=100 max=10000 description="Very high values are not recommended"]
uint S_OffsetMax = 3000;

string Round(bool b) {
    return (b ? GREEN : RED) + b;
}

string Round(int num) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Math::Abs(num);
}

string Round(float num, uint precision = S_Precision) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num));
}

string Round(vec2 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision);
}

string Round(vec3 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision) + "\\$G , " + Round(vec.z, precision);
}

string Round(vec4 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision) + "\\$G , " + Round(vec.z, precision) + "\\$G , " + Round(vec.w, precision);
}

string Round(iso4 iso, uint precision = S_Precision) {
    string ret;

    ret += Round(iso.tx, precision) + "\\$G , " + Round(iso.ty, precision) + "\\$G , " + Round(iso.tz, precision) + "\n";
    ret += Round(iso.xx, precision) + "\\$G , " + Round(iso.xy, precision) + "\\$G , " + Round(iso.xz, precision) + "\n";
    ret += Round(iso.yx, precision) + "\\$G , " + Round(iso.yy, precision) + "\\$G , " + Round(iso.yz, precision) + "\n";
    ret += Round(iso.zx, precision) + "\\$G , " + Round(iso.zy, precision) + "\\$G , " + Round(iso.zz, precision);

    return ret;
}

string RoundUint(uint num) {  // separate function else a uint gets converted to an int, losing data
    return (num == 0 ? WHITE : GREEN) + num;
}

void SetClipboard(const string &in text) {
    IO::SetClipboard(StripFormatCodes(text).Replace("\\", ""));
}

uint64[] memoryAllocations = array<uint64>();

uint64 Dev_Allocate(uint size, bool exec = false) {
    return RequestMemory(size, exec);
}

uint64 RequestMemory(uint size, bool exec = false) {
    auto ptr = Dev::Allocate(size, exec);
    memoryAllocations.InsertLast(ptr);
    return ptr;
}

void FreeAllAllocated() {
    for (uint i = 0; i < memoryAllocations.Length; i++) {
        Dev::Free(memoryAllocations[i]);
    }
    memoryAllocations.RemoveRange(0, memoryAllocations.Length);
}

namespace NodPtrs {
    void InitializeTmpPointer() {
        g_TmpPtrSpace = RequestMemory(0x1000);
        auto nod = CMwNod();
        uint64 tmp = Dev::GetOffsetUint64(nod, 0);
        Dev::SetOffset(nod, 0, g_TmpPtrSpace);
        @g_TmpSpaceAsNod = Dev::GetOffsetNod(nod, 0);
        Dev::SetOffset(nod, 0, tmp);
    }

    uint64 g_TmpPtrSpace = 0;
    CMwNod@ g_TmpSpaceAsNod = null;
}

CMwNod@ Dev_GetArbitraryNodAt(uint64 ptr) {
    if (NodPtrs::g_TmpPtrSpace == 0) {
        NodPtrs::InitializeTmpPointer();
    }
    if (ptr == 0) throw('null pointer passed');
    Dev::SetOffset(NodPtrs::g_TmpSpaceAsNod, 0, ptr);
    return Dev::GetOffsetNod(NodPtrs::g_TmpSpaceAsNod, 0);
}

uint64 Dev_GetPointerForNod(CMwNod@ nod) {
    if (NodPtrs::g_TmpPtrSpace == 0) {
        NodPtrs::InitializeTmpPointer();
    }
    if (nod is null) return 0;
    Dev::SetOffset(NodPtrs::g_TmpSpaceAsNod, 0, nod);
    return Dev::GetOffsetUint64(NodPtrs::g_TmpSpaceAsNod, 0);
}

CMwNod@ Dev_GetNodFromPointer(uint64 ptr) {
    if (ptr < 0xFFFFFFFF || ptr % 8 != 0 || ptr >> 48 > 0) {
        return null;
    }
    return Dev_GetArbitraryNodAt(ptr);
}