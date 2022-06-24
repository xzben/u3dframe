using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Networking;

namespace LuaFramework
{
    public class AssetBundleHelper
    {
        private AssetBundleManifest m_AssetBundleManifest = null;
        // 缓存包依赖，不用每次计算
        public Dictionary<string, string[]> DependenciesCache = new Dictionary<string, string[]>();

        public AssetBundleHelper( AssetBundleManifest manifest)
        {
            this.m_AssetBundleManifest = manifest;
        }
        
        public string[] GetSortedDependencies(string assetBundleName)
        {
            Dictionary<string, int> info = new Dictionary<string, int>();
            List<string> parents = new List<string>();
            CollectDependencies(parents, assetBundleName, info);
            string[] ss = info.OrderBy(x => x.Value).Select(x => x.Key).ToArray();
            return ss;
        }
        public void CollectDependencies(List<string> parents, string assetBundleName, Dictionary<string, int> info)
        {
            parents.Add(assetBundleName);
            string[] deps = GetDependencies(assetBundleName);
            foreach (string parent in parents)
            {
                if (!info.ContainsKey(parent))
                {
                    info[parent] = 0;
                }
                info[parent] += deps.Length;
            }


            foreach (string dep in deps)
            {
                if (parents.Contains(dep))
                {
                    throw new Exception($"包有循环依赖，请重新标记: {assetBundleName} {dep}");
                }
                CollectDependencies(parents, dep, info);
            }
            parents.RemoveAt(parents.Count - 1);
        }
        public string[] GetDependencies(string assetBundleName)
        {
            string[] dependencies = new string[0];
            if (DependenciesCache.TryGetValue(assetBundleName, out dependencies))
            {
                return dependencies;
            }
            dependencies = m_AssetBundleManifest.GetAllDependencies(assetBundleName);
            DependenciesCache.Add(assetBundleName, dependencies);
            return dependencies;
        }
    }

    public class ABInfo
    {
        public string Name { get; set; }
        public int RefCount { get; set; }

        public AssetBundle m_assetBundle;

        public void Dispose()
        {
            if (this.m_assetBundle != null)
            {
                this.m_assetBundle.Unload(true);
            }
            this.RefCount = 0;
            this.Name = "";
        }
    }


    public class ResourceManager : Manager
    {
        string m_basePathSyn;
        string m_basePath;
        private AssetBundleHelper m_assetBundleHelper = null;
        private readonly Dictionary<string, Dictionary<string, UnityEngine.Object>> m_resourceCache = new Dictionary<string, Dictionary<string, UnityEngine.Object>>();
        public Dictionary<string, ABInfo> m_bundles = new Dictionary<string, ABInfo>();

        private static ResourceManager s_instance = null;
        public static ResourceManager Inst
        {
            get
            {
                if(s_instance == null)
                {
                    GameObject go = new GameObject("ResourceManager");
                    DontDestroyOnLoad(go);
                    s_instance = go.AddComponent<ResourceManager>();
                }
                return s_instance;
            }
        }

        public void Init()
        {
            if (!Application.isEditor || !AppConst.DebugMode)
            {
                AssetBundle assetbundle = null;
                if (Application.platform == RuntimePlatform.Android)
                {
                    m_basePath = GameManager.getWriteablePath() + "/res/current/running/AssetBundles/Android/";
                    assetbundle = AssetBundle.LoadFromFile(m_basePath + "Android");
                }
                else if (Application.platform == RuntimePlatform.IPhonePlayer)
                {
                    m_basePath = GameManager.getWriteablePath() + "/res/current/running/AssetBundles/iOS/";
                    assetbundle = AssetBundle.LoadFromFile(m_basePath + "iOS");
                }
                else if (Application.platform == RuntimePlatform.WindowsPlayer)
                {
                    m_basePath = GameManager.getWriteablePath() + "/res/current/running/AssetBundles/Win/";
                    assetbundle = AssetBundle.LoadFromFile(m_basePath + "Win");
                }
                else if( Application.platform == RuntimePlatform.WindowsEditor)
                {
                    m_basePath = GameManager.getWriteablePath() + "/res/current/running/AssetBundles/Win/";
                    assetbundle = AssetBundle.LoadFromFile(m_basePath + "Win");
                }

                m_basePathSyn = m_basePath;
                m_basePath = "file:///" + m_basePath;
                AssetBundleManifest manifest = assetbundle.LoadAllAssets()[0] as AssetBundleManifest;
                this.m_assetBundleHelper = new AssetBundleHelper(manifest);
                assetbundle.Unload(false);
            }
            
            Debug.Log("加载完毕");
        }

        //释放 bundle 引用 
        public void UnloadBundle(string assetBundleName)
        {
            if (Application.isEditor || AppConst.DebugMode) return;
            assetBundleName = assetBundleName.ToLower();
            string[] dependencies = this.m_assetBundleHelper.GetSortedDependencies(assetBundleName);
            foreach (string dependency in dependencies)
            {
                this.UnloadOneBundle(dependency);
            }
        }

