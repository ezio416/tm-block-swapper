// c 2024-03-19
// m 2024-03-20

class Item {
    CGameCtnAnchoredObject@ item;

    vec3                                  absPosition;
    MwId                                  author;
    CGameCtnAnchoredObject::EMapElemColor color;
    int3                                  coord;
    bool                                  flying;
    MwId                                  id;
    vec3                                  rotationDeg;
    vec3                                  rotationRad;
    CGameItemModel::EnumWaypointType      waypointType;

    Item() { }
    Item(CGameCtnAnchoredObject@ item) {
        @this.item = item;

        absPosition = item.AbsolutePositionInMap;
        color       = item.MapElemColor;
        coord       = Nat3ToInt3(item.BlockUnitCoord);
        flying      = item.IsFlying;
        rotationRad = vec3(item.Yaw, item.Pitch, item.Roll);
        rotationDeg = Vec3RadToDeg(rotationRad);

        if (item.ItemModel !is null) {
            author       = item.ItemModel.Author;
            id           = item.ItemModel.Id;
            waypointType = item.ItemModel.WaypointType;
        }
    }

    const string get_name() {
        return id.GetName();
    }
}