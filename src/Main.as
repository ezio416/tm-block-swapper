// c 2024-03-18
// m 2024-03-18

Block@[]     blocks;
bool         gettingBlocks = false;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale         = UI::GetScale();
const string title         = "\\$FFF" + Icons::Arrows + "\\$G CP Remover";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

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
        if (UI::Button("remove CPs"))
            startnew(RemoveCps);

        UI::BeginDisabled(gettingBlocks);
        UI::SameLine();
        if (UI::Button("get blocks"))
            startnew(GetBlocks);
        UI::EndDisabled();

        UI::SameLine();
        UI::Text("blocks/items: " + blocks.Length);

        if (UI::BeginTable("##table-blocks", 9, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
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
                    UI::Text(tostring(block.id.Value));

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
    }

    UI::End();
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

        if (block.id.Value == 1073760396) {
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

uint16 GetMemberOffset(CMwNod@ nod, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::TypeOf(nod);

    if (type is null)
        throw("Unable to find reflection info for nod");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + type.Name + "\"");

    return member.Offset;
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

bool SaveMapSameName(CGameCtnEditorFree@ editor) {
    string fileName = editor.Challenge.MapInfo.FileName;
    _restoreMapName = editor.Challenge.MapName;
    if (fileName.Length == 0) {
        warn("Map must be saved, first.");
        return false;
    }
    editor.PluginMapType.SaveMap(fileName);
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