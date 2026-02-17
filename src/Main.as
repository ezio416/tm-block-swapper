const uint   nadeoAuthorId  = 0x40000E5A;
const vec4   rowBgAltColor  = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale          = UI::GetScale();
const uint   stadiumGrassId = 0x4000214A;
const string title          = "\\$FFF" + Icons::Exchange + "\\$G Block Swapper";

void OnDestroyed() { FreeAllAllocated(); }
void OnDisabled()  { FreeAllAllocated(); }

void Main() {
    InitLUT();
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
        || LUT is null
        || LUT.GetType() != Json::Type::Object
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

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize)) {
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

    UI::BeginDisabled(replacing);
    if (UI::Button("Replace checkpoint blocks"))
        startnew(ReplaceCheckpointBlocks);
    UI::EndDisabled();

    UI::BeginDisabled(stopReplacing || !replacing);
    UI::SameLine();
    if (UI::Button("STOP REPLACING##cp"))
        stopReplacing = true;
    UI::EndDisabled();

    UI::BeginDisabled(removing);
    UI::SameLine();
    if (UI::Button("Remove checkpoint blocks (ring)"))
        startnew(RemoveCheckpointBlocks).WithRunContext(Meta::RunContext::MainLoop);
    UI::EndDisabled();

    UI::SameLine();
    if (UI::Button("Remove checkpoint items"))
        startnew(RemoveCheckpointItems);

    UI::BeginDisabled(replacing);
    if (UI::Button("Replace finish blocks"))
        startnew(ReplaceFinishBlocks);
    UI::EndDisabled();

    UI::BeginDisabled(stopReplacing || !replacing);
    UI::SameLine();
    if (UI::Button("STOP REPLACING##fin"))
        stopReplacing = true;
    UI::EndDisabled();

    UI::BeginDisabled(removing);
    UI::SameLine();
    if (UI::Button("Remove finish blocks (ring/expandable)"))
        startnew(RemoveFinishBlocks).WithRunContext(Meta::RunContext::MainLoop);
    UI::EndDisabled();

    UI::SameLine();
    if (UI::Button("Remove finish items"))
        startnew(RemoveFinishItems);

    UI::BeginDisabled(replacing);
    if (UI::Button("Replace multilap blocks"))
        startnew(ReplaceMultilapBlocks);
    UI::EndDisabled();

    UI::BeginDisabled(stopReplacing || !replacing);
    UI::SameLine();
    if (UI::Button("STOP REPLACING##multi"))
        stopReplacing = true;
    UI::EndDisabled();

    UI::BeginDisabled(replacing);
    if (UI::Button("Replace start blocks"))
        startnew(ReplaceStartBlocks);
    UI::EndDisabled();

    UI::BeginDisabled(stopReplacing || !replacing);
    UI::SameLine();
    if (UI::Button("STOP REPLACING##start"))
        stopReplacing = true;
    UI::EndDisabled();

    if (UI::Button("Make All Items Flying"))
        startnew(MakeAllItemsFlying);

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

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null)
        return;

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
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
            const int3 coord = int3(x, y, z);

            if (ghost) {
                if (!PMT.PlaceGhostBlock(selectedBlock, coord, dir))
                    warn("failed to place ghost block at " + tostring(coord));
            } else {
                if (!PMT.PlaceBlock(selectedBlock, int3(x, y, z), dir))
                    warn("failed to place block at " + tostring(coord));
            }
        }
    }

    UI::EndTabItem();
}
