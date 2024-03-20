// c 2024-03-18
// m 2024-03-19

uint64       lastYield      = 0;
const uint   maxFrameTime   = 20;
const uint   nadeoAuthorId  = 0x40000E5A;
const vec4   rowBgAltColor  = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale          = UI::GetScale();
const uint   stadiumGrassId = 0x4000214A;
const string title          = "\\$FFF" + Icons::Exchange + "\\$G Block Swapper";

void OnDestroyed() { FreeAllAllocated(); }
void OnDisabled()  { FreeAllAllocated(); }

void Main() {
    InitCpLut();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null) {
        ClearMapBlocks();
        ClearMapItems();
        return;
    }

    CGameCtnChallenge@ Map = App.RootMap;
    if (Map is null) {
        ClearMapBlocks();
        ClearMapItems();
        return;
    }

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        UI::BeginTabBar("##tabs");
            Tab_Main();
            Tab_Custom();
            Tab_CatalogObjects();
            Tab_MapBlocks();
            Tab_Offsets();
            Tab_MapItems();
        UI::EndTabBar();
    }

    UI::End();
}

void Tab_Main() {
    if (!UI::BeginTabItem("Main"))
        return;

    if (UI::Button("Replace CPs"))
        startnew(ReplaceCPs);

    UI::EndTabItem();
}

string blockName;
CGameCtnBlockInfo@ selectedBlock;
uint8 x;
uint8 y;
uint8 z;
CGameEditorPluginMap::ECardinalDirections dir;
bool ghost;

void Tab_Custom() {
    if (!UI::BeginTabItem("Custom"))
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    blockName = UI::InputText("block name", blockName);

    if (UI::Button("get block"))
        @selectedBlock = PMT.GetBlockModelFromName(blockName);

    UI::SameLine();
    UI::Text("block: " + (selectedBlock is null ? "null" : string(selectedBlock.Name)));

    if (selectedBlock !is null) {
        x = UI::InputInt("X", x);
        y = UI::InputInt("Y", y);
        z = UI::InputInt("Z", z);

        if (UI::BeginCombo("direction", tostring(dir))) {
            if (UI::Selectable("North", dir == CGameEditorPluginMap::ECardinalDirections::North))
                dir = CGameEditorPluginMap::ECardinalDirections::North;
            if (UI::Selectable("East", dir == CGameEditorPluginMap::ECardinalDirections::East))
                dir = CGameEditorPluginMap::ECardinalDirections::East;
            if (UI::Selectable("South", dir == CGameEditorPluginMap::ECardinalDirections::South))
                dir = CGameEditorPluginMap::ECardinalDirections::South;
            if (UI::Selectable("West", dir == CGameEditorPluginMap::ECardinalDirections::West))
                dir = CGameEditorPluginMap::ECardinalDirections::West;

            UI::EndCombo();
        }

        ghost = UI::Checkbox("ghost mode", ghost);

        if (UI::Button("place")) {
            if (ghost)
                PMT.PlaceGhostBlock(selectedBlock, int3(x, y, z), dir);
            else
                PMT.PlaceBlock(selectedBlock, int3(x, y, z), dir);
        }
    }

    UI::EndTabItem();
}