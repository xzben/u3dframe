using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LuaFramework
{
    public class GameWorld : Base
    {
        Dictionary<string, object> m_managers = new Dictionary<string, object>();
        private static GameWorld s_instance = null;


        public UnityEngine.UI.Image m_process = null;
        public UnityEngine.UI.Text m_tips = null;

        public static GameWorld Inst
        {
            get
            {
                if (s_instance == null)
                {
                    GameObject go = new GameObject("GameWorld");
                    s_instance = go.AddComponent<GameWorld>();
                }

                return s_instance;
            }
        }

        public void addManager(string typeName, object obj)
        {
            if (!m_managers.ContainsKey(typeName))
            {
                m_managers.Add(typeName, obj);
            }
        }

        public T addManager<T>(string typeName) where T : Component
        {
            object result = null;

            this.m_managers.TryGetValue(typeName, out result);

            if (result != null)
            {
                return (T)result;
            }

            Component c = this.gameObject.AddComponent<T>();

            this.m_managers.Add(typeName, c);

            return default(T);

        }

        public T getManager<T>(string typeName) where T : class
        {
            if (!m_managers.ContainsKey(typeName))
            {
                return default(T);
            }
            object manager = null;
            m_managers.TryGetValue(typeName, out manager);
            return (T)manager;
        }

        public void removeManager(string typeName)
        {
            if (!m_managers.ContainsKey(typeName))
            {
                return;
            }
            object manager = null;
            m_managers.TryGetValue(typeName, out manager);
            Type type = manager.GetType();
            if (type.IsSubclassOf(typeof(MonoBehaviour)))
            {
                GameObject.Destroy((Component)manager);
            }
            m_managers.Remove(typeName);
        }

        private void initManager()
        {
            this.addManager<LuaManager>(ManagerName.Lua);
           
            this.addManager<NetworkManager>(ManagerName.Network);
            this.addManager<UpdateManager>(ManagerName.Update);
            this.addManager<AppEventManager>(ManagerName.Event);
            this.addManager<GameManager>(ManagerName.Game);
            this.addManager<PlatformManager>(ManagerName.platform);
            this.addManager(ManagerName.Resource, ResourceManager.Inst);
            
        }

        // Start is called before the first frame update
        void Start()
        {
            GameWorld.s_instance = this;
            DontDestroyOnLoad(this.gameObject);
            this.initManager();

            GameManager.checkSetGameStartParams();
            StartCoroutine(delayLoad());
        }

        public void restartGame()
        {
            NetworkManager.Reset();
            ResourceManager.clearAllLoadedAssetBundles();
            AppEventManager.clear();
            LuaManager.InitStart();
            ResourceManager.Init();
            UpdateManager.Init();
            AppEventManager.Init();
            UnityEngine.SceneManagement.SceneManager.LoadScene("miniload", UnityEngine.SceneManagement.LoadSceneMode.Single);
        }

        private void updateProcess(float process, string tips)
        {
            this.m_process.fillAmount = process;
            this.m_tips.text = tips;
        }

        IEnumerator delayLoad()
        {
            UpdateManager.Init();

            this.updateProcess(0, "");

            yield return UpdateManager.checkExtactResource(delegate(int status, int cursize, int total)
            {
                float process = 0;
                string tips = "";   

                switch ((UPDATE_STATUS)status)
                {
                    case UPDATE_STATUS.EXTRACT_LUA:
                    case UPDATE_STATUS.EXTRACT_INSTALL_LUA:
                        {
                            tips = "Lua安装";
                            break;
                        }
                    case UPDATE_STATUS.EXTRACT_RES:
                    case UPDATE_STATUS.EXTRACT_INSTALL_RES:
                        {
                            tips = "Res安装";
                            break;
                        }
                }

                if (total > 0)
                {
                    process = (float)cursize / total;
                    tips += cursize + "/" + total;
                }
                UnityEngine.Debug.Log("process cursize" + cursize+ " total " + total + " "+ + process);
                this.updateProcess(process, tips);
            });

            ResourceManager.Init();
            LuaManager.InitStart();
            AppEventManager.Init();
            AppEventManager.OnLevelLoaded(0, "miniload");
        }
    }
}
