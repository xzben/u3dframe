using UnityEngine;
using System.Collections;
using System.IO;
using LuaInterface;

namespace LuaFramework {
    /// <summary>
    /// 集成自LuaFileUtils，重写里面的ReadFile，
    /// </summary>
    public class LuaLoader : LuaFileUtils {
        private ResourceManager m_resMgr;

        ResourceManager resMgr {
            get { 
                if (m_resMgr == null)
                    m_resMgr = ResourceManager.Inst;
                return m_resMgr;
            }
        }

        public LuaLoader() {
            instance = this;
            beZip = AppConst.LuaBundleMode;
        }

 
        public bool AddBundle(string bundleName) {
            string url = Util.DataPath + bundleName.ToLower();
            if (File.Exists(url)) {
				Debug.Log("AddBundle--->>>" + url);
                var bytes = File.ReadAllBytes(url);
                AssetBundle bundle = AssetBundle.LoadFromMemory(bytes);
                if (bundle != null)
                {
                    bundleName = bundleName.Replace("lua/", "").Replace(".unity3d", "");
                    base.AddSearchBundle(bundleName.ToLower(), bundle);

                    return true;
                }
            }

            return false;
        }

        public override byte[] ReadFile(string fileName) {
            byte[] outContent = base.ReadFile(fileName);

            return LuaFramework.Util.DESDecrypt(outContent);
        }
    }
}