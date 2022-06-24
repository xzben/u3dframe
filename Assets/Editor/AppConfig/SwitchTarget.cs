using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace InfiniteJoy
{
    public class SwitchTarget : MonoBehaviour
    {

        static void SwitchToTarget(BuildTargetGroup targetGroup, BuildTarget target)
        {
            var curTarget = EditorUserBuildSettings.activeBuildTarget;
            if (curTarget == target)
            {
                // EditorUtility.DisplayDialog("提示", "当前已经切换到指定的平台，无需再次切换", "确定");
                Debug.Log("当前已经切换到指定的平台，无需再次切换");
                return;
            }

            EditorUserBuildSettings.activeBuildTargetChanged += onActiveBuildTargetChanged;
            EditorUserBuildSettings.SwitchActiveBuildTarget(targetGroup, target);
        }

        static void onActiveBuildTargetChanged()
        {
            // Debug.Log("2222222222222222");
        }

        public static void SwtichToTarget(BuildTarget target)
        {
            switch(target)
            {
                case BuildTarget.Android:
                    {
                        SwitchToAndroid();
                        break;
                    };
                case BuildTarget.iOS:
                    {
                        SwitchToIOS();
                        break;
                    }
                case BuildTarget.StandaloneWindows:
                case BuildTarget.StandaloneWindows64:
                    {
                        SwitchToWindows();
                        break;
                    }
                case BuildTarget.StandaloneOSX:
                    {
                        SwitchToMacOSX();
                        break;
                    }
                default:
                    {
                        Debug.LogError("Unknow target");
                        break;
                    }
                    
            }
        }
        [MenuItem("打包/切换平台/Android")]
        public static void SwitchToAndroid()
        {
            SwitchToTarget(BuildTargetGroup.Android, BuildTarget.Android);
        }

        [MenuItem("打包/切换平台/iOS")]
        public static void SwitchToIOS()
        {
            SwitchToTarget(BuildTargetGroup.iOS, BuildTarget.iOS);
        }

        [MenuItem("打包/切换平台/Windows")]
        public static void SwitchToWindows()
        {
            SwitchToTarget(BuildTargetGroup.Standalone, BuildTarget.StandaloneWindows);
        }

        [MenuItem("打包/切换平台/MacOSX")]
        public static void SwitchToMacOSX()
        {
            SwitchToTarget(BuildTargetGroup.Standalone, BuildTarget.StandaloneOSX);
        }

    }
}