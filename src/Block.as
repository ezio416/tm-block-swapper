// c 2024-03-18
// m 2024-03-18

const uint maxFrameTime   = 20;
uint64     lastYield      = 0;
const uint stadiumGrassId = 1073750346;

class Block {
    MwId                               author;
    CGameCtnBlock@                     block;
    CGameCtnBlock::EMapElemColor       color;
    CGameCtnBlock::ECardinalDirections direction;
    bool                               ghost;
    bool                               ground;
    MwId                               id;
    uint                               index;
    CGameCtnAnchoredObject@            item;
    vec3                               itemLocation;
    nat3                               location;
    vec3                               orientation;
    CGameCtnBlockInfo::EWayPointType   waypointType;

    Block() { }
    Block(CGameCtnBlock@ block) {
        @this.block = block;

        author       = block.DescAuthor;
        direction    = block.BlockDir;
        location     = block.Coord;
        color        = block.MapElemColor;
        ghost        = block.IsGhostBlock();
        ground       = block.IsGround;
        id           = block.DescId;
        waypointType = block.BlockInfo.EdWaypointType;
    }
    Block(CGameCtnAnchoredObject@ item) {
        @this.item = item;

        author       = item.ItemModel.Author;
        location     = item.BlockUnitCoord;
        color        = CGameCtnBlock::EMapElemColor(item.MapElemColor);
        id           = item.ItemModel.Id;
        itemLocation = item.AbsolutePositionInMap;
        orientation  = vec3(item.Yaw, item.Pitch, item.Roll);
        waypointType = CGameCtnBlockInfo::EWayPointType(item.ItemModel.WaypointType);
    }
}

void ClearBlocks() {
    blocks = {};
}

void GetBlocks() {
    if (gettingBlocks)
        return;

    gettingBlocks = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null)
        return;

    // CGameCtnChallenge@ Map = App.RootMap;
    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null)
        return;

    ClearBlocks();

    const uint64 now = Time::Now;

    for (uint i = 0; i < Map.Blocks.Length; i++) {
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        if (Map.Blocks[i].DescId.Value != stadiumGrassId && Map.Blocks[i].DescAuthor.GetName() == "Nadeo")
            blocks.InsertLast(Block(Map.Blocks[i]));
    }

    for (uint i = 0; i < Map.AnchoredObjects.Length; i++) {
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        if (Map.AnchoredObjects[i].ItemModel.Author.GetName() == "Nadeo")
        blocks.InsertLast(Block(Map.AnchoredObjects[i]));
    }

    gettingBlocks = false;
}