        //强制卸载 bundle
        public void UnloadBundleWithStrong(string assetBundleName)
        {
            if (Application.isEditor || AppConst.DebugMode) return;
            assetBundleName = assetBundleName.ToLower();
            string[] dependencies = this.m_assetBundleHelper.GetSortedDependencies(assetBundleName);
            foreach (string dependency in dependencies)
            {
                string _ab_name = dependency.ToLower();

                ABInfo abInfo;
                if (!this.m_bundles.TryGetValue(_ab_name, out abInfo))
                {
                    Debug.Log($"not found assetBundle: {_ab_name}");
                }
                else
                {
                    this.UnloadOneBundle(dependency, abInfo.RefCount);
                }
            }
        }

        //释放bundle 包指定 count 的引用
        private void UnloadOneBundle(string assetBundleName, int count = 1)
        {
            assetBundleName = assetBundleName.ToLower();

            ABInfo abInfo;
            if (!this.m_bundles.TryGetValue(assetBundleName, out abInfo))
            {
                Debug.Log($"not found assetBundle: {assetBundleName}");
                return;
            }

            Debug.Log($"---------- unload one bundle {assetBundleName} refcount: {abInfo.RefCount - count}");

            abInfo.RefCount -= count;

            if (abInfo.RefCount > 0)
            {
                return;
            }

            this.m_bundles.Remove(assetBundleName);
            this.m_resourceCache.Remove(assetBundleName);
            abInfo.Dispose();
        }

        //编辑器缓存
        Dictionary<string, Dictionary<string, UnityEngine.Object>> editor_cache = new Dictionary<string, Dictionary<string, UnityEngine.Object>>();
        public UnityEngine.Object GetAsset(string bundleName, string prefab)
        {
            //Editor
            if (AppConst.DebugMode && (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.OSXEditor))
            {
#if UNITY_EDITOR
                if (!editor_cache.ContainsKey(bundleName))
                {
                    editor_cache[bundleName] = new Dictionary<string, UnityEngine.Object>();
                    List<UnityEngine.Object> fs = new List<UnityEngine.Object>();
                    string path = "Assets/Res/" + bundleName;
                    var withoutExtensions = new List<string>() {
                            ".txt",".xml",".json",".cs",".bytes",".spriteatlas",
                            ".prefab",".fbx",".controller",".ttf",".unity",".mat",".shader",".asset",".physicmaterial",".exr",".fontsettings",".rendertexture",".anim",".otf",
                            ".bmp",".jpg",".png",".tga",
                            ".aiff",".wav",".mp3",".ogg" };
                    string[] files = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories)
                                    .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
                    for (int i = 0; i < files.Length; i++)
                    {
                        string p = files[i].Replace("\\", "/");
                        FileInfo f = new FileInfo(p);
                        editor_cache[bundleName][Path.GetFileNameWithoutExtension(f.Name)] = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(p);
                    }
                }
                return editor_cache[bundleName][prefab];
#endif
            }

            Dictionary<string, UnityEngine.Object> dict;
            if (!this.m_resourceCache.TryGetValue(bundleName.ToLower(), out dict))
            {
                throw new Exception($"not found asset: {bundleName} {prefab}");
            }

            UnityEngine.Object resource = null;
            if (!dict.TryGetValue(prefab, out resource))
            {
                throw new Exception($"not found asset: {bundleName} {prefab}");
            }

            return resource;
        }

        public void AddResource(string bundleName, string assetName, UnityEngine.Object resource)
        {
            Dictionary<string, UnityEngine.Object> dict;
            if (!this.m_resourceCache.TryGetValue(bundleName.ToLower(), out dict))
            {
                dict = new Dictionary<string, UnityEngine.Object>();
                this.m_resourceCache[bundleName] = dict;
            }

            dict[assetName] = resource;
        }
        /// <summary>
        /// 异步加载一个AB包列表
        /// </summary>
        public void LoadBundleListAsync(string[] assetBundleNames, Action callback)
        {
            StartCoroutine(_LoadBundleListAsync(assetBundleNames, callback));
        }
        IEnumerator _LoadBundleListAsync(string[] assetBundleNames, Action callback)
        {
            yield return new WaitForEndOfFrame();
            //Editor
            if (!AppConst.DebugMode && (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.OSXEditor))
            {
                if (callback != null)
                {
                    callback();
                }
                yield break;
            }

            Dictionary<string, bool> dic = new Dictionary<string, bool>();
            for (int i = 0; i < assetBundleNames.Length; i++)
            {
                string assetBundleName = assetBundleNames[i].ToLower();
                string[] dependencies = this.m_assetBundleHelper.GetSortedDependencies(assetBundleName);
                foreach (string dependency in dependencies)
                {
                    if (string.IsNullOrEmpty(dependency))
                    {
                        continue;
                    }
                    if (!dic.ContainsKey(dependency))
                    {
                        dic[dependency] = true;
                    }
                }
            }

            List<string> dependencie_list = new List<string>(dic.Keys.ToArray());
            for (int i = 0; i < dependencie_list.Count; i++)
            {
                yield return StartCoroutine(_LoadOneBundleAsync(dependencie_list[i]));
            }
            if (callback != null)
            {
                callback();
            }
        }


