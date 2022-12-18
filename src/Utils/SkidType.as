class SkidType
{
    string name;
    string path;
    string sha;
    string fileType;
    string url;

    array<Skid@> skids;

    SkidType(Json::Value data)
    {
        try {
            string dataType = data["type"];
            if (dataType == 'dir')
            {
                name = data["name"];
                path = data["path"];
                sha = data["sha"];
                fileType = data["type"];
                url = data["url"];
            }
            else
            {
                // send error
                error("Skid type is not a directory - " + dataType);
                vec4 color = UI::HSV(1.0, 1.0, 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skid type is invalid", color, 8000);
            }
        } catch {
            error("Failed to load skid type");
            vec4 color = UI::HSV(1.0, 1.0, 1.0);
            UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Failed to load skid type", color, 8000);
        }
    }

    Json::Value ToJson()
    {
        Json::Value json = Json::Object();
        try {
            json["name"] = name;
            json["path"] = path;
            json["sha"] = sha;
            json["type"] = fileType;
            json["url"] = url;
            json["skids"] = Json::Array();
            for (uint i = 0; i < skids.Length; i++)
            {
                json["skids"].Add(skids[i].ToJson());
            }
        } catch {
            error("Failed to convert SkidType to Json");
        }
        return json;
    }

    void LoadSkids()
    {
        string url = "https://api.github.com/repos/"+SKIDS_GITHUB_REPO+"/contents/"+path+"?ref="+SKIDS_MASTER_BRANCH_NAME;
        Json::Value json = API::GetAsync(url);
        if (json.GetType() != Json::Type::Array)
        {
            if (json.GetType() == Json::Type::Object && json.HasKey("message"))
            {
                string message = json["message"];
                if (message.Contains("API rate limit"))
                {
                    error("Rate limited");
                    vec4 color = UI::HSV(1.0, 1.0, 1.0);
                    UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "You got rate limited, try again later", color, 8000);
                    return;
                }
                else
                {
                    error("Error: " + message);
                    vec4 color = UI::HSV(1.0, 1.0, 1.0);
                    UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Error: " + message, color, 8000);
                    return;
                }
            }
            error("Skids list is not an array - " + tostring(json.GetType()));
            vec4 color = UI::HSV(1.0, 1.0, 1.0);
            UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skids list is invalid", color, 8000);
            return;
        }
        for (uint i = 0; i < json.Length; i++)
        {
            Json::Value skidJson = json[i];
            if (skidJson.GetType() != Json::Type::Object)
            {
                error("Skid is not an object - " + tostring(skidJson.GetType()));
                vec4 color = UI::HSV(1.0, 1.0, 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skid is invalid", color, 8000);
                continue;
            }

            string path = skidJson["path"];
            if (IS_DEV_MODE) trace("Loading skid: " + path);

            Skid@ skid = Skid(skidJson);
            skids.InsertLast(skid);
        }
        print("Loaded " + skids.Length + " skids for " + name + " type");
        SkidTypeTab@ tab = SkidTypeTab(this);
        if(skids.Length > 0)
        {
            Skid@ defaultSkid = skids[0];
            if(g_config.data.HasKey(name))
            {
                string skidName = g_config.data[name];
                for(uint i = 0; i < skids.Length; i++)
                {
                    if(skidName == skids[i].name){
                        trace("Found default: " + skidName);
                        Skid@ defaultSkid = skids[i];
                        tab.SetDefaultSkid(defaultSkid);
                    }
                }
            }
            else tab.SetDefaultSkid(defaultSkid);
        }
        if(g_config.data.HasKey("dirtDisableSmoke"))
            tab.dirtSkidDisableSmoke = g_config.data["dirtDisableSmoke"];
        
        g_window.AddTab(tab, false, true);
    }
}