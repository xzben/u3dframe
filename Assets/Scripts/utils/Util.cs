using LuaInterface;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

namespace LuaFramework
{
    public class Util
    {
        private static byte[] s_DESSignale = null;
        private static DESCryptoServiceProvider s_DESCProvider = null;
        public static long GetTime()
        {
            TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
            return (long)ts.TotalMilliseconds;
        }

        public static T Get<T>(GameObject go, string subnode) where T : Component
        {
            if (go != null)
            {
                Transform sub = go.transform.Find(subnode);
                if (sub != null) return sub.GetComponent<T>();
            }
            return null;
        }

        public static GameObject Child(GameObject go, string subnode)
        {
            return Child(go.transform, subnode);
        }

        /// <summary>
        /// 查找子对象
        /// </summary>
        public static GameObject Child(Transform go, string subnode)
        {
            Transform tran = go.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(GameObject go, string subnode)
        {
            return Peer(go.transform, subnode);
        }

        /// <summary>
        /// 取平级对象
        /// </summary>
        public static GameObject Peer(Transform go, string subnode)
        {
            Transform tran = go.parent.Find(subnode);
            if (tran == null) return null;
            return tran.gameObject;
        }

        /// <summary>
        /// 计算字符串的MD5值
        /// </summary>
        public static string md5(string source)
        {
            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
            byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
            md5.Clear();

            string destString = "";
            for (int i = 0; i < md5Data.Length; i++)
            {
                destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
            }
            destString = destString.PadLeft(32, '0');
            return destString;
        }

        /// <summary>
        /// 计算文件的MD5值
        /// </summary>
        public static string md5file(string file)
        {
            try
            {
                FileStream fs = new FileStream(file, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(fs);
                fs.Close();

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("md5file() fail, error:" + ex.Message);
            }
        }

        public static string GetFileText(string path)
        {
            return File.ReadAllText(path);
        }

        /// <summary>
        /// 网络可用
        /// </summary>
        public static bool NetAvailable
        {
            get
            {
                return Application.internetReachability != NetworkReachability.NotReachable;
            }
        }

        /// <summary>
        /// 是否是无线
        /// </summary>
        public static bool IsWifi
        {
            get
            {
                return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
            }
        }

        public static int getVersionCode(string versoin)
        {
            string[] sArray = versoin.Split('.');
            int code = 0;

            foreach (string i in sArray)
            {
                code = code * 1000 + int.Parse(i);
            }
            return code;

        }

        //返回 0 代表版本相等  > 0 代表 versionA > versionB  否则代表 versionA < versionB
        public static int compareVersion( string version1, string version2)
        {
            string[] v1 = version1.Split('.');
            string[] v2 = version2.Split('.');

            for(int i = 0; i < v1.Length ; i++)
            {
                int a = int.Parse(v1[i]);
                int b = 0;
                if(i < v2.Length)
                    b = int.Parse(v2[i]);

                if( a == b)
                {
                    continue;
                }
                else
                {
                    return a - b;
                }
            }

            if (v2.Length > v1.Length)
                return -1;

            return 0;
        }

        /// <summary>
        /// 应用程序内容路径
        /// </summary>
        public static string AppContentPath()
        {
            string path = string.Empty;
            switch (Application.platform)
            {
                case RuntimePlatform.Android:
                    path = "jar:file://" + Application.dataPath + "!/assets/";
                    break;
                case RuntimePlatform.IPhonePlayer:
                    path = Application.dataPath + "/Raw/";
                    break;
                default:
                    path = Application.dataPath + "/" + AppConst.AssetDir + "/";
                    break;
            }
            return path;
        }

        public static string DataPathRoot
        {
            get
            {
                string game = AppConst.AppName.ToLower();
                if (Application.isMobilePlatform)
                {
                    return Application.persistentDataPath + "/" + game + "/";
                }

                if (AppConst.DebugMode)
                {
                    return Application.dataPath + "/" + AppConst.AssetDir + "/";
                }

                if (Application.platform == RuntimePlatform.OSXEditor)
                {
                    int i = Application.dataPath.LastIndexOf('/');
                    return Application.dataPath.Substring(0, i + 1) + game + "/";
                }
                return "c:/" + game + "/";
            }
        }

        public static string DataPath
        {
            get
            {
                if (AppConst.DebugMode && !Application.isMobilePlatform)
                    return DataPathRoot;
                else
                    return DataPathRoot + "Codes/";

            }
        }

        public static string OtherDataPathRoot
        {
            get
            {
                if (AppConst.DebugMode && !Application.isMobilePlatform)
                    return DataPathRoot;
                else
                    return DataPathRoot + "Others/";

            }
        }
        public static string UpdateTempPath
        {
            get
            {
                string datapath = OtherDataPathRoot + "Update/";

                return datapath;
            }
        }

        public static string GetRelativePath()
        {
            if (Application.isEditor)
            {
                if (AppConst.DebugMode)
                    return "file://" + System.Environment.CurrentDirectory.Replace("\\", "/") + "/Assets/" + AppConst.AssetDir + "/";
                else
                    return "file:///" + DataPath;
            }
            else if (Application.isMobilePlatform || Application.isConsolePlatform)
                return "file:///" + DataPath;
            else // For standalone player.
                return "file://" + Application.streamingAssetsPath + "/";
        }
        /// <summary>
        /// 清除所有子节点
        /// </summary>
        public static void ClearChild(Transform go)
        {
            if (go == null) return;
            for (int i = go.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(go.GetChild(i).gameObject);
            }
        }

        public static void Log(string str)
        {
            Debug.Log(str);
        }

        public static void LogWarning(string str)
        {
            Debug.LogWarning(str);
        }

        public static void LogError(string str)
        {
            Debug.LogError(str);
        }

        /// <summary>
        /// 防止初学者不按步骤来操作
        /// </summary>
        /// <returns></returns>
        public static int CheckRuntimeFile()
        {
            if (!Application.isEditor) return 0;
            string streamDir = Application.dataPath + "/StreamingAssets/";
            if (!Directory.Exists(streamDir))
            {
                return -1;
            }
            else
            {
                string[] files = Directory.GetFiles(streamDir);
                if (files.Length == 0) return -1;

                if (!File.Exists(streamDir + "files.txt"))
                {
                    return -1;
                }
            }
            string sourceDir = AppConst.FrameworkRoot + "/ToLua/Source/Generate/";
            if (!Directory.Exists(sourceDir))
            {
                return -2;
            }
            else
            {
                string[] files = Directory.GetFiles(sourceDir);
                if (files.Length == 0) return -2;
            }
            return 0;
        }

        /// <summary>
        /// 执行Lua方法
        /// </summary>
        public static object[] CallMethod(string module, string func, params object[] args)
        {
            LuaManager luaMgr = GameWorld.Inst.LuaManager;
            if (luaMgr == null) return null;
            return luaMgr.CallFunction(module + "." + func, args);
        }

        public static void createLuaObject(string luaFile, params object[] args)
        {
            LuaManager luaMgr = GameWorld.Inst.LuaManager;
            if (luaMgr == null) return;

            string luafilePath = luaFile.Replace(".", "/");
            LuaTable luaCls = luaMgr.DoFile<LuaTable>(luafilePath);
            LuaFunction createFunc = luaCls.GetLuaFunction("create");

            if (createFunc == null)
            {
                LogWarning(string.Format("can't create lua object by filename:{0}", luaFile));
                return;
            }
            else
            {
                createFunc.BeginPCall();
                createFunc.Push(luaCls);
                createFunc.PushArgs(args);
                createFunc.PCall();
                createFunc.EndPCall();

                return;
            }
        }
        /// <summary>
        /// 检查运行环境
        /// </summary>
        public static bool CheckEnvironment()
        {
#if UNITY_EDITOR
            int resultId = Util.CheckRuntimeFile();
            if (resultId == -1)
            {
                Debug.LogError("没有找到框架所需要的资源，单击Game菜单下Build xxx Resource生成！！");
                EditorApplication.isPlaying = false;
                return false;
            }
            else if (resultId == -2)
            {
                Debug.LogError("没有找到Wrap脚本缓存，单击Lua菜单下Gen Lua Wrap Files生成脚本！！");
                EditorApplication.isPlaying = false;
                return false;
            }
#endif
            return true;
        }

        public static string CreateMD5Str(string content)
        {
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] result = md5.ComputeHash(Encoding.ASCII.GetBytes(content));
            return Encoding.ASCII.GetString(result);
        }
        /// 加密  
        /// </summary>  
        /// <param name="SourceText">需要加密的原字符串</param>  
        /// <param name="key">秘钥</param>  
        /// <returns></returns>  
        public static byte[] DESEncrypt(byte[] SourceText)
        {
            byte[] byteSignal = getDESCSignal();
            int signalSize = byteSignal.Length;

            if (checkSignHead(SourceText, byteSignal))
            {
                return SourceText;
            }

            //实现一个加密服务的类的对象，这个类提供了DES加密算法  
            DESCryptoServiceProvider desProvider = getDescProvider();

            //因为加密内容有可能包含汉字，所以用UTF8格式，将加密的字符串保存在字节数组里  
            byte[] inputBytesArray = SourceText;

            //实现一个内存流写入加密后的数据  
            MemoryStream memoryStream = new MemoryStream();

            //实现一个加密转换流，其中包含要将加密后的内容写入的内存流对象，用DESCrytoServiceProvider创建的加密器，模式为写入数据  
            CryptoStream cryptoStream = new CryptoStream(memoryStream, desProvider.CreateEncryptor(), CryptoStreamMode.Write);

            //将需要加密的字符串通过加密流写入到内存流中  
            cryptoStream.Write(inputBytesArray, 0, inputBytesArray.Length);

            //更新内存流存储块，然后清除缓存  
            cryptoStream.FlushFinalBlock();

            //用来将加密后的数据填充为一个字符串返回 
            List<byte> byteSource = new List<byte>();
            byteSource.AddRange(memoryStream.ToArray());
            byteSource.AddRange(byteSignal);

            return byteSource.ToArray();
        }

        static byte[] getDESCSignal()
        {
            if (s_DESSignale == null)
            {
                s_DESSignale = System.Text.Encoding.UTF8.GetBytes(AppConst.DESSignal);
            }

            return s_DESSignale;
        }


        static bool checkSignHead(byte[] source, byte[] byteSignal)
        {
            int signalSize = byteSignal.Length;
            int sourceSize = source.Length;
            if (sourceSize < signalSize)
                return false;

            int sourceIndex = sourceSize - signalSize;

            for (int i = 0; i < signalSize; i++)
            {
                if (source[sourceIndex + i] != byteSignal[i])
                {
                    return false;
                }
            }

            return true;
        }

        static DESCryptoServiceProvider getDescProvider()
        {
            if (null == s_DESCProvider)
            {
                string key = LuaFramework.Util.CreateMD5Str(LuaFramework.AppConst.LuaDESKey).Substring(0, 8); ;
                s_DESCProvider = new DESCryptoServiceProvider();
                s_DESCProvider.Key = ASCIIEncoding.ASCII.GetBytes(key);
                s_DESCProvider.IV = ASCIIEncoding.ASCII.GetBytes(key);
                s_DESCProvider.Padding = PaddingMode.ANSIX923;
            }

            return s_DESCProvider;
        }

        /// <summary>  
        /// 解密  
        /// </summary>  
        /// <param name="DecryptText">需要解密的字符串</param>  
        /// <param name="sKey">秘钥</param>  
        /// <returns></returns>  
        public static byte[] DESDecrypt(byte[] DecryptText)
        {
            byte[] byteSignal = getDESCSignal();
            int signalSize = byteSignal.Length;

            if (!checkSignHead(DecryptText, byteSignal))
            {
                return DecryptText;
            }

            //实现一个加密服务的类的对象，这个类提供了DES加密算法  
            DESCryptoServiceProvider des = getDescProvider();

            //实现一个二进制数组保存将需要解密的字符转换为二进制后的数据，因为加密后的数据用16位字符保存，所以定义的大小为源字符串一半  
            byte[] inputByteArray = DecryptText;
            //用来存储解密内容的内存流  
            MemoryStream ms = new MemoryStream();

            //加密转换流  
            CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(), CryptoStreamMode.Write);

            //转换后写入数据  
            cs.Write(inputByteArray, 0, inputByteArray.Length - signalSize);

            //更新存储，清理缓存  
            cs.FlushFinalBlock();
            StringBuilder ret = new StringBuilder();

            return ms.ToArray();
        }
    }
}
