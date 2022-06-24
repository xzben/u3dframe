using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using System;
using UnityEditor.Build.Reporting;

namespace InfiniteJoy
{
    public class AppBuilder : MonoBehaviour
    {
        static List<string> levels = new List<string>();

        [MenuItem("打包/打开编辑器持久目录")]
        public static void OpenWinEditorPersistentDataPath()
        {
            RestoreCompanyName();
            string path = Application.persistentDataPath;
            System.Diagnostics.Process.Start(path);
        }

        [MenuItem("打包/打开win模拟器持久目录")]
        public static void OpenWinStandlonePersistentDataPath()
        {
            RestoreWinStandloneName();
            string path = Application.persistentDataPath;
            System.Diagnostics.Process.Start(path);
            RestoreCompanyName();
        }

        [MenuItem("打包/恢复默认公司名")]
        public static void RestoreCompanyName()
        {
            PlayerSettings.companyName = "yckj";
            PlayerSettings.productName = "UnityGame";
        }

        public static void RestoreWinStandloneName()
        {
            PlayerSettings.companyName = "yckj";
            PlayerSettings.productName = "UnityGame";
        }

        [MenuItem("打包/平台工程/release/生成Android工程")]
        public static void ExportAndroidProjectRelease()
        {
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            BuildAndroidRelease();
        }

        [MenuItem("打包/平台工程/debug/生成Android工程")]
        public static void ExportAndroidProjectDebug()
        {
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            BuildAndroidDebug();
        }

        [MenuItem("打包/构建APP/release/Android")]
        public static void BuildAndroidRelease()
        {
            ReleaseImp.BuildAppABAnroid(true);
            
            BuildAndroid(true);
        }

        [MenuItem("打包/构建APP/release/iOS")]
        static void BuildIOSRelease()
        {
            ReleaseImp.BuildAppABIOS(true);
            BuildIOS(true);
        }

        [MenuItem("打包/构建APP/release/Win模拟器")]
        static void BuildWindowsRelease()
        {
            ReleaseImp.BuildAppABWindows(true);
            BuildWindows(true);
        }

        [MenuItem("打包/构建APP/release/所有平台包生成")]
        static void BuildAllAppRelease()
        {
            BuildAndroidRelease();
            BuildWindowsRelease();
        }


        [MenuItem("打包/构建APP/debug/Android")]
        public static void BuildAndroidDebug()
        {
            ReleaseImp.BuildAppABAnroid(false);
            BuildAndroid(false);
        }

        [MenuItem("打包/构建APP/debug/iOS")]
        static void BuildIOSDebug()
        {
            ReleaseImp.BuildAppABIOS(false);
            BuildIOS(false);
        }

        [MenuItem("打包/构建APP/debug/Win模拟器")]
        static void BuildWindowsDebug()
        {
            ReleaseImp.BuildAppABWindows(false);
            BuildWindows(false);
        }

        [MenuItem("打包/构建APP/debug/所有平台包生成")]
        static void BuildAllAppDebug()
        {
            BuildAndroidDebug();
            BuildWindowsDebug();
        }


        [MenuItem("打包/构建APP/已有AB直接构建/Android release")]
        public static void BuildAndroidOnlyRelease()
        {
            BuildAndroid(true);
        }
        [MenuItem("打包/构建APP/已有AB直接构建/iOS release")]
        public static void BuildiOSOnlyRelease()
        {
            BuildIOS(true);
        }

        [MenuItem("打包/构建APP/已有AB直接构建/Windows release")]
        public static void BuildWindowsOnlyRelease()
        {
            BuildWindows(true);
        }


        [MenuItem("打包/构建APP/已有AB直接构建/Android debug")]
        public static void BuildAndroidOnlyDebug()
        {
            BuildAndroid(false);
        }

        [MenuItem("打包/构建APP/已有AB直接构建/iOS debug")]
        public static void BuildiOSOnlyDebug()
        {
            BuildIOS(false);
        }

        [MenuItem("打包/构建APP/已有AB直接构建/Windows debug")]
        public static void BuildWindowsOnlyDebug()
        {
            BuildWindows(false);
        }


