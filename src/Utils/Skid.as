class Skid
{
    string name;
    string path;
    string sha;
    uint size;
    string fileType;
    string url;
    string downloadUrl;

    Skid(Json::Value data)
    {
        try {
            string dataType = data["type"];
            if (dataType == 'file')
            {
                name = data["name"];
                path = data["path"];
                sha = data["sha"];
                size = data["size"];
                fileType = data["type"];
                url = data["url"];
                if (data["download_url"].GetType() == Json::Type::String) downloadUrl = data["download_url"];
            }
            else
            {
                // send error
                error("Skid is not a file - " + dataType);
                vec4 color = UI::HSV(1.0, 1.0, 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skid is invalid", color, 8000);
            }
        } catch {
            error("Failed to load skid");
            vec4 color = UI::HSV(1.0, 1.0, 1.0);
            UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Failed to load skid", color, 8000);
        }
    }

    Json::Value ToJson()
    {
        Json::Value json = Json::Object();
        try {
            json["name"] = name;
            json["path"] = path;
            json["sha"] = sha;
            json["size"] = size;
            json["type"] = fileType;
            json["url"] = url;
            json["download_url"] = downloadUrl;
        } catch {
            error("Failed to convert Skid to Json");
        }
        return json;
    }
}