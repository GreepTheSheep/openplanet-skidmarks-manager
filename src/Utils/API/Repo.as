class Repo
{

    array<SkidType@> skidTypes;

    Repo()
    {
        // load skids types from Github repo
        this.LoadSkidsTypes();
    }

    void LoadSkidsTypes()
    {
        string url = "https://api.github.com/repos/"+SKIDS_GITHUB_REPO+"/contents/"+SKIDS_GITHUB_LIST_PATH+"?ref="+SKIDS_MASTER_BRANCH_NAME;
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
            error("Skid types list is not an array - " + tostring(json.GetType()));
            vec4 color = UI::HSV(1.0, 1.0, 1.0);
            UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skid types list is invalid", color, 8000);
            return;
        }
        for (uint i = 0; i < json.Length; i++)
        {
            Json::Value typeJson = json[i];
            if (typeJson.GetType() != Json::Type::Object)
            {
                error("Skid type is not an object - " + tostring(typeJson.GetType()));
                vec4 color = UI::HSV(1.0, 1.0, 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + Meta::ExecutingPlugin().Name + " - Error", "Skid type is invalid", color, 8000);
                continue;
            }

            string path = typeJson["path"];
            trace("Loading skid type: " + path);

            SkidType@ type = SkidType(typeJson);
            skidTypes.InsertLast(type);
        }
        print("Loaded " + skidTypes.Length + " skid types");
        for (uint i = 0; i < skidTypes.Length; i++)
        {
            SkidType@ type = skidTypes[i];
            trace("Loading skids for type: " + type.name);
            type.LoadSkids();
        }
    }
}