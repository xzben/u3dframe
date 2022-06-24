using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using LuaInterface;
using System.Reflection;
using System.IO;
using UnityEngine.Networking;

namespace LuaFramework {
    class GameStartParam
    {
        public bool needRemoveOldCode = false;
        public string writeablepath = "";
    };

    public class GameManager : Manager
    {
        private string m_writeablePath = "";

        private GameStartParam checkStartParams()
        {
            GameStartParam param = new GameStartParam();
            string[] CommandLineArgs = Environment.GetCommandLineArgs();
            int size = CommandLineArgs.Length;
            Debug.Log("checkStartParams len:" + CommandLineArgs.Length);

            string content = "";
            
            for (int i = 0; i < size; i++)
            {
                
                string argc = CommandLineArgs[i];
                content += argc + "  ";

                if (argc == "deleteLuaAndRes")
                {
                    param.needRemoveOldCode = true;
                }
                else if (argc == "-writeablepath" && i + 1 < size)
                {
                    param.writeablepath = CommandLineArgs[i + 1];
                    content += CommandLineArgs[i + 1] + " ";
                    i++;
                }
            }

            Debug.Log("checkStartParams content:" + content);

            return param;
        }

        public void checkSetGameStartParams()
        {
#if UNITY_STANDALONE
            //注意这段逻辑一定要在 folder 对象new之前执行，否则writeable path会不生效
            GameStartParam param = checkStartParams();

            if (param.writeablepath != "")
            {
                if (!Directory.Exists(param.writeablepath))
                {
                    Directory.CreateDirectory(param.writeablepath);
                }
                this.m_writeablePath = param.writeablepath;
            }

            if (param.needRemoveOldCode)
                deleteLuaAndRes();
#endif
        }

        private void deleteLuaAndRes()
        {
            string baseDir = this.m_writeablePath;
            string binPath = baseDir + "/bins";
            string resPath = baseDir + "res";

            if (System.IO.Directory.Exists(binPath))
            {
                FileTools.FolderDelete(binPath);
            }

            if (System.IO.Directory.Exists(resPath))
            {
                FileTools.FolderDelete(resPath);
            }
        }

        public int getPlatfromType()
        {
            return PlatformManager.getPlatfromType();
        }

        public string getWriteablePath()
        {
#if UNITY_STANDALONE
            if (m_writeablePath != "")
                return m_writeablePath;
            else
                return UnityEngine.Application.persistentDataPath;
#else
            return UnityEngine.Application.persistentDataPath;
#endif
        }
    }
}


