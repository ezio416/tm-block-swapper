bool    loadingMapItems = false;
Item@[] mapItems;

void ClearMapItems() {
    if (mapItems.Length == 0)
        return;

    mapItems = {};
}

void LoadMapItems() {
    if (loadingMapItems)
        return;

    loadingMapItems = true;

    const uint64 start = Time::Now;
    trace("loading map items");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree>(App.Editor);
    if (Editor is null) {
        loadingMapItems = false;
        return;
    }

    CGameCtnChallenge@ Map = Editor.Challenge;
    if (Map is null) {
        loadingMapItems = false;
        return;
    }

    ClearMapItems();

    for (uint i = 0; i < Map.AnchoredObjects.Length; i++) {
        YieldIfNeeded();

        mapItems.InsertLast(Item(Map.AnchoredObjects[i]));
    }

    trace("loaded " + mapItems.Length + " item" + (mapItems.Length == 1 ? "" : "s") + " after " + (Time::Now - start) + "ms (" + Time::Format(Time::Now - start) + ")");

    loadingMapItems = false;
}

void MakeAllItemsFlying() {
    trace("making items flying");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CGameCtnEditorFree@ Editor = cast<CGameCtnEditorFree@>(App.Editor);
    if (Editor is null || Editor.Challenge is null)
        return;

    uint total = 0;

    for (uint i = 0; i < Editor.Challenge.AnchoredObjects.Length; i++) {
        YieldIfNeeded();

        if (!Editor.Challenge.AnchoredObjects[i].IsFlying) {
            Editor.Challenge.AnchoredObjects[i].IsFlying = true;
            total++;
        }
    }

    trace("made " + total + " items flying");
}

void Tab_MapItems() {
    if (!UI::BeginTabItem("Map Items"))
        return;

    const float scale = UI::GetScale();

    UI::BeginDisabled(loadingMapItems);
    if (UI::Button("Load Map Items"))
        startnew(LoadMapItems);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("Loaded Items: " + mapItems.Length);

    if (UI::BeginTable("##table-map-items", 10, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("id");
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("color",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("coord",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("flying",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("absPos",   UI::TableColumnFlags::WidthFixed, scale * 170.0f);
        UI::TableSetupColumn("rotRad",   UI::TableColumnFlags::WidthFixed, scale * 130.0f);
        UI::TableSetupColumn("rotDeg",   UI::TableColumnFlags::WidthFixed, scale * 160.0f);
        UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapItems.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Item@ item = mapItems[i];

                UI::TableNextRow();

                const string name = item.name;

                UI::TableNextColumn();
                UI::BeginDisabled(item.item is null);
                if (UI::Selectable(name + "##" + i, false))
                    SetClipboard(name);
                if (UI::IsItemHovered()) {
                    UI::BeginTooltip();
                        UI::Text("right-click to explore nod");
                    UI::EndTooltip();
                    if (UI::IsMouseClicked(UI::MouseButton::Right))
                        ExploreNod(name, item.item);
                }
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::Text(IntToHex(item.id.Value));

                UI::TableNextColumn();
                UI::Text(item.author.GetName());

                UI::TableNextColumn();
                UI::Text(tostring(item.color));

                UI::TableNextColumn();
                UI::Text(Round(item.coord));

                UI::TableNextColumn();
                UI::Text(Round(item.flying));

                UI::TableNextColumn();
                UI::Text(Round(item.absPosition));

                UI::TableNextColumn();
                UI::Text(Round(item.rotationRad));

                UI::TableNextColumn();
                UI::Text(Round(item.rotationDeg));

                UI::TableNextColumn();
                UI::Text(tostring(item.waypointType));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}