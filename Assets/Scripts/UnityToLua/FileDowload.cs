using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine.Networking;
using UnityEngine;
using System.IO;

namespace LuaFramework
{
    public class FileDowload : MonoBehaviour
    {
        public static FileDowload s_instance = null;

        public static FileDowload Inst
        {
            get
            {
                if(s_instance == null)
                {
                    GameObject obj = new GameObject("#FileDownload#");
                    DontDestroyOnLoad(obj);
                    s_instance = obj.AddComponent<FileDowload>();
                }
                return s_instance;
            }
        }

        public void downloadFile(string url, string destfilepath, Action<float> funcProcess, Action<bool> result)
        {
            StartCoroutine(download(url, destfilepath, funcProcess, result));
        }

        public void uploadFile(string url, string file, string mimeType, Action<float> funcProcess, Action<bool, string> result)
        {
            StartCoroutine(upload(url, file, mimeType, funcProcess, result));
        }

        public IEnumerator download(string url, string destfilepath, Action<float> funcProcess, Action<bool> result)
        {
            UnityWebRequest request = UnityWebRequest.Get(url);
            request.SendWebRequest();
            if (request.isHttpError || request.isNetworkError)
            {
                Debug.LogError("当前的下载发生错误" + request.error);
                result(false);
                yield break;
            }
            while (!request.isDone)
            {
                Debug.Log("当前的下载进度为：" + request.downloadProgress);
                funcProcess(request.downloadProgress);
                yield return 0;
            }

            if (request.isDone)
            {
                funcProcess(1);
                string path = Path.GetDirectoryName(destfilepath);
                if (File.Exists(destfilepath))
                {
                    File.Delete(destfilepath);
                }

                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                //将下载的文件写入
                using (FileStream fs = new FileStream(destfilepath, FileMode.Create))
                {
                    byte[] data = request.downloadHandler.data;
                    fs.Write(data, 0, data.Length);
                }
                result(true);
            }
        }

        public IEnumerator upload(string url, string file, string mimeType, Action<float> funcProcess, Action<bool, string> result)
        {
            if (!File.Exists(file))
            {
                result(false, "upload file not exist");
                yield break;
            }

            byte[] filecontent = File.ReadAllBytes(file);
            string filename = Path.GetFileName(file);
            WWWForm form = new WWWForm();
            form.AddBinaryData("file", filecontent, filename, mimeType);

            using( UnityWebRequest www = UnityWebRequest.Post(url, form))
            {
                www.SendWebRequest();
                if(www.isHttpError || www.isNetworkError)
                {
                    Debug.LogError("当前上传错误" + www.error);
                    result(false, www.error);
                    yield break;
                }

                while (!www.isDone)
                {
                    funcProcess(www.uploadProgress);
                    yield return 0;
                }

                if (www.isDone)
                {
                    string resp = "";

                    if (www.downloadHandler != null)
                    {
                        resp = www.downloadHandler.text;
                    }
                    Debug.Log("上传成功服务器返回:" + resp);
                    result(true, resp);
                }
            }
        }
    }
}
