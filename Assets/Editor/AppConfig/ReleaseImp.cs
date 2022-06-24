using System.IO;
using UnityEditor;
using UnityEngine;

public class ReleaseImp
{
    public static void CreateAppConfig(int appid)
    {
        AppConfigModel model = new AppConfigModel(appid);
        string jsonData = Unity.Plastic.Newtonsoft.Json.JsonConvert.SerializeObject(model);
        File.WriteAllText(Application.dataPath + "/Resources/AppConfig.json", jsonData, System.Text.Encoding.UTF8);
    }

    [MenuItem("打包/发布AB包/Android")]
    public static void BuildAppABAnroid(bool release)//进行打包
    {
        CreateAppConfig(1);
        Packager.BuildAndroidResource();
        Packager.BuildAllLua();
        Packager.CopyAB(BuildTarget.Android);
        if(release)
            Packager.backupABHistory(BuildTarget.Android);
    }

    [MenuItem("打包/发布AB包/IOS")]
    public static void BuildAppABIOS(bool release)//进行打包
    {
        CreateAppConfig(2);
        Packager.BuildiPhoneResource();
        Packager.BuildAllLua();
        Packager.CopyAB(BuildTarget.iOS);
        if (release)
            Packager.backupABHistory(BuildTarget.iOS);
    }

    [MenuItem("打包/发布AB包/Windows")]
    public static void BuildAppABWindows(bool release)//进行打包
    {
        clearPersistentDataPath();
        CreateAppConfig(3);
        Packager.BuildWindowsResource();
        Packager.BuildAllLua();
        Packager.CopyAB(BuildTarget.StandaloneWindows);
        if (release)
            Packager.backupABHistory(BuildTarget.StandaloneWindows);
    }

    [MenuItem("打包/发布Lua并清除持久目录")]
    public static void BuildAppLuaOnly()//进行打包
    {
        clearPersistentDataPath();
        Packager.BuildAllLua();
    }

    public static void clearPersistentDataPath()
    {
        string verFilePath = System.IO.Path.Combine(Application.persistentDataPath, "bins", "current", "versionfiles", "VersionStamp");
        string  luaRoot = System.IO.Path.Combine(Application.persistentDataPath, "bins", "current", "running", "myLua");

        if (File.Exists(verFilePath))
        {
            File.Delete(verFilePath);
        }

        if (System.IO.Directory.Exists(luaRoot))
        {
            FileTools.FolderDelete(luaRoot);
        }
    }
}