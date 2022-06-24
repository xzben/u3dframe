using ICSharpCode.SharpZipLib.Zip;
using LuaFramework;
using LuaInterface;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using UnityEditor;
using UnityEditor.U2D;
using UnityEngine;

public class Packager {
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();

    [MenuItem("发布/Build iPhone Resource", false, 100)]
    public static void BuildiPhoneResource() {
        BuildTarget target;
#if UNITY_5
        target = BuildTarget.iOS;
#else
        target = BuildTarget.iOS;
#endif
        BuildAssetResource(target);
    }

    [MenuItem("发布/Build Android Resource", false, 101)]
    public static void BuildAndroidResource() {
        BuildAssetResource(BuildTarget.Android);
        CopyAB(BuildTarget.Android);
    }

    [MenuItem("发布/Build Windows Resource", false, 102)]
    public static void BuildWindowsResource() {
        BuildAssetResource(BuildTarget.StandaloneWindows);
        CopyAB(BuildTarget.StandaloneWindows);
    }

    [MenuItem("发布/Build Windows64 Resource", false, 102)]
    public static void BuildWindow64sResource()
    {
        BuildAssetResource(BuildTarget.StandaloneWindows64);
        CopyAB(BuildTarget.StandaloneWindows64);
    }

    [MenuItem("发布/发布打包Lua", false, 103)]
    public static void BuildAllLua()
    {
        //将lua 文件先加密
        ASE();
        string sourceVersionFilePath = Path.Combine(System.Environment.CurrentDirectory, "Assets/Lua/myLua/Lua/Version.lua");
        string destVersionFilePath = Path.Combine(System.Environment.CurrentDirectory, "Assets/Resources/VersionStamp.bytes");
        // 拷贝版本文件
        File.Copy(sourceVersionFilePath, destVersionFilePath, true);

        string targetFilePath = Path.Combine(Application.streamingAssetsPath, "myLua.bytes");
        if (File.Exists(targetFilePath))
        {
            // 先删除旧的压缩包文件
            File.Delete(targetFilePath);
        }

        string luaPath = Path.Combine(System.Environment.CurrentDirectory, "ASM/myLua");
        try
        {
            FileTools.CreateZipFromDirectory(luaPath, targetFilePath, System.IO.Compression.CompressionLevel.Fastest, true);
        }
        catch (Exception ex)
        {
            UnityEngine.Debug.LogError(ex.Message);
        }

        AssetDatabase.Refresh();
    }

    public static string getCurVersion()
    {
        string file = LuaConst.luaDir + "/Version.lua";
        return File.ReadAllText(file);
    }

    public static void ASE()
    {
        try
        {
            //删除旧的文件夹
            if (FileTools.DirectoryExists(System.Environment.CurrentDirectory + "/ASM"))
            {
                FileTools.FolderDelete(System.Environment.CurrentDirectory + "/ASM");
            }

            UnityEngine.Debug.Log("ASM path:" + System.Environment.CurrentDirectory + "/ASM");
            //string testFile = Application.dataPath + "/Lua/myLua/Lua/Main.lua";

            //把Lua文件加密，copy 到 总工程目录/ASM 下
            EncryptAllLuaFile(Application.dataPath + "/Lua", System.Environment.CurrentDirectory + "/ASM");

            UnityEngine.Debug.Log("AES Success!");
        }
        catch (Exception e)
        {
            UnityEngine.Debug.LogError(e.Message + e.StackTrace);
            //Console.WriteLine("Error: {0}", e.Message);
        }
    }

    public static void EncodeLuaFile(string srcFile, string outFile)
    {
        if (srcFile.ToLower().EndsWith(".meta"))
            return;

        if (!srcFile.ToLower().EndsWith(".lua"))
        {
            File.Copy(srcFile, outFile, true);
            return;
        }
        byte[] outContent = Util.DESEncrypt(File.ReadAllBytes(srcFile));
        File.WriteAllBytes(outFile, outContent);
    }

    public static void EncryptAllLuaFile(string srcPath, string destPath)
    {
        try
        {
            // 检查目标目录是否以目录分割字符结束如果不是则添加
            if (destPath[destPath.Length - 1] != System.IO.Path.DirectorySeparatorChar)
            {
                destPath += System.IO.Path.DirectorySeparatorChar;
            }
            // 判断目标目录是否存在如果不存在则新建
            if (!System.IO.Directory.Exists(destPath))
            {
                System.IO.Directory.CreateDirectory(destPath);
            }

            string[] fileList = System.IO.Directory.GetFileSystemEntries(srcPath);
            // 遍历所有的文件和目录
            foreach (string file in fileList)
            {
                // 先当作目录处理如果存在这个目录就递归Encrypt该目录下面的Lua文件
                if (System.IO.Directory.Exists(file))
                {
                    EncryptAllLuaFile(file, destPath + System.IO.Path.GetFileName(file));
                }
                else
                {
                    string dest = destPath + System.IO.Path.GetFileName(file);
                    EncodeLuaFile(file, dest);
                }
            }
        }
        catch (Exception e)
        {
            UnityEngine.Debug.LogError(e.Message + e.StackTrace);
            throw e;
        }
    }

