// c 2024-03-19
// m 2024-04-05

bool removing = false;

void RemoveBlocks(Block@[] blocksArr, const string &in type) {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing " + type + " blocks");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove " + type + " blocks - editor is null");
        removing = false;
        return;
    }

    CGameCtnBlock@[] freeBlocks;
    CGameCtnBlock@[] blocks;

    for (uint i = 0; i < blocksArr.Length; i++) {
        Block@ block = blocksArr[i];

        if (block.free)
            freeBlocks.InsertLast(block.block);
        else
            blocks.InsertLast(block.block);
    }

    const uint deletedFree = Editor::DeleteFreeblocks(freeBlocks);
    const bool deleted = Editor::DeleteBlocks(blocks, true);

    const uint total = deletedFree + (deleted ? blocks.Length : 0);

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + blocksArr.Length + " " + type + " block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapBlocks();
}

void RemoveCheckpointBlocks() {
    LoadMapBlocks();
    RemoveBlocks(mapBlocksCpRing, "checkpoint");
}

void RemoveFinishBlocks() {
    LoadMapBlocks();
    RemoveBlocks(mapBlocksFinRingGate, "finish");
}

void RemoveWaypointItems(CGameItemModel::EnumWaypointType wpType) {
    if (removing)
        return;

    removing = true;

    const string type = tostring(wpType);

    const uint64 start = Time::Now;
    trace("removing " + type + " items");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove " + type + " items - editor is null");
        removing = false;
        return;
    }

    CGameCtnAnchoredObject@[] items;

    for (uint i = 0; i < mapItems.Length; i++) {
        Item@ item = mapItems[i];

        if (item.waypointType == wpType)
            items.InsertLast(item.item);
    }

    const bool deleted = Editor::DeleteItems(items, true);

    const uint total = deleted ? items.Length : 0;

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + items.Length + " " + type + " item" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapItems();
}

void RemoveCheckpointItems() {
    LoadMapItems();
    RemoveWaypointItems(CGameItemModel::EnumWaypointType::Checkpoint);
}

void RemoveFinishItems() {
    LoadMapItems();
    RemoveWaypointItems(CGameItemModel::EnumWaypointType::Finish);
}
