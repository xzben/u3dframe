using Sirenix.OdinInspector.Editor;
using Sirenix.Utilities;
using Sirenix.Utilities.Editor;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class UpdateToolWindow : UnityEditor.EditorWindow
{
    enum PlatformType{
        ALL,
        WIN,
        ANDROID,
        IOS,
        END,
    };

    string[] m_platforms = { "ALL", "WIN", "ANDROID", "IOS" };
    int m_curPlatform;
    string[] m_allVerions;
    int m_diffVersionIndex;

    Vector3 pos;
    float dir;

    [MenuItem("打包/热更新生成")]
    public static void showToolWindow()
    {
        var window = Editor.CreateInstance<UpdateToolWindow>();
        window.Show();
        window.position = GUIHelper.GetEditorWindowRect().AlignCenter(800, 600);
    }

    public static UpdateToolWindow instance;
 
    void OnEnable() {
        this.m_allVerions = this.getHistoryVersions().ToArray();
        Array.Sort(this.m_allVerions, delegate (string v1, string v2)
        {
            return LuaFramework.Util.compareVersion(v2, v1);
        });

        instance = this; 
    }

    void OnDisable() { instance = null; }


    List<string> getHistoryVersions()
    {
        string hirstoryPath = Path.Combine(System.Environment.CurrentDirectory, "builds", "history");

        DirectoryInfo root = new DirectoryInfo(hirstoryPath);
        DirectoryInfo[] dirs = root.GetDirectories();

        List<string> versions = new List<string>();
        foreach(var dirinfo in dirs)
        {
            versions.Add(dirinfo.Name);
        }

        return versions;
    }

    List<string> getMiniVersions(string version )
    {
        List<string> miniVersions = new List<string>();

        foreach(string tempVersion in this.m_allVerions)
        {
            if(LuaFramework.Util.compareVersion(version, tempVersion) > 0)
            {
                miniVersions.Add(tempVersion);
            }
        }

        return miniVersions;
    }

    string getPlatformName(PlatformType platform)
    {
        switch (platform) {
            case PlatformType.ANDROID:
                return "Android";
            case PlatformType.WIN:
                return "Win";
            case PlatformType.IOS:
                return "iOS";
        }

        throw new Exception("unknow platfrom");
    }

    string getVersionPackagePath( string version, PlatformType platform)
    {
        string hirstoryPath = Path.Combine(System.Environment.CurrentDirectory, "builds", "history");
        string platformName = getPlatformName(platform);

        string path = string.Format("{0}/{1}/{2}", hirstoryPath, version, platformName);
        if (!Directory.Exists(path))
            return "";

        DirectoryInfo root = new DirectoryInfo(path);
        FileInfo[] fileinfos = root.GetFiles();

        if(fileinfos.Length > 1 || fileinfos.Length <= 0)
        {
            throw new Exception("version package file num error:"+ fileinfos.Length);
        }

        return fileinfos[0].FullName;
    }

    void unzipPackage(string packagePath, string targetPath, string version)
    {
        string unzip1 = Path.Combine(targetPath, version);
        if (Directory.Exists(unzip1))
        {
            Directory.Delete(unzip1, true);
        }
        Directory.CreateDirectory(unzip1);

        FileTools.ExtractToDirectory(packagePath, unzip1);

        string myluaZip = Path.Combine(unzip1, "myLua.bytes");
        string bundleZip = Path.Combine(unzip1, "AssetBundles.bytes");

        if (!File.Exists(myluaZip))
        {
            throw new Exception("can't find mylua package");
        }

        if (!File.Exists(bundleZip))
        {
            throw new Exception("can't find bundle package");
        }

        FileTools.ExtractToDirectory(myluaZip, unzip1);
        FileTools.ExtractToDirectory(bundleZip, unzip1);
    }

    bool checkFileDiff(string file1, string file2)
    {
        if(!File.Exists(file1) || !File.Exists(file2))
        {
            return true;
        }

        byte[] content1 = File.ReadAllBytes(file1);
        byte[] content2 = File.ReadAllBytes(file2);

        if(content1.Length != content2.Length)
        {
            return true;
        }

        for(int i = 0; i < content1.Length; i++)
        {
            if(content1[i] != content2[i])
            {
                return true;
            }
        }

        return false;
    }

    void selectDiffFile(string diffpath, string unzippath, string verionMax, string versionMin)
    {
        string luaPath1 = Path.Combine(unzippath, verionMax, "myLua");
        string luaPath2 = Path.Combine(unzippath, versionMin, "myLua");

        string diffDestPath = Path.Combine(diffpath, "myLua");

        luaPath1.Replace('\\', '/');
        luaPath2.Replace('\\', '/');

        if (Directory.Exists(diffDestPath))
        {
            Directory.Delete(diffDestPath, true);
        }
        Directory.CreateDirectory(diffDestPath);

        string[] files = Directory.GetFiles(luaPath1, "*.*", SearchOption.AllDirectories);
        foreach(var file in files)
        {
            file.Replace('\\', '/');

            string minpath = file.Replace(luaPath1, luaPath2);

            string path = file.Replace(luaPath1, "");
            string destfilename = diffDestPath + path;

            if (!File.Exists(minpath) || checkFileDiff(file, minpath))
            {
                if (File.Exists(destfilename))
                {
                    File.Delete(destfilename);
                }

                string destpath = Path.GetDirectoryName(destfilename);
                if (!Directory.Exists(destpath))
                    Directory.CreateDirectory(destpath);
                File.Copy(file, destfilename);
            }
        }

        string bundlePath1 = Path.Combine(unzippath, verionMax, "AssetBundles");
        string bundlePath2 = Path.Combine(unzippath, versionMin, "AssetBundles");
        diffDestPath = Path.Combine(diffpath, "AssetBundles");
        bundlePath1.Replace('\\', '/');
        bundlePath2.Replace('\\', '/');

        files = Directory.GetFiles(bundlePath1, "*.*", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            file.Replace('\\', '/');

            string minpath = file.Replace(bundlePath1, bundlePath2);

            string path = file.Replace(bundlePath1, "");
            string destfilename = diffDestPath + path;

            if (!File.Exists(minpath) || checkFileDiff(file, minpath))
            {
                if (File.Exists(destfilename))
                {
                    File.Delete(destfilename);
                }

                string destpath = Path.GetDirectoryName(destfilename);
                if (!Directory.Exists(destpath))
                    Directory.CreateDirectory(destpath);
                File.Copy(file, destfilename);
            }
        }
    }

    void PackageDifffiles(string diffpath, string versionMin, string versionMax, PlatformType platfrom)
    {
        string diffLuaPath = Path.Combine(diffpath, "myLua");
        string diffbundlePath = Path.Combine(diffpath, "AssetBundles");

        string luaBytes = Path.Combine(diffpath, "myLua.bytes");
        string bundleBytes = Path.Combine(diffpath, "AssetBundles.bytes");

        FileTools.CreateZipFromDirectory(diffLuaPath, luaBytes, System.IO.Compression.CompressionLevel.Fastest, true);
        FileTools.CreateZipFromDirectory(diffbundlePath, bundleBytes, System.IO.Compression.CompressionLevel.Fastest, true);

        Directory.Delete(diffLuaPath, true);
        Directory.Delete(diffbundlePath, true);

        string packageName = string.Format("{0}_{1}.zip", versionMin, versionMax);
        string platformName = getPlatformName(platfrom);
        string hirstoryPath = Path.Combine(System.Environment.CurrentDirectory, "builds", "history");
        string packagePath = Path.Combine(hirstoryPath, versionMax, platformName, "diff");
        if (!Directory.Exists(packagePath))
            Directory.CreateDirectory(packagePath);

        string packagezipfile = Path.Combine(packagePath, packageName);

        FileTools.CreateZipFromDirectory(diffpath, packagezipfile, System.IO.Compression.CompressionLevel.Fastest, false);
    }

    void diffVersionPackage(string maxVersion, string minVersion, PlatformType platfrom)
    {
        string path1 = getVersionPackagePath(maxVersion, platfrom);
        string path2 = getVersionPackagePath(minVersion, platfrom);

        if (path1 == "" || path2 == "") return;

        string tempRoot = Path.Combine(System.Environment.CurrentDirectory, "builds", "updateToolTemp");
        string tempPath = Path.Combine(tempRoot, "unzip");
        string tempDiffPath = Path.Combine(tempRoot, "diff");

        if (Directory.Exists(tempRoot))
            Directory.Delete(tempRoot, true);
        Directory.CreateDirectory(tempRoot);

        unzipPackage(path1, tempPath, maxVersion);
        unzipPackage(path2, tempPath, minVersion);

        selectDiffFile(tempDiffPath, tempPath, maxVersion, minVersion);
        PackageDifffiles(tempDiffPath, minVersion, maxVersion, platfrom);

        Directory.Delete(tempRoot, true);
    }

    void doDiffPackage(string diffVersion, PlatformType platfrom)
    {
        Debug.Log("doDiffPackage:" + diffVersion);
        List<string> needVersion = this.getMiniVersions(diffVersion);

        if (needVersion.Count <= 0) return;
       
        foreach(string minVersion in needVersion)
        {
            if(platfrom == PlatformType.ALL)
            {
                for(var i = PlatformType.ALL + 1; i < PlatformType.END; i++)
                {
                    diffVersionPackage(diffVersion, minVersion, i);
                }
            }
            else
            {
                diffVersionPackage(diffVersion, minVersion, platfrom);
            }
        }
    }

    void OnGUI()
    {
        EditorGUILayout.Space();
        GUILayout.BeginVertical();

        m_diffVersionIndex = EditorGUILayout.Popup("DiffVersion", m_diffVersionIndex, this.m_allVerions);
        EditorGUILayout.Space();

        m_curPlatform = EditorGUILayout.Popup("Platform", m_curPlatform, this.m_platforms);
        EditorGUILayout.Space();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("开始差分"))
        {
            doDiffPackage(this.m_allVerions[m_diffVersionIndex], (PlatformType)m_curPlatform);
        }
        if (GUILayout.Button("关闭界面"))
        {
            instance.Close();
        }
        GUILayout.EndHorizontal();
        GUILayout.EndVertical();
    }

    #region 窗体事件调用
    private void OnProjectChange()
    {
        //Debug.Log("当场景改变时调用");
    }

    private void OnHierarchyChange()
    {
        //Debug.Log("当选择对象属性改变时调用");
    }

    void OnGetFocus()
    {
        //Debug.Log("当窗口得到焦点时调用");
    }

    private void OnLostFocus()
    {
        //Debug.Log("当窗口失去焦点时调用");
    }

    private void OnSelectionChange()
    {
        //Debug.Log("当改变选择不同对象时调用");
    }

    private void OnInspectorUpdate()
    {
        //Debug.Log("监视面板调用");
    }

    private void OnDestroy()
    {
        //Debug.Log("当窗口关闭时调用");
    }

    private void OnFocus()
    {
        //Debug.Log("当窗口获取键盘焦点时调用");
    }
    #endregion

}

