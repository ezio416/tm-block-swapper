// c 2024-03-18
// m 2024-03-19

Block@[]     blocks;
bool         gettingBlocks = false;
uint64       lastYield     = 0;
const uint   maxFrameTime  = 20;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale         = UI::GetScale();
const string title         = "\\$FFF" + Icons::ArrowsH + "\\$G Block Swapper";

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
        ClearBlocks();
        return;
    }

    CGameCtnChallenge@ Map = App.RootMap;
    if (Map is null) {
        ClearBlocks();
        return;
    }

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        UI::BeginTabBar("##tabs");
            Tab_MapBlocks();
            Tab_NadeoBlocks();
        UI::EndTabBar();
    }

    UI::End();
}

void Tab_MapBlocks() {
    if (!UI::BeginTabItem("Map Blocks"))
        return;

    if (UI::Button("replace CPs"))
        ReplaceCps();

    // if (UI::Button("remove CPs"))
    //     startnew(RemoveCps);

    UI::BeginDisabled(gettingBlocks);
    UI::SameLine();
    if (UI::Button("get blocks"))
        startnew(GetBlocks);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("blocks/items: " + blocks.Length);

    if (UI::BeginTable("##table-map-blocks", 9, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        // UI::TableSetupColumn("del",      UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableSetupColumn("id");
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("color",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("dir",      UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("ghost",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("ground",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("loc",      UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(blocks.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Block@ block = blocks[i];

                UI::TableNextRow();

                // UI::TableNextColumn();
                // UI::BeginDisabled(block.removed);
                // if (UI::Button(Icons::TrashO + "##" + i))

                // UI::EndDisabled();

                UI::TableNextColumn();
                if (UI::Selectable(block.id.GetName() + "##" + i, false, UI::SelectableFlags::SpanAllColumns)) {
                    if (block.block !is null)
                        ExploreNod(block.block);
                    else if (block.item !is null)
                        ExploreNod(block.item);
                }

                UI::TableNextColumn();
                UI::Text(IntToHex(block.id.Value));

                UI::TableNextColumn();
                UI::Text(block.author.GetName());

                UI::TableNextColumn();
                UI::Text(tostring(block.color));

                UI::TableNextColumn();
                UI::Text(tostring(block.direction));

                UI::TableNextColumn();
                UI::Text(tostring(block.ghost));

                UI::TableNextColumn();
                UI::Text(tostring(block.ground));

                UI::TableNextColumn();
                UI::Text(tostring(block.location));

                UI::TableNextColumn();
                UI::Text(tostring(block.waypointType));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

string nadeoBlockSearch;
CGameCtnArticle@[] nadeoBlocksFiltered;

void SearchNadeoBlocks() {
    if (nadeoBlockSearch.Length == 0) {
        nadeoBlocksFiltered = nadeoBlocks;
        return;
    }

    nadeoBlocksFiltered = {};

    for (uint i = 0; i < nadeoBlocks.Length; i++) {
        if (nadeoBlocks[i].IdName.ToLower().Contains(nadeoBlockSearch.ToLower()))
            nadeoBlocksFiltered.InsertLast(nadeoBlocks[i]);
    }
}

void Tab_NadeoBlocks() {
    if (!UI::BeginTabItem("Nadeo Blocks"))
        return;

    UI::BeginDisabled(gettingBlocks);
    if (UI::Button("get blocks"))
        startnew(GetNadeoBlocks);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("blocks: " + nadeoBlocks.Length);

    UI::SameLine();
    UI::Text("LUT size: " + cpReplaceLut.GetSize());

    nadeoBlockSearch = UI::InputText("###search-nadeo-blocks", nadeoBlockSearch);

    UI::BeginDisabled(nadeoBlockSearch.Length == 0);
    UI::SameLine();
    if (UI::Button("search"))
        SearchNadeoBlocks();
    UI::EndDisabled();

    UI::BeginDisabled(nadeoBlockSearch.Length == 0);
    UI::SameLine();
    if (UI::Button("clear")) {
        nadeoBlockSearch = "";
        SearchNadeoBlocks();
    }
    UI::EndDisabled();

    if (nadeoBlockSearch.Length > 0) {
        UI::SameLine();
        UI::Text("results: " + nadeoBlocksFiltered.Length);
    }

    if (UI::BeginTable("##table-nadeo-blocks", 3, UI::TableFlags::Resizable | UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("nod type");
        // UI::TableSetupColumn("id")
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        // UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        // UI::TableSetupColumn("color",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        // UI::TableSetupColumn("dir",      UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        // UI::TableSetupColumn("ghost",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        // UI::TableSetupColumn("ground",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        // UI::TableSetupColumn("loc",      UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        // UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(nadeoBlocksFiltered.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                CGameCtnArticle@ article = nadeoBlocksFiltered[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                if (UI::Selectable(article.IdName, false))
                    ExploreNod(article);

                UI::TableNextColumn();
                if (article.LoadedNod !is null) {
                    const Reflection::MwClassInfo@ type = Reflection::TypeOf(article.LoadedNod);

                    if (type !is null) {
                        UI::Text(type.Name);
                    }
                }

                UI::TableNextColumn();
                UI::Text(IntToHex(article.Id.Value));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

void ReplaceCps() {
    print("replacing CPs");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    uint total = 0;

    for (int i = Map.Blocks.Length - 1; i >= 0; i--) {
        CGameCtnBlock@ block = Map.Blocks[i];

        if (cpReplaceLut.Exists(IntToHex(block.DescId.Value))) {
            CGameCtnBlockInfo@ replacement = cast<CGameCtnBlockInfo@>(cpReplaceLut[IntToHex(block.DescId.Value)]);

            PMT.RemoveBlockSafe(block.BlockModel, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));

            if (block.IsGhostBlock())
                PMT.PlaceGhostBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
            else
                PMT.PlaceBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));

            total++;
        } else
            warn("id " + IntToHex(block.DescId.Value) + " not found in LUT");
    }

    print("replaced " + total + " blocks");
}

void RemoveCps() {
    print("removing CPs");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    uint total = 0;

    // CGameCtnChallenge@ Map = App.RootMap;
    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    for (uint i = 0; i < blocks.Length; i++) {
        Block@ block = blocks[i];

        if (block.block is null)
            continue;

        if (block.id.Value == 0x4000488C) {  // ring CP
            PMT.RemoveBlockSafe(block.block.BlockModel, int3(block.location.x, block.location.y, block.location.z), CGameEditorPluginMap::ECardinalDirections(block.direction));
            total++;
        }
    }

    print("removed " + total + " blocks");

    CGameCtnAnchoredObject@[] itemsToKeep;

    for (int i = Map.AnchoredObjects.Length - 1; i >= 0; i--) {
        CGameCtnAnchoredObject@ item = Map.AnchoredObjects[i];

        if (item.ItemModel.WaypointType != CGameItemModel::EnumWaypointType::Checkpoint)
            itemsToKeep.InsertLast(item);
    }

    CMwNod@ bufPtr = Dev::GetOffsetNod(Map, GetMemberOffset(Map, "AnchoredObjects"));

    for (uint i = 0; i < itemsToKeep.Length; i++)
        Dev::SetOffset(bufPtr, 0x8 * i, itemsToKeep[i]);

    Dev::SetOffset(Map, GetMemberOffset(Map, "AnchoredObjects") + 0x8, itemsToKeep.Length);
    SaveAndReloadMap();
}

void SaveAndReloadMap() {
    print('save and reload map');

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);

    if (!SaveMapSameName(Editor)) {
        warn("Map must be saved, first. Please save and reload manually!");
        return;
    }

    string fileName = Editor.Challenge.MapInfo.FileName;
    while (!Editor.PluginMapType.IsEditorReadyForRequest)
        yield();

    App.BackToMainMenu();
    print('back to menu');
    AwaitReturnToMenu();
    App.ManiaTitleControlScriptAPI.EditMap(fileName, "", "");
    AwaitEditor();
    startnew(_RestoreMapName);
}

bool SaveMapSameName(CGameCtnEditorFree@ Editor) {
    string fileName = Editor.Challenge.MapInfo.FileName;
    _restoreMapName = Editor.Challenge.MapName;
    if (fileName.Length == 0) {
        warn("Map must be saved, first.");
        return false;
    }
    Editor.PluginMapType.SaveMap(fileName);
    startnew(_RestoreMapName);
    print('saved map');
    return true;
}

string _restoreMapName;
// set after calling SaveMapSameName
void _RestoreMapName() {
    yield();

    if (_restoreMapName.Length == 0)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    Editor.Challenge.MapName = _restoreMapName;
    print('restored map name: ' + _restoreMapName);
}

void AwaitReturnToMenu() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (App.Switcher.ModuleStack.Length == 0 || cast<CTrackManiaMenus@>(App.Switcher.ModuleStack[0]) is null)
        yield();

    while (!App.ManiaTitleControlScriptAPI.IsReady)
        yield();
}

void AwaitEditor() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (cast<CGameCtnEditorFree@>(App.Editor) is null)
        yield();

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    while (!Editor.PluginMapType.IsEditorReadyForRequest)
        yield();
}