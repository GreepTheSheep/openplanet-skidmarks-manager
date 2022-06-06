class CachedImage
{
    string m_url;
    UI::Texture@ m_texture;

    void Converted()
    {
        // Api from http://rest7.com/image_convert
        string url = "http://api.rest7.com/v1/image_convert.php?url="+m_url+"&format=png";
        Json::Value res = API::GetAsync(url);
        if (res.GetType() != Json::Type::Object) {
            error("ImageConverted: Invalid JSON response");
        }
        int success = res["success"];
        if (success != 1) {
            string errorReason;
            if (res.HasKey("error")) {
                errorReason = res["error"];
            }
            error("ImageConverted: Invalid success value: " + errorReason);
        }
        if (!res.HasKey("file")) {
            error("ImageConverted: Invalid JSON response");
        } else m_url = res["file"];

        DownloadFromURLAsync();
    }

    void DownloadFromURLAsync()
    {
        auto req = API::Get(m_url);
        while (!req.Finished()) {
            yield();
        }
        @m_texture = UI::LoadTexture(req.Buffer());
        if (IS_DEV_MODE) trace("Loading texture: " + m_url);
        if (m_texture.GetSize().x == 0) {
            @m_texture = null;
        }
    }
}

namespace Images
{
    dictionary g_cachedImages;

    CachedImage@ FindExisting(const string &in url)
    {
        CachedImage@ ret = null;
        g_cachedImages.Get(url, @ret);
        return ret;
    }

    CachedImage@ CachedFromURL(const string &in url)
    {
        // Return existing image if it already exists
        auto existing = FindExisting(url);
        if (existing !is null) {
            return existing;
        }

        // Create a new cached image object and remember it for future reference
        auto ret = CachedImage();
        ret.m_url = url;
        g_cachedImages.Set(url, @ret);

        // if the image is a DDS file, we need to convert
        if (url.ToLower().EndsWith(".dds")) {
            startnew(CoroutineFunc(ret.Converted));
        } else {
            startnew(CoroutineFunc(ret.DownloadFromURLAsync));
        }
        return ret;
    }
}