    public static void BuildAssetResource(BuildTarget target)
    {
        SpriteAtlasUtility.PackAllAtlases(target);
        string _base_path = new DirectoryInfo("./AssetBundles").FullName.Replace('\\', '/');
        if (target == BuildTarget.iOS)
        {
            _base_path += "/iOS";
        }
        else if (target == BuildTarget.Android)
        {
            _base_path += "/Android";
        }
        else if (target == BuildTarget.StandaloneWindows64 || target == BuildTarget.StandaloneWindows)
        {
            _base_path += "/Win";
        }
        else
        {
            UnityEngine.Debug.Log("打包出错");
        }

        if (Directory.Exists(_base_path))
        {
            Directory.Delete(_base_path, true);
        }
        Directory.CreateDirectory(_base_path);

        maps.Clear();

        FindFile("Assets/Res");

        BuildAssetBundleOptions options = BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression;
        BuildPipeline.BuildAssetBundles(_base_path, maps.ToArray(), options, target);

        AssetDatabase.Refresh();
        UnityEngine.Debug.Log("生成完毕.");
    }

    static void FindFile(string dirPath)
    {
        DirectoryInfo dir = new DirectoryInfo(dirPath);

        //查找文件
        string[] files = Directory.GetFiles(dirPath);
        List<string> resFiles = new List<string>();
        for (int i = 0; i < files.Length; i++)
        {
            if (files[i].EndsWith(".meta"))
            {
                continue;
            }
            files[i] = files[i].Replace('\\', '/').Replace(Application.dataPath, "Assets");
            resFiles.Add(files[i]);

            //UnityEngine.Debug.Log(files[i]);
        }
        if (resFiles.Count > 0)
        {
            string _ab_name = dir.FullName.Replace('\\', '/').Replace(Application.dataPath, "").Replace("/Res/", "");

            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = _ab_name;
            build.assetNames = resFiles.ToArray();
            maps.Add(build);
        }

        //目录
        foreach (DirectoryInfo d in dir.GetDirectories())
        {
            FindFile(d.FullName);
        }
    }

    public static bool CopyAB(BuildTarget target = BuildTarget.Android, string source = "", string dest = "")
    {
        string build_target = "";
        if (target == BuildTarget.Android)
            build_target = "Android";
        else if (target == BuildTarget.iOS)
            build_target = "iOS";
        else if (target == BuildTarget.StandaloneWindows || target == BuildTarget.StandaloneWindows64)
            build_target = "Win";
        else
        {
            UnityEngine.Debug.LogError("没有设置这个编译环境的 ab 包目录");
            return false;
        }
        // 判断使用默认路径
        if (source == "")
            source = Path.Combine(System.Environment.CurrentDirectory, "AssetBundles");
        if (dest == "")
            dest = Path.Combine(System.Environment.CurrentDirectory, "Assets/StreamingAssets/AssetBundles");

        // 清空一下目录,避免里面存在其他平台的ab包内容,例如：当前先编译了安卓,现在编译ios,不清理的话会多一个平台ab包
        if (Directory.Exists(dest))
            Directory.Delete(dest, true);

        // 拷贝过去
        FileTools.CopyDir(Path.Combine(source, build_target), Path.Combine(dest, build_target));

        string bytesFile = dest + ".bytes";
        // 原地将 AssetBundles 打个zip压缩包,用于自己上传到后台用的
        if (File.Exists(bytesFile))
            File.Delete(bytesFile);

        FileTools.CreateZipFromDirectory(dest, bytesFile, System.IO.Compression.CompressionLevel.Fastest, true);
        Directory.Delete(dest, true);

        //AssetDatabase.Refresh(); //好像不需要刷新这里的资源
        return true;
    }

    public static bool backupABHistory(BuildTarget target = BuildTarget.Android)
    {
        string build_target = "";
        if (target == BuildTarget.Android)
            build_target = "Android";
        else if (target == BuildTarget.iOS)
            build_target = "iOS";
        else if (target == BuildTarget.StandaloneWindows || target == BuildTarget.StandaloneWindows64)
            build_target = "Win";
        else
        {
            UnityEngine.Debug.LogError("没有设置这个编译环境的 ab 包目录");
            return false;
        }

        string luabytes = Path.Combine(Application.streamingAssetsPath, "myLua.bytes");
        string bundlebytes = Path.Combine(Application.streamingAssetsPath, "AssetBundles.bytes");

        string destTargetPath = Path.Combine(System.Environment.CurrentDirectory, "builds", "history", getCurVersion(), build_target);
        string destpath = Path.Combine(destTargetPath, "package");

        string destluaBytes = Path.Combine(destpath, "myLua.bytes");
        string destbundleBytes = Path.Combine(destpath, "AssetBundles.bytes");

        //删掉旧版本
        if (!FileTools.isDirectoryEmpty(destTargetPath))
        {
            Directory.Delete(destTargetPath, true);
            Directory.CreateDirectory(destpath);
        }

        if (!Directory.Exists(destpath))
        {
            Directory.CreateDirectory(destpath);
        }

        if(File.Exists(destluaBytes))
        {
            File.Delete(destluaBytes);
        }

        if (File.Exists(destbundleBytes))
        {
            File.Delete(destbundleBytes);
        }

        File.Copy(luabytes, destluaBytes);
        File.Copy(bundlebytes, destbundleBytes);

        string str_time = DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss");
        string package_file_name = string.Format(@"{0}/ver_{1}_{2}.zip", destTargetPath, getCurVersion(), str_time);

        FileTools.CreateZipFromDirectory(destpath, package_file_name, System.IO.Compression.CompressionLevel.Fastest, false);

        Directory.Delete(destpath, true);

        return true;
    }
}