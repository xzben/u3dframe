

using UnityEngine;
using System.Runtime.InteropServices;

namespace LuaFramework
{
    public class PlatformManager : Manager
    {

#if UNITY_IOS
	[DllImport("__Internal" )]
    static extern void __callStaticMethod(string className, string methodName, string json);
    [DllImport("__Internal" )]
    static extern int __callStaticMethodReturnInt(string className, string methodName, string json);
    [DllImport("__Internal" )]
    static extern string __callStaticMethodReturnString(string className, string methodName, string json);
#endif

        public int getPlatfromType()
        {

#if UNITY_EDITOR
            return 0;
#elif UNITY_ANDROID
            return 1;
#elif UNITY_IOS
        return 2;
#elif UNITY_STANDALONE
        return 3;
#else
        return -1;
#endif
        }


        public void callNative(string className, string methodName, params object[] args)
        {
            UnityEngine.Debug.Log("====callNative===" + className + "," + methodName);
#if UNITY_ANDROID
            AndroidJavaClass ajo = new AndroidJavaClass(className);
            if (ajo == null)
            {
                Debug.Log("Can't find className:" + className);
                return;
            }
            if (args == null)
            {
                args = new object[] {};
            }
            ajo.CallStatic(methodName, args);
# elif UNITY_IOS
            //IOS调用静态函数只支持一个json参数或者null参数
            if ( args != null && args.Length == 1 && args[0] is string)
            {
                UnityEngine.Debug.Log("callNative className:" + className + " methodName:" + methodName + " json:" + args[0].ToString());
                __callStaticMethod(className, methodName, args[0].ToString());
            }
            else if(args == null || args.Length == 0)
            {
                UnityEngine.Debug.Log("callNative className:" + className + " methodName:" + methodName);
                __callStaticMethod(className, methodName, null);
            }
#endif
        }

        public int callNativeReturnInt(string className, string methodName, params object[] args)
        {
            UnityEngine.Debug.Log("====callNativeReturnInt===" + className + "," + methodName);
#if UNITY_ANDROID
            AndroidJavaClass ajo = new AndroidJavaClass(className);
            if (ajo == null)
            {
                Debug.Log("Can't find className:" + className);
                return -1;
            }
            if (args == null)
            {
                args = new object[] { };
            }
            return ajo.CallStatic<int>(methodName, args);
# elif UNITY_IOS
            if ( args != null && args.Length == 1 && args[0] is string)
            {
                return __callStaticMethodReturnInt(className, methodName, args[0].ToString());
            }
            else if(args == null || args.Length == 0)
            {
                return __callStaticMethodReturnInt(className, methodName, null);
            }
#endif
            return -1;
        }

        public string callNativeReturnString(string className, string methodName, params object[] args)
        {
            UnityEngine.Debug.Log("====callNativeReturnString===" + className + "," + methodName);
#if UNITY_ANDROID
            AndroidJavaClass ajo = new AndroidJavaClass(className);
            if (ajo == null)
            {
                Debug.Log("Can't find className:" + className);
                return "";
            }
            if (args == null)
            {
                args = new object[] { };
            }
            return ajo.CallStatic<string>(methodName, args);
# elif UNITY_IOS
            if ( args != null && args.Length == 1 && args[0] is string)
            {
                return __callStaticMethodReturnString(className, methodName, args[0].ToString());
            }
            else if(args == null || args.Length == 0)
            {
                return __callStaticMethodReturnString(className, methodName, null);
            }
#endif
            return "";
        }


        public void callEngine(string msg)
        {
            AppEventManager.OnPlatformEvent(msg);
        }
    }
}
