using LuaInterface;
using System;
using System.Collections;
using System.IO;
using System.IO.Compression;
using UnityEngine;
using UnityEngine.Networking;

namespace LuaFramework
{
    public enum UPDATE_STATUS
    {
        EXTRACT_LUA, //copy 安装包中lua 压缩文件到安装目录
        EXTRACT_INSTALL_LUA, //解压安装 lua 代码到运行目录
        EXTRACT_INSTALL_LUA_DONE, // 安装 lua 代码完成
        EXTRACT_RES, // copy res压缩包到安装目录
        EXTRACT_INSTALL_RES, //解压安装 res 资源到运行目录
        EXTRACT_INSTALL_RES_DONE, // 安装res 资源完成
    }

    public enum ERROR_CODE
    {
        //无版本文件，需要 COPY 文件，新装
        NO_CURR_VER_FILE = -1,
        //当前版本文件格式错误
        CURR_VER_FILE_FORMAT_ERROR = -2,
        //升级版本文件格式错误
        UPDATE_VER_FILE_FORMAT_ERROR = -3,
        //当前版本大于要升级的版本
        CURR_BIGGER = -4,
        //没有初始化
        ERROR_NOT_INIT = -5,
        //初始化参数错误
        INIT_PARA_ERROR = -6,
        //

        //COPY LUA EXCEPTION
        LUA_EXCEPTION_1 = -100,
        LUA_EXCEPTION_2 = -101,
        LUA_EXCEPTION_3 = -102,
        LUA_EXCEPTION_4 = -103,
        LUA_EXCEPTION_5 = -104,

    };


    /*
        bins --代码路径
            preload
                loading --下载文件目录
                unzip --解压目录
                forupdate --校验后需要更新的文件
            current
                versionfiles --版本文件目录
                running --目前正在运行的版本
            backup
                versions
                    1 -- 旧版本，用于回滚
                    2 -- 旧版本，用于回滚
                    ...
        res --资源路径
            preload
                loading --下载资源路径
                unzip --解压后的资源路径
                forupdate --校验后需要更新的资源
            current
                versionfiles --版本文件目录
                running --目前正在运行的版本
            backup
                versionfiles
                    1 --旧版本
                    2 --旧版本
                    ...
    */

    public class UpdateManager : Manager
    {
        //基础路径
        private string m_writepath = "";
        //lua版本
        private string m_packageVersion = null;
        private string m_localVersion = null;

        //基础版本控制文件
        string m_localVerFilePath = "";

        //lua 根路径
        string m_luaRoot = "";
        //AssetBundles 根目录
        string m_assetRoot = "";

        public void Init()
        {
            this.m_writepath = GameManager.getWriteablePath();
            this.m_localVersion = null;
            this.InitDir();
        }

        public string getPackageVersion()
        {
            if (this.m_packageVersion == null)
            {
                TextAsset luaVersionAsset = Resources.Load<TextAsset>("VersionStamp");
                this.m_packageVersion = luaVersionAsset.text;
                Resources.UnloadAsset(luaVersionAsset);
            }

            return this.m_packageVersion;
        }

        public string getLocalVersion()
        {
            if (this.m_localVersion == null)
            {
                this.m_localVersion = "0.0.0.0";
                if (FileTools.FileExists(this.m_localVerFilePath))
                {
                    this.m_localVersion = File.ReadAllText(m_localVerFilePath);
                }
            }


            return this.m_localVersion;
        }

        public string getLuaRoot()
        {
#if UNITY_EDITOR
            if (AppConst.DebugMode)
            {
                return m_luaRoot;
            }
            else
            {
                return System.IO.Path.Combine(Application.dataPath, "Lua", "myLua");
            }
            
#else
            return m_luaRoot;
#endif
        }

