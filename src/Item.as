// c 2024-03-19
// m 2024-03-19

class Item {
    CGameCtnAnchoredObject@ item;

    vec3                                  absPosition;
    MwId                                  author;
    CGameCtnAnchoredObject::EMapElemColor color;
    int3                                  coord;
    MwId                                  id;
    vec3                                  orientation;
    CGameItemModel::EnumWaypointType      waypointType;

    Item() { }
    Item(CGameCtnAnchoredObject@ item) {
        @this.item = item;

        absPosition = item.AbsolutePositionInMap;
        color       = item.MapElemColor;
        coord       = Nat3ToInt3(item.BlockUnitCoord);
        orientation = vec3(item.Yaw, item.Pitch, item.Roll);

        if (item.ItemModel !is null) {
            author       = item.ItemModel.Author;
            id           = item.ItemModel.Id;
            waypointType = item.ItemModel.WaypointType;
        }
    }
}