using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaFramework
{
    public class AppConst
    {
        public static string LuaDir = Application.dataPath + "/Lua";                //lua逻辑代码目录
        public static string ToLuaDir = Application.dataPath + "/3rd/ToLua/ToLua/Lua";        //tolua lua文件目录
        public static string LuaBundleTemp = Application.dataPath + "Lua";

        public const bool DebugMode = false;                       //调试模式-用于内部测试
        public const bool BundleRes = false;                     //资源打包
     
        public const bool LuaByteMode = false;                       //Lua字节码模式-默认关闭 
        public const bool LuaBundleMode = false;                    //Lua代码AssetBundle模式
        public const string DESSignal = "asdkfjqweqfdfadsf";
        public const string LuaDESKey = "1asfjadksfjadsfj12123123123asdfadsf";                         //Lua使用DES加密用的Key
        public const int TimerInterval = 1;
        public const int GameFrameRate = 60;                        //游戏帧频

        public const string AppName = "unity3dframe";               //应用程序名称
        public const string AppPrefix = AppName + "_";              //应用程序前缀
        public const string ExtName = ".unity3d";                   //素材扩展名
        public const string AssetDir = "StreamingAssets";           //素材目录 

        public static string FrameworkRoot
        {
            get
            {
                return Application.dataPath;
            }
        }
    }
}
