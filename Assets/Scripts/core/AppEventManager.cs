using LuaInterface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine.SceneManagement;

namespace LuaFramework
{
    public class AppEventManager : Manager
    {
        protected LuaFunction m_levelLoaded = null;
        protected LuaFunction m_socketEvent = null;
        protected LuaFunction m_platformEvent = null;

        private void Awake()
        {
            SceneManager.sceneLoaded += OnSceneLoaded;
        }

        private void OnDestroy()
        {
            SceneManager.sceneLoaded -= OnSceneLoaded;
        }

        public void Init()
        {
            m_levelLoaded = LuaManager.GetFunction("OnLevelWasLoaded");
            m_socketEvent = LuaManager.GetFunction("OnSocketEvent");
            m_platformEvent = LuaManager.GetFunction("onPlatformEvent");
        }

        public void clear()
        {
            m_levelLoaded = null;
            m_socketEvent = null;
            m_platformEvent = null;
        }

        void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            OnLevelLoaded(scene.buildIndex, scene.name);
        }


        public void OnSocketEvent( int evt, ByteBuffer msg)
        {
            if(m_socketEvent != null)
            {
                m_socketEvent.BeginPCall();
                m_socketEvent.Push(evt);
                m_socketEvent.Push(msg);
                m_socketEvent.PCall();
                m_socketEvent.EndPCall();
            }
        }

        public void OnLevelLoaded(int level, string name)
        {
            if (m_levelLoaded != null)
            {
                m_levelLoaded.BeginPCall();
                m_levelLoaded.Push(level);
                m_levelLoaded.Push(name);
                m_levelLoaded.PCall();
                m_levelLoaded.EndPCall();
            }
        }

        public void OnPlatformEvent(string msg)
        {
            if (m_platformEvent != null)
            {
                m_platformEvent.BeginPCall();
                m_platformEvent.Push(msg);
                m_platformEvent.PCall();
                m_platformEvent.EndPCall();
            }
        }
    }
}
