// c 2024-03-18
// m 2024-03-20

class Block {
    MwId                               author;
    CGameCtnBlock@                     block;
    CGameCtnBlock::EMapElemColor       color;
    int3                               coord;
    CGameCtnBlock::ECardinalDirections direction;
    bool                               free;
    vec3                               freePosition;
    vec3                               freeRotationDeg;
    vec3                               freeRotationRad;
    bool                               ghost;
    bool                               ground;
    MwId                               id;
    uint                               variant;
    CGameCtnBlockInfo::EWayPointType   waypointType;

    Block() { }
    Block(CGameCtnBlock@ block) {
        @this.block = block;

        author    = block.DescAuthor;
        color     = block.MapElemColor;
        coord     = Nat3ToInt3(block.Coord);
        direction = block.BlockDir;
        free      = int(block.CoordX) < 0;
        ghost     = block.IsGhostBlock();
        ground    = block.IsGround;
        id        = block.DescId;
        variant   = block.BlockInfoVariantIndex;

        if (block.BlockInfo !is null)
            waypointType = block.BlockInfo.EdWaypointType;

        if (free) {
            freePosition = GetFreeBlockPosition(block);
            freeRotationRad = GetFreeBlockRotation(block);
            freeRotationDeg = Vec3RadToDeg(freeRotationRad);
        }
    }

    const string get_name() {
        return id.GetName();
    }
}