// c 2024-03-19
// m 2024-04-05

bool removing = false;

void RemoveCheckpointBlocks() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing checkpoint blocks");

    LoadMapBlocks();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove checkpoint blocks - editor is null");
        removing = false;
        return;
    }

    CGameCtnBlock@[] freeBlocks;
    CGameCtnBlock@[] blocks;

    for (uint i = 0; i < mapBlocksCpRing.Length; i++) {
        Block@ block = mapBlocksCpRing[i];

        if (block.free)
            freeBlocks.InsertLast(block.block);
        else
            blocks.InsertLast(block.block);
    }

    const uint deletedFree = Editor::DeleteFreeblocks(freeBlocks);
    const bool deleted = Editor::DeleteBlocks(blocks, true);

    const uint total = deletedFree + (deleted ? blocks.Length : 0);

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + mapBlocksCpRing.Length + " checkpoint block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapBlocks();
}

void RemoveFinishBlocks() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing finish blocks");

    LoadMapBlocks();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove finish blocks - editor is null");
        removing = false;
        return;
    }

    CGameCtnBlock@[] freeBlocks;
    CGameCtnBlock@[] blocks;

    for (uint i = 0; i < mapBlocksFinRingGate.Length; i++) {
        Block@ block = mapBlocksFinRingGate[i];

        if (block.free)
            freeBlocks.InsertLast(block.block);
        else
            blocks.InsertLast(block.block);
    }

    const uint deletedFree = Editor::DeleteFreeblocks(freeBlocks);
    const bool deleted = Editor::DeleteBlocks(blocks, true);

    const uint total = deletedFree + (deleted ? blocks.Length : 0);

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + mapBlocksFinRingGate.Length + " finish block" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapBlocks();
}

void RemoveCheckpointItems() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing checkpoint items");

    LoadMapItems();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove checkpoint items - editor is null");
        removing = false;
        return;
    }

    CGameCtnAnchoredObject@[] items;

    for (uint i = 0; i < mapItems.Length; i++) {
        Item@ item = mapItems[i];

        if (item.waypointType == CGameItemModel::EnumWaypointType::Checkpoint)
            items.InsertLast(item.item);
    }

    const bool deleted = Editor::DeleteItems(items, true);

    const uint total = deleted ? items.Length : 0;

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + items.Length + " checkpoint item" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapItems();
}

void RemoveFinishItems() {
    if (removing)
        return;

    removing = true;

    const uint64 start = Time::Now;
    trace("removing finish items");

    LoadMapItems();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (cast<CGameCtnEditorFree@>(App.Editor) is null) {
        warn("can't remove finish items - editor is null");
        removing = false;
        return;
    }

    CGameCtnAnchoredObject@[] items;

    for (uint i = 0; i < mapItems.Length; i++) {
        Item@ item = mapItems[i];

        if (item.waypointType == CGameItemModel::EnumWaypointType::Finish)
            items.InsertLast(item.item);
    }

    const bool deleted = Editor::DeleteItems(items, true);

    const uint total = deleted ? items.Length : 0;

    const uint64 dif = Time::Now - start;
    trace("removed " + total + " / " + items.Length + " finish item" + (total == 1 ? "" : "s") + " after " + dif + "ms (" + Time::Format(dif) + ")");

    removing = false;

    LoadMapItems();
}
