// c 2024-03-19
// m 2024-03-19

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

    const uint64 now = Time::Now;

    for (uint i = 0; i < Map.AnchoredObjects.Length; i++) {
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        mapItems.InsertLast(Item(Map.AnchoredObjects[i]));
    }

    loadingMapItems = false;
}

void Tab_MapItems() {
    if (!UI::BeginTabItem("Map Items"))
        return;

    UI::BeginDisabled(loadingMapItems);
    if (UI::Button("Load Map Items"))
        startnew(LoadMapItems);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("Loaded Items: " + mapItems.Length);

    if (UI::BeginTable("##table-map-items", 8, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("id");
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("color",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("coord",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
        UI::TableSetupColumn("absPos",   UI::TableColumnFlags::WidthFixed, scale * 100.0f);
        UI::TableSetupColumn("orient",   UI::TableColumnFlags::WidthFixed, scale * 100.0f);
        UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(mapItems.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Item@ item = mapItems[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::BeginDisabled(item.item is null);
                if (UI::Selectable(item.id.GetName(), false, UI::SelectableFlags::SpanAllColumns))
                    ExploreNod(item.item);
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::Text(IntToHex(item.id.Value));

                UI::TableNextColumn();
                UI::Text(item.author.GetName());

                UI::TableNextColumn();
                UI::Text(tostring(item.color));

                UI::TableNextColumn();
                UI::Text(tostring(item.coord));

                UI::TableNextColumn();
                UI::Text(tostring(item.absPosition));

                UI::TableNextColumn();
                UI::Text(tostring(item.orientation));

                UI::TableNextColumn();
                UI::Text(tostring(item.waypointType));
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}