        private static Dictionary<string, string> ReadConfigs()
        {

            Dictionary<string, string> keystoreProperties = new Dictionary<string, string>();

            string projectPath = System.Environment.CurrentDirectory;
            string keystorePath = string.Format(@"{0}/../keystore/", projectPath);
            string keystoreConfigPath = string.Format(@"{0}/keystore.properties", keystorePath);

            keystoreProperties.Add("keystorePath", keystorePath);

            Debug.Log("keystore.properties=" + keystoreConfigPath);
            if (!File.Exists(keystoreConfigPath))
            {
                Debug.Log("keystore配置文件不存在！");
                return keystoreProperties;
            }

            using (FileStream fs = File.OpenRead(keystoreConfigPath))
            {
                using (StreamReader sr = new StreamReader(fs))
                {
                    while (!sr.EndOfStream)
                    {
                        string line = sr.ReadLine();

                        if (line.StartsWith("#"))
                        {
                            continue;
                        }

                        string[] arr = line.Split(new char[] { '=' });
                        if (arr.Length == 2)
                        {
                            string key = arr[0].Trim();
                            string value = arr[1].Trim();

                            keystoreProperties.Add(key, value);

                            Debug.Log(string.Format("key={0}, value={1}", key, value));
                        }
                    }
                }
            }

            return keystoreProperties;
        }

        public static void Build()
        {

        }

        public static string GetCurVersion()
        {
            return Packager.getCurVersion();
        }

        public static int GetCurVersionCode()
        {
            string version = GetCurVersion();
            int code = 0;
            string[] numbers = version.Split('.');

            foreach(string num in numbers)
            {
                if (num.Length > 3) Debug.LogError("the version num is to large max length is 3 version:"+ version);
                code = code * 1000 + int.Parse(num);
            }
            return code;
        }
        public static string GetBuildAppName(BuildTarget target, bool release)
        {
            string projectPath = System.Environment.CurrentDirectory;
            string platform = "win";
            string ext = "";
            switch (target)
            {
                case BuildTarget.Android:
                    {
                        platform = "android";
                        ext = ".apk";
                        break;
                    }
                case BuildTarget.iOS:
                    {
                        platform = "ios";
                        ext = "/";
                        break;
                    }
                case BuildTarget.StandaloneWindows:
                case BuildTarget.StandaloneWindows64:
                    {
                        platform = "win";
                        ext = "/gamestart.exe";
                        break;
                    }
            }
            string buildPath = string.Format(@"{0}/builds/packages/{1}/{2}", projectPath, GetCurVersion(), platform);
            if (!Directory.Exists(buildPath))
            {
                Directory.CreateDirectory(buildPath);
            }

            string version = GetCurVersion();
            version = version.Replace(".", "_");
            string str_time = DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss");
            string str_release = release ? "release" : "debug";
            string apk_name = string.Format(@"{0}/ver_{1}_time_{2}_{3}{4}", buildPath, version, str_time, str_release, ext);

            return apk_name;
        }

        public static void BuildAndroid(bool release)
        {
            string app_name = GetBuildAppName(BuildTarget.Android, release);
            Debug.Log("Build android/apk to:" + app_name);
            BuildTarget curTarget = EditorUserBuildSettings.activeBuildTarget;

            if (curTarget != BuildTarget.Android)
            {
                SwitchTarget.SwitchToAndroid();
            }

            EditorUserBuildSettings.exportAsGoogleAndroidProject = false;


            Dictionary<string, string> keystoreProperties = ReadConfigs();
            string keystore_name = keystoreProperties["keystore_name"];
            string keystorePath = keystoreProperties["keystorePath"];
            string keystore_name_path = keystore_name;
            if(!Path.IsPathRooted(keystore_name_path))
            {
                keystore_name_path = string.Format(@"{0}/{1}", keystorePath, keystore_name);
            }

            Debug.Log("keystore=" + keystore_name_path);
            if (!File.Exists(keystore_name_path))
            {
                Debug.Log("keystore签名文件不存在!");
                return;
            }

            PlayerSettings.Android.useCustomKeystore = true;
            PlayerSettings.Android.keystoreName = keystore_name_path;
            PlayerSettings.Android.keyaliasName = keystoreProperties["keyalias_name"];
            PlayerSettings.Android.keystorePass = keystoreProperties["keystore_pass"];
            PlayerSettings.Android.keyaliasPass = keystoreProperties["keyalias_pass"];

            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
            PlayerSettings.bundleVersion = GetCurVersion();
            PlayerSettings.Android.bundleVersionCode = GetCurVersionCode() ;
            PlayerSettings.applicationIdentifier = keystoreProperties["package_name"];
            PlayerSettings.companyName = keystoreProperties["company_name"];
            PlayerSettings.productName = keystoreProperties["product_name"];
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel21;



            Debug.Log("Add all scene.");
            levels.Clear();
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                levels.Add(scene.path);
            }

            Debug.Log("Start build android/apk.");

            BuildOptions options = BuildOptions.None;
            if (!release)
                options |= BuildOptions.Development;

