// c 2024-03-19
// m 2024-03-20

bool removing     = false;
bool stopRemoving = false;

void RemoveCpBlocks() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing CP blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't remove CP blocks - Editor is null");
        removing = false;
        return;
    }

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null) {
        warn("can't remove CP blocks - Map is null");
        removing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't remove CP blocks - PMT is null");
        removing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksCpRing.Length; i++) {
        YieldIfNeeded();

        trace("removing ring CP (" + (i + 1) + " / " + mapBlocksCpRing.Length + ")");

        Block@ block = mapBlocksCpRing[i];

        if (block.block is null || block.block.BlockModel is null) {
            warn("can't remove ring CP - something is null");
            continue;
        }

        if (block.ghost) {
            if (!PMT.RemoveGhostBlock(block.block.BlockModel, block.coord, CGameEditorPluginMap::ECardinalDirections(block.direction))) {
                warn("failed to remove ghost block at " + tostring(block.coord));
                continue;
            }
        } else {
            if (!PMT.RemoveBlockSafe(block.block.BlockModel, block.coord, CGameEditorPluginMap::ECardinalDirections(block.direction))) {
                warn("failed to remove block at " + tostring(block.coord));
                continue;
            }
        }

        total++;
    }

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " CP block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    removing = false;
}

// void RemoveCpItems() {
//     print("removing CP items");

//     CTrackMania@ App = cast<CTrackMania@>(GetApp());

//     CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
//     if (Editor is null)
//         return;

//     CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
//     if (PMT is null)
//         return;

//     uint total = 0;

//     LoadMapItems();

//     CGameCtnChallenge@ Map = Editor.Challenge;
//     if (Map is null)
//         return;

//     for (uint i = 0; i < mapItems.Length; i++) {
//         Item@ item = mapItems[i];

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