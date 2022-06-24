using System;

using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using LuaInterface;

class Uncompress
{
    /// <summary>
    /// 解压功能(解压压缩文件到指定目录)
    /// </summary>
    /// <param name="FileToUpZip">待解压的文件</param>
    /// <param name="ZipedFolder">指定解压目标目录</param>
    public bool UnZip(string FileToUpZip, string ZipedFolder, LuaFunction callback = null)
    {
        bool res = true;
        if (!File.Exists(FileToUpZip))
        {
            //Log(FileToUpZip + " is not exist");
            return false;
        }

        if (!Directory.Exists(ZipedFolder))
        {
            Directory.CreateDirectory(ZipedFolder);
        }

        ZipInputStream zipInputS = null;
        ZipEntry theEntry = null;

        string fileName;
        FileStream streamWriter = null;
        FileStream file = null;
        int zipLeng = 0;
        int zipIndex = 0;
        float rate = 0;
        try
        {
            file = File.OpenRead(FileToUpZip);
            zipInputS = new ZipInputStream(file);
            while ((theEntry = zipInputS.GetNextEntry()) != null)
            {
                if (theEntry.Name != String.Empty)
                {
                    zipLeng++;
                }
            }
            file = File.OpenRead(FileToUpZip);
            zipInputS = new ZipInputStream(file);
            while ((theEntry = zipInputS.GetNextEntry()) != null)
            {
                if (theEntry.Name != String.Empty)
                {
                    zipIndex++;
                    if(callback != null){
                        rate = (float)zipIndex / (float)zipLeng;
                        callback.BeginPCall();
                        callback.Push(rate);
                        callback.PCall();
                        callback.EndPCall();
                    }
                    //Log(ZipedFolder, theEntry.Name);
                    fileName = Path.Combine(ZipedFolder, theEntry.Name);
                    ///判断文件路径是否是文件夹
                    if (fileName.EndsWith("/") || fileName.EndsWith("\\"))
                    {
                        Directory.CreateDirectory(fileName);
                        continue;
                    }
                    //Log("create:" + fileName);
                    CheckFileSavePath(fileName);
                    streamWriter = File.Create(fileName);
                    int size = 2048;
                    byte[] data = new byte[size];
                    while (true)
                    {
                        size = zipInputS.Read(data, 0, data.Length);
                        if (size > 0)
                        {
                            streamWriter.Write(data, 0, size);
                        }
                        else
                        {
                            break;
                        }
                    }
                    streamWriter.Close();
                }
                
            }
            
        }
        catch (Exception ex)
        {
            //Log("zip error:"+ex.Message);
            res = false;
        }
        finally
        {
            if(file != null)
            {
                file.Close();
                file = null;
            }

            if (streamWriter != null)
            {
                streamWriter.Close();
                streamWriter = null;
            }
            if (theEntry != null)
            {
                theEntry = null;
            }
            if (zipInputS != null)
            {
                zipInputS.Close();
                zipInputS = null;
            }
            GC.Collect();
            GC.Collect(1); 
        }

        return res;
    }

    public void CheckFileSavePath(string path)
    {
        string realPath = path;
        int ind = path.LastIndexOf("/");
        if (ind >= 0)
        {
            realPath = path.Substring(0, ind);
        }
        else
        {
            ind = path.LastIndexOf("\\");
            if (ind >= 0)
            {
                realPath = path.Substring(0, ind);
            }
        }
        if (!Directory.Exists(realPath))
        {
            Directory.CreateDirectory(realPath);
        }
    }

}