            BuildReport res = BuildPipeline.BuildPlayer(levels.ToArray(), app_name, BuildTarget.Android, options);
            BuildSummary summary = res.summary;
            if (summary.result == BuildResult.Succeeded)
            {
                Debug.Log("Build android/apk succeeded:" + (summary.totalSize / 1024 / 1024) + "M");
            }
            else
            {
                Debug.Log("Build android/apk failed.");
            }


            string version = GetCurVersion();
            string projectPath = System.Environment.CurrentDirectory;
            string srcFolderPath = string.Format(@"{0}/Temp/gradleOut/apk/{1}", projectPath, release ? "release" : "debug");
            string[] fileList = Directory.GetFileSystemEntries(srcFolderPath);
            if (fileList.Length > 0)
            {
                string destFolderPath = string.Format(@"{0}/builds/packages/{1}/{2}/{3}", projectPath, version, "android", release ? "release" : "debug");
                if (!Directory.Exists(destFolderPath))
                {
                    Directory.CreateDirectory(destFolderPath);
                }
                string str_time = DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss");
                FileTools.CopyDirFilesByEx(srcFolderPath, destFolderPath, ".apk", str_time);
                FileTools.FolderDelete(srcFolderPath);
            }

            PlayerSettings.Android.useCustomKeystore = false;
            RestoreCompanyName();
            SwitchTarget.SwtichToTarget(curTarget);
        }

        static void BuildIOS(bool release)
        {
            string app_name = GetBuildAppName(BuildTarget.iOS, release);
            Debug.Log("构建苹果IPA"+ app_name);

            BuildTarget curTarget = EditorUserBuildSettings.activeBuildTarget;
            if (curTarget != BuildTarget.iOS)
            {
                EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.iOS, BuildTarget.iOS);
            }

            levels.Clear();
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                levels.Add(scene.path);
            }

            EditorUserBuildSettings.iOSBuildConfigType = iOSBuildType.Debug;

            Dictionary<string, string> configs = ReadConfigs();

            PlayerSettings.companyName = configs["company_name"];
            PlayerSettings.productName = configs["product_name"];
            PlayerSettings.bundleVersion = GetCurVersion();
            PlayerSettings.iOS.buildNumber = GetCurVersionCode().ToString();

            PlayerSettings.applicationIdentifier = configs["package_name"];

            if (Directory.Exists(app_name))
            {
                Directory.Delete(app_name, true);
            }

            BuildOptions options = BuildOptions.None;
            if (!release)
                options |= BuildOptions.Development;

            BuildReport res = BuildPipeline.BuildPlayer(levels.ToArray(), app_name, BuildTarget.iOS, options);
            BuildSummary summary = res.summary;
            if (summary.result == BuildResult.Succeeded)
            {
                Debug.Log("Export xcode project succeeded.");
            }
            else
            {
                Debug.Log("Export xcode project failed.");
            }

            RestoreCompanyName();
            SwitchTarget.SwtichToTarget(curTarget);
        }

        static void BuildWindows(bool release)
        {
            string app_name = GetBuildAppName(BuildTarget.StandaloneWindows, release);
            

            Debug.Log("构建Windows " + app_name);

            BuildTarget curTarget = EditorUserBuildSettings.activeBuildTarget;
            if (curTarget != BuildTarget.StandaloneWindows)
            {
                EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Standalone, BuildTarget.StandaloneWindows);
            }
            levels.Clear();
            foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                levels.Add(scene.path);
            }

            Dictionary<string, string> configs = ReadConfigs();

            RestoreWinStandloneName();

            PlayerSettings.fullScreenMode = FullScreenMode.Windowed;
            PlayerSettings.defaultScreenHeight = 960;
            PlayerSettings.defaultScreenWidth = 540;
            PlayerSettings.usePlayerLog = true;
            PlayerSettings.resizableWindow = true;
            PlayerSettings.runInBackground = true;

            BuildOptions options = BuildOptions.None;
            if (!release)
                options |= BuildOptions.Development;

            BuildReport res = BuildPipeline.BuildPlayer(levels.ToArray(), app_name, BuildTarget.StandaloneWindows, options);
            
            BuildSummary summary = res.summary;
            if (summary.result == BuildResult.Succeeded)
            {
                string app_path = Path.GetDirectoryName(app_name);
                string start_bat = Path.Combine(app_path, "start.bat");
                File.WriteAllText(start_bat, "start %cd%/gamestart.exe -writeablepath %cd%/writeablepath");
                Debug.Log("build window player succeeded.");
            }
            else
            {
                Debug.Log("build window player failed.");
            }

            RestoreCompanyName();
            SwitchTarget.SwtichToTarget(curTarget);
        }
    }
}