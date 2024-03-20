// c 2024-03-19
// m 2024-03-19

CGameCtnArticle@[] catalogfiltered;
dictionary@        catalogObjects        = dictionary();
string             catalogSearch;
bool               loadingCatalogObjects = false;
const uint         objectsChapterIndex   = 3;

CGameCtnArticle@ GetCatalogObject(const string &in key) {
    if (!catalogObjects.Exists(key))
        return null;

    return cast<CGameCtnArticle@>(catalogObjects[key]);
}

CGameCtnArticle@ GetCatalogObject(const dictionaryValue@ &in key) {
    return GetCatalogObject(string(key));
}

void LoadCatalogObjects() {
    if (loadingCatalogObjects)
        return;

    loadingCatalogObjects = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    for (uint i = 0; i < App.GlobalCatalog.Chapters[objectsChapterIndex].Articles.Length; i++) {
        const uint64 now = Time::Now;

        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        CGameCtnArticle@ Article = App.GlobalCatalog.Chapters[objectsChapterIndex].Articles[i];

        if (Article.IdentAuthor.Value == nadeoAuthorId)
            catalogObjects[Article.Name] = @Article;
    }

    FilterCatalog();

    loadingCatalogObjects = false;
}

void Tab_CatalogObjects() {
    if (!UI::BeginTabItem("Catalog Objects"))
        return;

    UI::BeginDisabled(loadingCatalogObjects);
    if (UI::Button("Load Catalog Objects"))
        startnew(LoadCatalogObjects);
    UI::EndDisabled();

    UI::SameLine();
    UI::Text("Loaded Objects: " + catalogObjects.GetSize());

    catalogSearch = UI::InputText("###search-catalog", catalogSearch);

    UI::BeginDisabled(catalogSearch.Length == 0);
        UI::SameLine();
        if (UI::Button("search"))
            startnew(FilterCatalog);

        UI::SameLine();
        if (UI::Button("clear")) {
            catalogSearch = "";
            startnew(FilterCatalog);
        }
    UI::EndDisabled();

    if (catalogSearch.Length > 0) {
        UI::SameLine();
        UI::Text("results: " + catalogfiltered.Length);
    }

    if (UI::BeginTable("##table-catalog", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("id");
        UI::TableSetupColumn("id value", UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableSetupColumn("author",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("wp type",  UI::TableColumnFlags::WidthFixed, scale * 90.0f);
        UI::TableHeadersRow();

        UI::ListClipper clipper(catalogfiltered.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                CGameCtnArticle@ article = catalogfiltered[i];

                UI::TableNextRow();

                UI::TableNextColumn();
                if (UI::Selectable(article.Id.GetName(), false, UI::SelectableFlags::SpanAllColumns))
                    ExploreNod(article.Id.GetName(), article);

                UI::TableNextColumn();
                UI::Text(IntToHex(article.Id.Value));

                UI::TableNextColumn();
                UI::Text(article.IdentAuthor.GetName());

                CGameCtnBlockInfo@ blockInfo = cast<CGameCtnBlockInfo@>(article.LoadedNod);
                if (blockInfo !is null) {
                    UI::TableNextColumn();
                    UI::Text(tostring(blockInfo.EdWaypointType));
                }
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

void FilterCatalog() {
    catalogfiltered = {};

    string[]@ keys = catalogObjects.GetKeys();

    for (uint i = 0; i < keys.Length; i++) {
        const uint64 now = Time::Now;

        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        CGameCtnArticle@ article = cast<CGameCtnArticle@>(catalogObjects[keys[i]]);

        if (catalogSearch.Length == 0 || string(article.Name).ToLower().Contains(catalogSearch.ToLower()))
            catalogfiltered.InsertLast(article);
    }
}