        private void InitDir()
        {
            makeDir(System.IO.Path.Combine(m_writepath, "update"));
            makeDir(System.IO.Path.Combine(m_writepath, "update", "loading"));
            makeDir(System.IO.Path.Combine(m_writepath, "update", "unzip"));

            //文件路径
            makeDir(System.IO.Path.Combine(m_writepath, "bins"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "preload"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "preload", "loading"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "preload", "unzip"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "preload", "forupdate"));

            makeDir(System.IO.Path.Combine(m_writepath, "bins", "current"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "current", "versionfiles"));
            makeDir(System.IO.Path.Combine(m_writepath, "bins", "current", "running"));

            //资源路径
            makeDir(System.IO.Path.Combine(m_writepath, "res"));
            makeDir(System.IO.Path.Combine(m_writepath, "res", "preload"));
            makeDir(System.IO.Path.Combine(m_writepath, "res", "preload", "loading"));
            makeDir(System.IO.Path.Combine(m_writepath, "res", "preload", "unzip"));
            makeDir(System.IO.Path.Combine(m_writepath, "res", "current"));
            makeDir(System.IO.Path.Combine(m_writepath, "res", "current", "running"));

            //基础版本控制文件
            m_localVerFilePath = System.IO.Path.Combine(m_writepath, "bins", "current", "versionfiles", "VersionStamp");

            //lua 根路径
            m_luaRoot = System.IO.Path.Combine(m_writepath, "bins", "current", "running", "myLua");

            //assetBundle 根目录
            m_assetRoot = System.IO.Path.Combine(m_writepath, "res", "current", "running", "AssetBundles");
        }