        /// <summary>
        /// 异步加载一个AB包
        /// </summary>
        public void LoadBundleAsync(string assetBundleName, Action callback)
        {
            StartCoroutine(_LoadBundleAsync(assetBundleName, callback));
        }
        IEnumerator _LoadBundleAsync(string assetBundleName, Action callback)
        {
            yield return new WaitForEndOfFrame();
            //Editor
            if (AppConst.DebugMode && (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.OSXEditor))
            {
                if (callback != null)
                {
                    callback();
                }
                yield break;
            }

            assetBundleName = assetBundleName.ToLower();
            string[] dependencies = this.m_assetBundleHelper.GetSortedDependencies(assetBundleName);
            foreach (string dependency in dependencies)
            {
                if (string.IsNullOrEmpty(dependency))
                {
                    continue;
                }
                yield return StartCoroutine(_LoadOneBundleAsync(dependency));
            }
            if (callback != null)
            {
                callback();
            }
        }
        IEnumerator _LoadOneBundleAsync(string assetBundleName)
        {
            yield return new WaitForEndOfFrame();
            ABInfo abInfo;
            if (this.m_bundles.TryGetValue(assetBundleName, out abInfo))
            {
                ++abInfo.RefCount;
                yield break;
            }

            using (UnityWebRequest request = UnityWebRequestAssetBundle.GetAssetBundle(m_basePath + assetBundleName))
            {
                yield return request.SendWebRequest();

                if (request.isNetworkError || request.isHttpError)
                {
                    Debug.Log(request.error);
                    Debug.Log(string.Format("加载ab:{0}失败:{1}", m_basePath + assetBundleName, request.error));
                    throw new Exception($"assets bundle not found: {assetBundleName}");
                }
                else
                {

                    AssetBundle bundle = DownloadHandlerAssetBundle.GetContent(request);
                    abInfo = new ABInfo();
                    abInfo.m_assetBundle = bundle;
                    abInfo.Name = assetBundleName;
                    abInfo.RefCount++;
                    this.m_bundles[assetBundleName] = abInfo;

                    AssetBundleRequest assetBundleRequest = bundle.LoadAllAssetsAsync();
                    yield return assetBundleRequest;
                    UnityEngine.Object[] assets = assetBundleRequest.allAssets;
                    foreach (UnityEngine.Object asset in assets)
                    {
                        AddResource(assetBundleName, asset.name, asset);
                    }

                }
            }
        }

        public ABInfo LoadBundle(string assetBundleName)
        {
            //Editor
            if (AppConst.DebugMode && (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.OSXEditor))
            {
                return null;
            }
            assetBundleName = assetBundleName.ToLower();
            string[] dependencies = this.m_assetBundleHelper.GetSortedDependencies(assetBundleName);

            ABInfo mainBundle = null;

            foreach (string dependency in dependencies)
            {
                if (string.IsNullOrEmpty(dependency))
                {
                    continue;
                }
                ABInfo info = _LoadOneBundle(dependency);

                if(info.Name == assetBundleName)
                {
                    mainBundle = info;
                }
            }

            return mainBundle;
        }

        ABInfo _LoadOneBundle(string assetBundleName)
        {

            ABInfo abInfo;
            if (this.m_bundles.TryGetValue(assetBundleName, out abInfo))
            {
                ++abInfo.RefCount;
                return abInfo;
            }

            string _p = m_basePathSyn + assetBundleName;
            AssetBundle bundle = AssetBundle.LoadFromFile(_p);

            abInfo = new ABInfo();
            abInfo.m_assetBundle = bundle;
            abInfo.Name = assetBundleName;
            abInfo.RefCount++;
            this.m_bundles[assetBundleName] = abInfo;

            UnityEngine.Object[] assets = bundle.LoadAllAssets();
            foreach (UnityEngine.Object asset in assets)
            {
                AddResource(assetBundleName, asset.name, asset);
            }

            return abInfo;
        }

        public void clearAllLoadedAssetBundles()
        {
            foreach( string key in this.m_bundles.Keys)
            {
                ABInfo info = this.m_bundles[key];
                info.Dispose();
            }
            this.m_bundles.Clear();
            this.m_resourceCache.Clear();
        }

        static string editor_path = "Assets/Res/";
        //给lua用的，在UnityEditor模式下，load resource
        public UnityEngine.Object luaEditorLoadRes(string assetPath, Type type)
        {
#if UNITY_EDITOR
            return AssetDatabase.LoadAssetAtPath(editor_path + assetPath, type);
#else
        return null;
#endif
        }
    }

}
