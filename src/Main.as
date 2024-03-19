// c 2024-03-18
// m 2024-03-19

uint64       lastYield     = 0;
const uint   maxFrameTime  = 20;
const uint   nadeoAuthorId = 0x40000E5A;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const float  scale         = UI::GetScale();
const string title         = "\\$FFF" + Icons::Exchange + "\\$G Block Swapper";

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
            Tab_CatalogObjects();
            Tab_MapBlocks();
            Tab_MapItems();
        UI::EndTabBar();
    }

    UI::End();
}

// void ReplaceCps() {
//     print("replacing CPs");

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     if (Editor is null)
//         return;

//     CGameCtnChallenge@ Map = Editor.Challenge;
//     if (Map is null)
//         return;

//     CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
//     if (PMT is null)
//         return;

//     uint total = 0;

//     for (int i = Map.Blocks.Length - 1; i >= 0; i--) {
//         CGameCtnBlock@ block = Map.Blocks[i];

//         if (cpReplaceLut.Exists(IntToHex(block.DescId.Value))) {
//             CGameCtnBlockInfo@ replacement = cast<CGameCtnBlockInfo@>(cpReplaceLut[IntToHex(block.DescId.Value)]);

//             PMT.RemoveBlockSafe(block.BlockModel, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));

//             if (block.IsGhostBlock())
//                 PMT.PlaceGhostBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));
//             else
//                 PMT.PlaceBlock(replacement, Nat3ToInt3(block.Coord), CGameEditorPluginMap::ECardinalDirections(block.BlockDir));

//             total++;
//         } else
//             warn("id " + IntToHex(block.DescId.Value) + " not found in LUT");
//     }

//     print("replaced " + total + " blocks");
// }

// void RemoveCps() {
//     print("removing CPs");

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     if (Editor is null)
//         return;

//     CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
//     if (PMT is null)
//         return;

//     uint total = 0;

//     // CGameCtnChallenge@ Map = App.RootMap;
//     CGameCtnChallenge@ Map = Editor.Challenge;
//     if (Map is null)
//         return;

//     for (uint i = 0; i < blocks.Length; i++) {
//         Block@ block = blocks[i];

//         if (block.block is null)
//             continue;

//         if (block.id.Value == 0x4000488C) {  // ring CP
//             PMT.RemoveBlockSafe(block.block.BlockModel, int3(block.location.x, block.location.y, block.location.z), CGameEditorPluginMap::ECardinalDirections(block.direction));
//             total++;
//         }
//     }

//     print("removed " + total + " blocks");

//     CGameCtnAnchoredObject@[] itemsToKeep;

//     for (int i = Map.AnchoredObjects.Length - 1; i >= 0; i--) {
//         CGameCtnAnchoredObject@ item = Map.AnchoredObjects[i];

//         if (item.ItemModel.WaypointType != CGameItemModel::EnumWaypointType::Checkpoint)
//             itemsToKeep.InsertLast(item);
//     }

//     CMwNod@ bufPtr = Dev::GetOffsetNod(Map, GetMemberOffset(Map, "AnchoredObjects"));

//     for (uint i = 0; i < itemsToKeep.Length; i++)
//         Dev::SetOffset(bufPtr, 0x8 * i, itemsToKeep[i]);

//     Dev::SetOffset(Map, GetMemberOffset(Map, "AnchoredObjects") + 0x8, itemsToKeep.Length);
//     SaveAndReloadMap();
// }

// void SaveAndReloadMap() {
//     print('save and reload map');

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());
//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);

//     if (!SaveMapSameName(Editor)) {
//         warn("Map must be saved, first. Please save and reload manually!");
//         return;
//     }

//     string fileName = Editor.Challenge.MapInfo.FileName;
//     while (!Editor.PluginMapType.IsEditorReadyForRequest)
//         yield();

//     App.BackToMainMenu();
//     print('back to menu');
//     AwaitReturnToMenu();
//     App.ManiaTitleControlScriptAPI.EditMap(fileName, "", "");
//     AwaitEditor();
//     startnew(_RestoreMapName);
// }

// bool SaveMapSameName(CGameCtnEditorFree@ Editor) {
//     string fileName = Editor.Challenge.MapInfo.FileName;
//     _restoreMapName = Editor.Challenge.MapName;
//     if (fileName.Length == 0) {
//         warn("Map must be saved, first.");
//         return false;
//     }
//     Editor.PluginMapType.SaveMap(fileName);
//     startnew(_RestoreMapName);
//     print('saved map');
//     return true;
// }

// string _restoreMapName;
// // set after calling SaveMapSameName
// void _RestoreMapName() {
//     yield();

//     if (_restoreMapName.Length == 0)
//         return;

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     Editor.Challenge.MapName = _restoreMapName;
//     print('restored map name: ' + _restoreMapName);
// }