        public IEnumerator checkExtactResource(Action<int, int, int> process)
        {
            string packageVersion = this.getPackageVersion();
            string respath = Util.AppContentPath();
            string luafile = respath + "myLua.bytes";
            string bundlefile = respath + "AssetBundles.bytes";

            //需要从 Resource 包内扩展lua代码
            if (Util.compareVersion(this.getLocalVersion(), packageVersion) < 0)
            {
                process((int)UPDATE_STATUS.EXTRACT_LUA, 0, 0);
                //基础包压缩文件
                string zipLuaFilePath = System.IO.Path.Combine(m_writepath, "bins", "preload", "loading", "myLua.bytes");
                if(FileTools.FileExists(zipLuaFilePath))
                {
                    File.Delete(zipLuaFilePath);
                }
                string dir = Path.GetDirectoryName(zipLuaFilePath);
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }

                if (Application.platform == RuntimePlatform.Android)
                {
                    UnityWebRequest req = UnityWebRequest.Get(luafile);
                    yield return req.SendWebRequest();

                    Debug.Log("UPDATE_STATUS.EXTRACT_LUA " + luafile + " writepath :" + m_writepath + " done:" + req.isDone);
                    if (!req.isNetworkError && req.isDone)
                    {
                        File.WriteAllBytes(zipLuaFilePath, req.downloadHandler.data);
                    }
                    else
                    {
                        Debug.LogError("get file failed" + luafile + "error:" + req.error);
                    }
                    Debug.Log("UPDATE_STATUS.EXTRACT_LUA " + luafile);
                }
                else
                {
                    File.Copy(luafile, zipLuaFilePath, true);
                }
                yield return new WaitForEndOfFrame();

                Debug.Log("UPDATE_STATUS.EXTRACT_INSTALL_LUA");
                yield return InstallLuaFiles(zipLuaFilePath, true, delegate(){
                    Debug.Log("UPDATE_STATUS.EXTRACT_INSTALL_LUA 0");
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_LUA, 0, 0);
                }, delegate(int curzie, int totoal, string file) {
                    Debug.Log("UPDATE_STATUS.EXTRACT_INSTALL_LUA totoal:" + curzie + " totoal:" + totoal);
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_LUA, curzie, totoal);
                }, delegate() {
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_LUA_DONE, 0, 0);
                });
                
                // 安装 res
                string zipBundlesFilePath = System.IO.Path.Combine(m_writepath, "res", "preload", "loading", "AssetBundles.bytes");
                process((int)UPDATE_STATUS.EXTRACT_RES, 0, 0);
                if (Application.platform == RuntimePlatform.Android)
                {
                    UnityWebRequest req = UnityWebRequest.Get(bundlefile);
                    yield return req.SendWebRequest();

                    if (!req.isNetworkError && req.isDone)
                    {
                        File.WriteAllBytes(zipBundlesFilePath, req.downloadHandler.data);
                    }
                    else
                    {
                        Debug.LogError("get file failed" + bundlefile + "error:" + req.error);
                    }
                }
                else
                {
                    File.Copy(bundlefile, zipBundlesFilePath, true);
                }
                yield return this.InstallResFiles(zipBundlesFilePath, true, delegate() {
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_RES, 0, 0);
                }, delegate(int cursize, int totoal, string file) {
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_RES, cursize, totoal);
                }, delegate() {
                    process((int)UPDATE_STATUS.EXTRACT_INSTALL_RES_DONE, 0, 0);
                });

                File.WriteAllText(this.m_localVerFilePath, packageVersion);
            }
        }

        public void InstallUpdateZip(string zipfile, string version, Action funcStart = null, Action<float> funcProc = null, Action funcDone = null)
        {
            string unzippath = System.IO.Path.Combine(m_writepath, "update", "unzip");
            if (FileTools.DirectoryExists(unzippath))
            {
                Directory.Delete(unzippath, true);
                Directory.CreateDirectory(unzippath);
            }
            FileTools.ExtractToDirectory(zipfile, unzippath);

            StartCoroutine(IntallLuaRes(unzippath, version, funcStart, funcProc, funcDone));
        }

        private IEnumerator IntallLuaRes(string unzippath, string version, Action funcStart = null, Action<float> funcProc = null, Action funcDone = null)
        {
            string updateLuaFile = System.IO.Path.Combine(unzippath, "myLua.bytes");
            string updateResFile = System.IO.Path.Combine(unzippath, "AssetBundles.bytes");

            funcStart();

            if (FileTools.FileExists(updateLuaFile))
            {
                yield return InstallLuaFiles(updateLuaFile, false, delegate ()
                {
                    Debug.Log("Install lua file start");
                }, delegate (int cursize, int total, string filename)
                {
                    float percent = 0;
                    if(total > 0)
                    {
                        percent = (float)cursize / total;
                    }
                    else
                    {
                        percent = 1;
                    }

                    funcProc(percent*0.5f);
                    Debug.Log("Install lua file process cursize:" + cursize + "total:" + total + "filename:" + filename );
                }, delegate ()
                {
                    funcProc(0.5f);
                    Debug.Log("Install lua file finish");
                });
            }

            if (FileTools.FileExists(updateResFile))
            {
                yield return InstallResFiles(updateLuaFile, false, delegate ()
                {
                    Debug.Log("Install  res start");
                }, delegate (int cursize, int total, string filename)
                {
                    float percent = 0;
                    if (total > 0)
                    {
                        percent = (float)cursize / total;
                    }
                    else
                    {
                        percent = 1;
                    }
                    Debug.Log("Install res process cursize:" + cursize + "total:" + total + "filename:" + filename);

                    funcProc(0.5f + percent * 0.5f);
                }, delegate ()
                {
                    Debug.Log("Install res file finish");
                    funcProc(1f);
                });
            }

            funcDone();
            File.WriteAllText(this.m_localVerFilePath, version);
        }

        public IEnumerator InstallLuaFiles(string zipfile, bool unziptoDirect, Action funcStart = null, Action<int, int, string> funcProc = null, Action funcDone = null)
        {
            string unzippath = System.IO.Path.Combine(m_writepath, "bins", "preload", "unzip");
            string runpath = System.IO.Path.Combine(m_writepath, "bins", "current", "running");
            if (funcStart != null)
            {
                funcStart();
            }

            if (unziptoDirect)
            {
                FileTools.ExtractToDirectory(zipfile, runpath);
            }
            else
            {
                if (FileTools.DirectoryExists(unzippath))
                {
                    Directory.Delete(unzippath, true);
                    Directory.CreateDirectory(unzippath);
                }
                FileTools.ExtractToDirectory(zipfile, unzippath);
                yield return FileTools.FolderCopyAsyn(unzippath, runpath, true, null, funcProc, null);
                Directory.Delete(unzippath, true);
            }

            File.Delete(zipfile);

            if (funcDone != null)
            {
                funcDone();
            }
        }

        public IEnumerator InstallResFiles(string zipfile, bool unziptoDirect, Action funcStart = null, Action<int, int, string> funcProc = null, Action funcDone = null)
        {
            string unzippath = System.IO.Path.Combine(m_writepath, "res", "preload", "unzip");
            string runpath = System.IO.Path.Combine(m_writepath, "res", "current", "running");
            if (funcStart != null)
            {
                funcStart();
            }
           
            if (unziptoDirect)
            {
                 FileTools.ExtractToDirectory(zipfile, runpath);
            }
            else
            {
                if (FileTools.DirectoryExists(unzippath))
                {
                    Directory.Delete(unzippath, true);
                    Directory.CreateDirectory(unzippath);
                }

                FileTools.ExtractToDirectory(zipfile, unzippath);
                yield return FileTools.FolderCopyAsyn(unzippath, runpath, true, null, funcProc, null);
                Directory.Delete(unzippath, true);
            }

            //删除zip文件
            File.Delete(zipfile);

            if (funcDone != null)
            {
                funcDone();
            }
        }

        //创建文件夹
        private void makeDir(string destPath)
        {
            if (!System.IO.Directory.Exists(destPath))
            {
                System.IO.Directory.CreateDirectory(destPath);
            }
        }
    }
}