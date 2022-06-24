using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using System;
using UnityEngine.SceneManagement;

namespace LuaFramework
{
    public class LuaManager : Manager
    {
        private LuaState m_luaState = null;

        private LuaLooper m_loop = null;

        private LuaLoader m_loader = null;


        void restart()
        {
            this.Close();
            m_loader = new LuaLoader();
            m_luaState= new LuaState();
            this.OpenLibs();
            m_luaState.LuaSetTop(0);

            LuaBinder.Bind(m_luaState);
            DelegateFactory.Init();
            LuaCoroutine.Register(m_luaState, this);
        }

        public void InitStart()
        {
            restart();
            InitLuaPath();
            this.m_luaState.Start();    //启动LUAVM
            this.StartMain();
            this.StartLooper();
        }

        void StartLooper()
        {
            m_loop = gameObject.AddComponent<LuaLooper>();
            m_loop.luaState = m_luaState;
        }

        //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
        protected void OpenCJson()
        {
            m_luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            m_luaState.OpenLibs(LuaDLL.luaopen_cjson);
            m_luaState.LuaSetField(-2, "cjson");

            m_luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
            m_luaState.LuaSetField(-2, "cjson.safe");
        }

        void StartMain()
        {
            m_luaState.DoFile("Main.lua");
            LuaFunction main = GetFunction("Main");
            main.Call();
            main.Dispose();
            main = null;
        }


        public LuaFunction GetFunction( string name)
        {
            return this.m_luaState.GetFunction(name);
        }

        void OpenLibs()
        {
            m_luaState.OpenLibs(LuaDLL.luaopen_protobuf_c);
            m_luaState.OpenLibs(LuaDLL.luaopen_pb);
            m_luaState.OpenLibs(LuaDLL.luaopen_lpeg);
            m_luaState.OpenLibs(LuaDLL.luaopen_bit);
            m_luaState.OpenLibs(LuaDLL.luaopen_socket_core);

            this.OpenCJson();
            this.OpenLuaSocket();
        }

        void OpenLuaSocket()
        {
            LuaConst.openLuaSocket = true;

            m_luaState.BeginPreLoad();
            m_luaState.RegFunction("socket.core", LuaOpen_Socket_Core);
            m_luaState.EndPreLoad();
        }

        void InitLuaPath()
        {
#if !UNITY_EDITOR
            string rootPath = UpdateManager.getLuaRoot();
            m_luaState.AddSearchPath(rootPath + "/Lua");
            m_luaState.AddSearchPath(rootPath + "/ToLua/Lua");
#endif
        }

        public bool AddBoundle(string bundleName)
        {
            return m_loader.AddBundle(bundleName);
        }

        public void DoFile(string filename)
        {
            m_luaState.DoFile(filename);
        }

        public T LuaLoadBuffer<T>(byte[] bytes, string filename)
        {
            return m_luaState.LuaLoadBuffer<T>(bytes, filename);
        }

        public T DoFile<T>(string fileName)
        {
            return m_luaState.DoFile<T>(fileName);
        }

        public T CheckValue<T>(int pos)
        {
            return m_luaState.CheckValue<T>(pos);
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        // Update is called once per frame
        public object[] CallFunction(string funcName, params object[] args)
        {
            LuaFunction func = m_luaState.GetFunction(funcName);
            if (func != null)
            {
                return func.LazyCall(args);
            }
            return null;
        }

        public void LuaGC()
        {
            m_luaState.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }

        public void Close()
        {
            if (m_loop != null)
            {
                m_loop.Destroy();
                m_loop = null;
            }

            if (m_luaState != null)
            {
                m_luaState.Dispose();
                m_luaState = null;
            }

            if (m_loader != null)
            {
                m_loader = null;
            }

        }
    }
}