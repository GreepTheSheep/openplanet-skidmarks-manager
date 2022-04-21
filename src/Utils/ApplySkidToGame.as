class GameSkidApply
{
    Skid@ skid;
    SkidType@ type;
    SkidTypeTab@ tab;

    void Apply()
    {
        string modWorkDir = IO::FromUserGameFolder("Skins/Stadium/ModWork");
        if (!IO::FolderExists(modWorkDir)) IO::CreateFolder(modWorkDir);
        if (type.name != "Dirt") {
            string fxImageDir = IO::FromUserGameFolder("Skins/Stadium/ModWork/CarFxImage");
            if (!IO::FolderExists(fxImageDir)) IO::CreateFolder(fxImageDir);
            auto req = API::Get(skid.downloadUrl);
            while (!req.Finished()) {
                yield();
            }
            req.SaveToFile(fxImageDir + "/Car"+type.name+"Marks.dds");
        } else {
            auto req = API::Get(skid.downloadUrl);
            while (!req.Finished()) {
                yield();
            }
            req.SaveToFile(modWorkDir + "/DirtMarks.dds");
            if (tab.dirtSkidDisableSmoke) {
                auto reqSmoke = API::Get("https://raw.githubusercontent.com/"+SKIDS_GITHUB_REPO+"/master/"+SKIDS_GITHUB_LIST_PATH+"/Dirt/DirtSmoke.dds");
                while (!reqSmoke.Finished()) {
                    yield();
                }
                reqSmoke.SaveToFile(modWorkDir + "/DirtSmoke.dds");
            }
        }
        tab.isSkidApplied = true;
        tab.isSkidInProgress = false;
    }
}

namespace Skids
{
    void ApplyToGame(SkidType@ type, Skid@ skid, SkidTypeTab@ tab)
    {
        print("Applying skid " + skid.name + " to " + type.name);
        tab.isSkidApplied = false;
        tab.isSkidDeleted = false;
        tab.isSkidInProgress = true;
        GameSkidApply@ apply = GameSkidApply();
        @apply.skid = @skid;
        @apply.type = @type;
        @apply.tab = @tab;
        startnew(CoroutineFunc(apply.Apply));
    }

    void Delete(SkidType@ type, SkidTypeTab@ tab)
    {
        print("Deleting skid to " + type.name);
        tab.isSkidApplied = false;
        tab.isSkidDeleted = false;
        tab.isSkidInProgress = true;

        string modWorkDir = IO::FromUserGameFolder("Skins/Stadium/ModWork");
        if (!IO::FolderExists(modWorkDir)) IO::CreateFolder(modWorkDir);
        if (type.name != "Dirt") {
            string fxImageDir = IO::FromUserGameFolder("Skins/Stadium/ModWork/CarFxImage");
            if (!IO::FolderExists(fxImageDir)) IO::CreateFolder(fxImageDir);
            string file = fxImageDir + "/Car"+type.name+"Marks.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
        } else {
            string file = modWorkDir + "/DirtMarks.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
            file = modWorkDir + "/DirtSmoke.dds";
            trace("Deleting " + file);
            if (IO::FileExists(file)) IO::Delete(file);
        }
        tab.isSkidDeleted = true;
        tab.isSkidInProgress = false;
    }

    void DeleteAll()
    {
        string modWorkDir = IO::FromUserGameFolder("Skins/Stadium/ModWork");
        if (IO::FolderExists(modWorkDir)) {
            array<string> files = IO::IndexFolder(modWorkDir, true);
            for (uint i = 0; i < files.Length; i++) {
                trace("Deleting " + files[i]);
                IO::Delete(files[i]);
            }
        }
        UI::ShowNotification(Icons::Check + " " + Meta::ExecutingPlugin().Name, "All customizations have been deleted.");
    }
}