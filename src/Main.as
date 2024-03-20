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