// c 2024-03-19
// m 2024-03-19

bool        loadingCatalogBlocks = false;
const uint  nadeoAuthorId        = 0x40000E5A;
dictionary@ nadeoBlocks          = dictionary();
const uint  objectsChapterIndex  = 3;

void LoadCatalogBlocks() {
    if (loadingCatalogBlocks)
        return;

    loadingCatalogBlocks = true;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    const uint64 now = Time::Now;

    for (uint i = 0; i < App.GlobalCatalog.Chapters[objectsChapterIndex].Articles.Length; i++) {
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        CGameCtnArticle@ Article = App.GlobalCatalog.Chapters[objectsChapterIndex].Articles[i];

        if (Article.LoadedNod !is null && Article.IdentAuthor.Value == nadeoAuthorId)
            nadeoBlocks[IntToHex(Article.Id.Value)] = @Article;
    }

    loadingCatalogBlocks = false;
}