using UnityEngine;

namespace LuaFramework
{
    public class Base : MonoBehaviour
    {
        private LuaManager m_luaMgr;
        private ResourceManager m_resMgr;
        private NetworkManager m_netMgr;
        private GameManager m_gameMgr;
        private UpdateManager m_updateMgr;
        private AppEventManager m_eventMgr;
        private PlatformManager m_platformMgr;

        public AppEventManager AppEventManager 
        {
            get
            {
                if(m_eventMgr == null)
                {
                    m_eventMgr = GameWorld.Inst.getManager<AppEventManager>(ManagerName.Event);
                }

                return m_eventMgr;
            }
        }

        public UpdateManager UpdateManager
        {
            get
            {
                if(m_updateMgr == null)
                {
                    m_updateMgr = GameWorld.Inst.getManager<UpdateManager>(ManagerName.Update);
                }
                return m_updateMgr;
            }
        }

        public LuaManager LuaManager
        {
            get
            {
                if(m_luaMgr == null)
                {
                    m_luaMgr = GameWorld.Inst.getManager<LuaManager>(ManagerName.Lua);
                }
                return m_luaMgr;
            }
        }

        public ResourceManager ResourceManager
        {
            get
            {
                if(m_resMgr == null)
                {
                    m_resMgr = GameWorld.Inst.getManager<ResourceManager>(ManagerName.Resource);
                }

                return m_resMgr;
            }
        }

        public NetworkManager NetworkManager
        {
            get
            {
                if (m_netMgr == null)
                {
                    m_netMgr = GameWorld.Inst.getManager<NetworkManager>(ManagerName.Network);
                }

                return m_netMgr;
            }
        }

        public GameManager GameManager
        {
            get
            {
                if (m_gameMgr == null)
                {
                    m_gameMgr = GameWorld.Inst.getManager<GameManager>(ManagerName.Game);
                }

                return m_gameMgr;
            }
        }

        public PlatformManager PlatformManager
        {
            get
            {
                if (m_platformMgr == null)
                {
                    m_platformMgr = GameWorld.Inst.getManager<PlatformManager>(ManagerName.platform);
                }

                return m_platformMgr;
            }
        }

        public GameWorld GameWorld
        {
            get
            {
                return GameWorld.Inst;
            }
        }
    }
}
