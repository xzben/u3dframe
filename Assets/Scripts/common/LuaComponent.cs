using UnityEngine;
using System.Collections;
using LuaInterface;

namespace LuaFramework
{
    public class LuaComponent : MonoBehaviour
    {
        private LuaTable m_self = null;
        private LuaFunction m_start = null;
        private LuaFunction m_update = null;
        private LuaFunction m_fixUpdate = null;
        private LuaFunction m_destroy = null;

        public string luaFilePath = "";
        public GameObject[] nodes;

        public void reset(LuaTable table, LuaFunction start, LuaFunction destroy, LuaFunction update = null, LuaFunction fixUpdate = null)
        {
            m_self = table;
            m_start = start;
            m_destroy = destroy;
            m_update = update;
            m_fixUpdate = fixUpdate;
        }

        public LuaTable getNodeInfo(LuaTable table)
        {
            if (nodes == null) return table;
            for (int i = 0; i < nodes.Length; i++)
            {
                GameObject node = nodes[i];
                table.SetTable(node.name, node);
            }

            return table;
        }

        public LuaTable getLuaObject()
        {
            return m_self;
        }

        void createLuaObj()
        {
            if (luaFilePath != "")
                LuaFramework.Util.createLuaObject(luaFilePath, gameObject);
        }

        void Awake()
        {
            createLuaObj();
        }

        // Use this for initialization
        void Start()
        {
            if (m_start != null)
            {
                m_start.BeginPCall();
                m_start.Push(m_self);
                m_start.PCall();
                m_start.EndPCall();
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (m_update != null)
            {
                m_update.BeginPCall();
                m_update.Push(m_self);
                m_update.Push(Time.deltaTime);
                m_update.PCall();
                m_update.EndPCall();
            }
        }

        void FixedUpdate()
        {
            if (m_fixUpdate != null)
            {
                m_fixUpdate.BeginPCall();
                m_fixUpdate.Push(m_self);
                m_fixUpdate.Push(Time.fixedTime);
                m_fixUpdate.PCall();
                m_fixUpdate.EndPCall();
            }
        }

        void OnDestroy()
        {
            if (m_destroy != null)
            {
                m_destroy.BeginPCall();
                m_destroy.Push(m_self);
                m_destroy.PCall();
                m_destroy.EndPCall();
            }
        }
    }
}