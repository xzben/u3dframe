using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System.IO;
#if UNITY_IOS
using UnityEditor.iOS.Xcode;

public static class MyBuildPostprocess
{
	[PostProcessBuild(999)]
	public static void OnPostProcessBuild( BuildTarget buildTarget, string path)
	{
		if(buildTarget == BuildTarget.iOS)
		{
			string projectPath = path + "/Unity-iPhone.xcodeproj/project.pbxproj";

			PBXProject pbxProject = new PBXProject();
			pbxProject.ReadFromFile(projectPath);

			//string target1 = pbxProject.TargetGuidByName("Unity-iPhone");
			//var targetGUID = pbxProject.GetUnityMainTargetGuid();
			string target = pbxProject.GetUnityFrameworkTargetGuid();
			
			//"z.entitlemests"名字自取
			//var capManager = new ProjectCapabilityManager(projectPath, "z.entitlements", target);
			//capability设置
			//SetCapabilities(capManager);
 
			//BuildSetting
			SetBuidSetting(pbxProject, target, projectPath);

			//framework
			AddFramework(pbxProject, target, projectPath);

			//plist文件
			AddPlist(path);

			//代码
			AddiosCode(path);
			
			//cocoaPods文件
			addCocoaPods(path);

			pbxProject.WriteToFile (projectPath);
		}
	}

	private static void SetCapabilities(ProjectCapabilityManager manager)
	{
//		//推送
//		manager.AddPushNotifications(true);
//		//内购
//		manager.AddInAppPurchase();
//		manager.WriteToFile();
	}

	private static void SetBuidSetting(PBXProject project, string target, string projectpath)
	{
		string linkerFlag = "OTHER_LDFLAGS";
		project.SetBuildProperty(target, "ENABLE_BITCODE", "NO");
		project.SetBuildProperty(target, "GCC_ENABLE_OBJC_EXCEPTIONS", "YES");
		//project.SetBuildProperty (target, "CLANG_ENABLE_OBJC_ARC", "NO");
		
		//--- weixin sdk need setting begin ---
		project.AddBuildProperty (target, linkerFlag, "-ObjC");
		
		
		//		project.AddBuildProperty (target, linkerFlag, "-all_load");  //注释掉因为会导致 tolua 重复函数定义报错
		//--- weixin sdk need setting end ---

		string searchPath = "HEADER_SEARCH_PATHS";
		project.AddBuildProperty (target, searchPath, "$(SRCROOT)/Libraries/Plugins/iOS/SDK/");

	}

	private static void AddFramework(PBXProject project, string target, string projectpath)
	{
		string[] frameworkArr = { 
			// ---- weixin sdk need --
			"SystemConfiguration.framework",
			"libz.tbd",
			"libsqlite3.0.tbd",
			"libc++.tbd",
			"Security.framework",
			"CoreTelephony.framework",
			"CFNetwork.framework",
			"CoreGraphics.framework",
			//---  weixin sdk need end ----

			"StoreKit.framework",
			"AuthenticationServices.framework",
		};

		foreach(string str in frameworkArr)
		{
			project.AddFrameworkToProject (target, str, false);
		}
	}

	private static void AddPlist(string path)
	{
		string plistPath = path + "/Info.plist";
		PlistDocument plist = new PlistDocument();
		plist.ReadFromString(File.ReadAllText(plistPath));

		PlistElementDict rootDic = plist.root;
		rootDic.SetString("GADApplicationIdentifier", "ca-app-pub-3940256099942544~1458002511");
		PlistElementArray mobAdNetItems = rootDic.CreateArray("SKAdNetworkItems");
		string[] netIds = { "cstr6suwn9.skadnetwork", "4fzdc2evr5.skadnetwork", "2fnua5tdw4.skadnetwork" };
		for(int i = 0; i < netIds.Length; i++)
		{
			string netId = netIds[i];
			PlistElementDict item = mobAdNetItems.AddDict();
			item.SetString("SKAdNetworkIdentifier", netId);
		}
		File.WriteAllText(plistPath, plist.WriteToString());
	}

	private static void AddiosCode(string path)
	{
		//XClass UnityAppController = new XClass (path + "/Classes/UnityAppController.mm");
		//UnityAppController.WriteBelow ("#include \"PluginBase/AppDelegateListener.h\"", "#include <wx/WXUtil.h>");
		//UnityAppController.WriteBelow ("NSDictionary* notifData = [NSDictionary dictionaryWithObjects: values forKeys: keys];\n    AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData);","    if([WXApi handleOpenURL:url delegate:[WXApiManager shareManager]] == FALSE)\n        return FALSE;");
	}

	private static void addCocoaPods(string path)
	{
		string sourcePodsPath = Path.Combine(System.Environment.CurrentDirectory, "Assets/Plugins/iOS/Podfile");
		string destPodsPath = path + "Podfile";
		File.Copy(sourcePodsPath, destPodsPath, true);
		
		string sourcePodsShPath = Path.Combine(System.Environment.CurrentDirectory, "Assets/Plugins/iOS/Podfile.sh");
		string destPodsShPath = path + "Podfile.sh";
		File.Copy(sourcePodsShPath, destPodsShPath, true);

		string argss =  destPodsShPath +" "+ path;
		System.Diagnostics.Process.Start("/bin/bash", argss);

		UnityEngine.Debug.Log("addCocoaPods end ");
	}
}

#endif