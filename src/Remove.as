// c 2024-03-19
// m 2024-03-21

bool removing     = false;
bool stopRemoving = false;

void RemoveCheckpointBlocks() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing checkpoint blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't remove checkpoint blocks - Editor is null");
        removing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't remove checkpoint blocks - PMT is null");
        removing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksCpRing.Length; i++) {
        YieldIfNeeded();

        trace("removing ring checkpoint (" + (i + 1) + " / " + mapBlocksCpRing.Length + ")");

        Block@ block = mapBlocksCpRing[i];

        if (block.block is null || block.block.BlockModel is null) {
            warn("can't remove ring checkpoint - something is null");
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
    trace("removed " + total + " checkpoint block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    removing = false;
}

void RemoveFinishBlocks() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing finish blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null) {
        warn("can't remove finish blocks - Editor is null");
        removing = false;
        return;
    }

    CSmEditorPluginMapType@ PMT = cast<CSmEditorPluginMapType@>(Editor.PluginMapType);
    if (PMT is null) {
        warn("can't remove finish blocks - PMT is null");
        removing = false;
        return;
    }

    uint total = 0;

    LoadMapBlocks();

    for (uint i = 0; i < mapBlocksFinRingGate.Length; i++) {
        YieldIfNeeded();

        trace("removing ring checkpoint (" + (i + 1) + " / " + mapBlocksFinRingGate.Length + ")");

        Block@ block = mapBlocksFinRingGate[i];

        if (block.block is null || block.block.BlockModel is null) {
            warn("can't remove ring finish - something is null");
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
    trace("removed " + total + " finish block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    if (total > 0)
        PMT.AutoSave();  // usually doesn't save but at least fixes undo

    removing = false;
}

void RemoveCheckpointItems() {
    print("removing checkpoint items");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    uint total = 0;

    LoadMapItems();

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    CGameCtnAnchoredObject@[] itemsToKeep;

    for (int i = mapItems.Length - 1; i >= 0; i--) {
        Item@ item = mapItems[i];

        if (item.waypointType != CGameItemModel::EnumWaypointType::Checkpoint)
            itemsToKeep.InsertLast(item.item);
        else
            total++;
    }

    const uint16 offsetAnchored = GetMemberOffset(Map, "AnchoredObjects");

    CMwNod@ bufPtr = Dev::GetOffsetNod(Map, offsetAnchored);

    for (uint i = 0; i < itemsToKeep.Length; i++)
        Dev::SetOffset(bufPtr, 0x8 * i, itemsToKeep[i]);

    Dev::SetOffset(Map, offsetAnchored + 0x8, itemsToKeep.Length);
    SaveAndReloadMap();

    print("removed " + total + " checkpoint items");
}

void RemoveFinishItems() {
    print("removing finish items");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    CGameEditorPluginMapMapType@ PMT = Editor.PluginMapType;
    if (PMT is null)
        return;

    uint total = 0;

    LoadMapItems();

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    CGameCtnAnchoredObject@[] itemsToKeep;

    for (int i = mapItems.Length - 1; i >= 0; i--) {
        Item@ item = mapItems[i];

        if (item.waypointType != CGameItemModel::EnumWaypointType::Finish)
            itemsToKeep.InsertLast(item.item);
        else
            total++;
    }

    const uint16 offsetAnchored = GetMemberOffset(Map, "AnchoredObjects");

    CMwNod@ bufPtr = Dev::GetOffsetNod(Map, offsetAnchored);

    for (uint i = 0; i < itemsToKeep.Length; i++)
        Dev::SetOffset(bufPtr, 0x8 * i, itemsToKeep[i]);

    Dev::SetOffset(Map, offsetAnchored + 0x8, itemsToKeep.Length);
    SaveAndReloadMap();

    print("removed " + total + " finish items");
}

void SaveAndReloadMap() {
    print("save and reload map");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);

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