class Config
{
    Json::Value data = Json::Object();

    Config() {
        Load();
    }

    void Load()
    {
        if(IO::FileExists(SKIDS_CONFIG)) {
            data = Json::FromFile(SKIDS_CONFIG);
            trace("Loaded skid config.");
        } else trace("Could not locate a skid config.");
    }

    void Save() {
        Json::ToFile(SKIDS_CONFIG, data);
        trace("Saved skid config.");
    }

}