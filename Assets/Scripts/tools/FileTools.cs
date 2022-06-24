using LuaInterface;
using System;
using System.Collections;
using System.IO;
using System.IO.Compression;
using System.Security.Cryptography;
using UnityEngine;
using UnityEngine.Networking;

public class FileTools : MonoBehaviour
{
    public static void CopyDirNoThrow(string srcPath, string destPath)
    {
        try
        {
            //路径统一按照Unix格式
            string _src = srcPath.Replace('\\', '/');
            string _dest = destPath.Replace('\\', '/');

            if (_src[srcPath.Length - 1] != '/')
            {
                _src += '/';
            }

            if (_dest[destPath.Length - 1] != '/')
            {
                _dest += '/';
            }

            //判断是否存在有目录同名文件，如果有就删去
            string _destFile = _dest.Substring(0, _dest.Length - 1);
            if (System.IO.File.Exists(_destFile))
            {
                System.IO.File.Delete(_destFile);
            }

            // 判断目标目录是否存在如果不存在则新建
            if (!System.IO.Directory.Exists(_dest))
            {
                System.IO.Directory.CreateDirectory(_dest);
            }

            string[] fileList = System.IO.Directory.GetFileSystemEntries(_src);
            // 遍历所有的文件和目录
            foreach (string file in fileList)
            {
                // 先当作目录处理如果存在这个目录就递归Copy该目录下面的文件
                if (System.IO.Directory.Exists(file))
                {
                    CopyDirNoThrow(file, _dest + System.IO.Path.GetFileName(file));
                }
                // 否则直接Copy文件
                else
                {
                    //判断是否dest存在同名目录，如果有就删去
                    if (System.IO.Directory.Exists(_dest + System.IO.Path.GetFileName(file)))
                    {
                        FolderDelete(_dest + System.IO.Path.GetFileName(file));
                    }
                    System.IO.File.Copy(file, _dest + System.IO.Path.GetFileName(file), true);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError("CopyDirNoThrow:" + e);
        }
    }

    

    public static void CopyDir(string srcPath, string destPath)
    {
        try
        {
            string _src = srcPath.Replace('\\', '/');
            string _dest = destPath.Replace('\\', '/');

            if (_src[srcPath.Length - 1] != '/')
            {
                _src += '/';
            }

            if (_dest[destPath.Length - 1] != '/')
            {
                _dest += '/';
            }

            // 检查目标目录是否以目录分割字符结束如果不是则添加
            //if (destPath[destPath.Length - 1] != '/')
            //{
            //    destPath += '/';
            //}
            // 判断目标目录是否存在如果不存在则新建
            if (!System.IO.Directory.Exists(_dest))
            {
                System.IO.Directory.CreateDirectory(_dest);
            }
            // 得到源目录的文件列表，该里面是包含文件以及目录路径的一个数组
            // 如果你指向copy目标文件下面的文件而不包含目录请使用下面的方法
            // string[] fileList = Directory.GetFiles（srcPath）；
            string[] fileList = System.IO.Directory.GetFileSystemEntries(_src);
            // 遍历所有的文件和目录
            foreach (string file in fileList)
            {
                // 先当作目录处理如果存在这个目录就递归Copy该目录下面的文件
                if (System.IO.Directory.Exists(file))
                {
                    CopyDir(file, _dest + System.IO.Path.GetFileName(file));
                }
                // 否则直接Copy文件
                else
                {
                    System.IO.File.Copy(file, _dest + System.IO.Path.GetFileName(file), true);
                }
            }
        }
        catch (Exception e)
        {
            throw e;
        }
    }


    public static void CopyDirFilesByEx(string srcFolderPath, string destFolderPath, string ext, string time)
    {
        string _src = normalizeDirPath(srcFolderPath);
        string _dest = normalizeDirPath(destFolderPath);

        //检查目标目录是否以目标分隔符结束，如果不是则添加之
        //if (destFolderPath[destFolderPath.Length - 1] != Path.DirectorySeparatorChar)
        //    destFolderPath += Path.DirectorySeparatorChar;
        //判断目标目录是否存在，如果不在则创建之
        if (!Directory.Exists(_dest))
            Directory.CreateDirectory(_dest);
        string[] fileList = Directory.GetFileSystemEntries(_src);
        foreach (string file in fileList)
        {
            if (Directory.Exists(file))
                CopyDirFilesByEx(file, _dest + Path.GetFileName(file), ext, time);
            else
            {
                FileInfo fi = new FileInfo(file);
                if (fi.Attributes.ToString().IndexOf("ReadOnly") != -1)//改变只读文件属性，否则删不掉
                    fi.Attributes = FileAttributes.Normal;
                try
                {
                    string ex = Path.GetExtension(file);
                    if (ex == ext)
                    {
                        string name = Path.GetFileNameWithoutExtension(file);
                        string tempDest = _dest + name + "_" + time + ex;
                        File.Copy(file, tempDest, true);
                    }
                }
                catch (Exception e)
                {

                }
            }

        }
    }

    public IEnumerator ReadData(string path, Action<byte[]> action_CB)
    {
        using (UnityWebRequest req = UnityWebRequest.Get(path))
        {
            yield return req.SendWebRequest();

            if (!string.IsNullOrEmpty(req.error))
            {
                Debug.LogError(req.error + path);
                action_CB(null);
            }
            else
            {
                if (req.isDone == false)
                {
                    Debug.LogError("www.isDone == false" + path);
                    action_CB(null);
                }
                else
                {
                    byte[] data = req.downloadHandler.data;
                    action_CB(data);
                }
            }
        }
    }

    //文件路径上的文件夹是否存在，如果不存在，则创建，默认文件夹连接符都是"/"
    public static bool CreateFilePath(string file)
    {
        string fileSrc = file.Replace('\\', '/');

        //如果是个文件夹
        if (fileSrc[fileSrc.Length - 1] == '/')
        {
            return false;
        }
        //获取文件的文件夹路径
        string fileFolder = "";
        string[] filePaths = fileSrc.Split('/');
        for (int i = 0; i < filePaths.Length - 1; i++)
        {
            fileFolder += filePaths[i] + '/';
        }
        if (fileFolder != "")
        {
            if (!Directory.Exists(fileFolder))
            {
                Directory.CreateDirectory(fileFolder);
            }
        }
        return true;
    }

    //文件是否存在
    public static bool FileExists(string filePath)
    {
        return File.Exists(filePath);
    }

    //文件夹是否存在
    public static bool DirectoryExists(string filePath)
    {
        return Directory.Exists(filePath);
    }

    //文件夹是否存在
    public static bool CreateDirectory(string filePath)
    {
        //if (filePath[filePath.Length - 1] == '/')
        //{
        //    return false;
        //}
        Directory.CreateDirectory(filePath);
        return true;
    }

    public static bool isDirectoryEmpty(string directpath)
    {
        if (!Directory.Exists(directpath))
        {
            return true;
        }
        string[] fileList = System.IO.Directory.GetFileSystemEntries(directpath);

        if (fileList.Length > 0)
            return false;

        return true;
    }
    //先删除再拷贝
    public static void FileDeleteAndCopy(string srcFilePath, string destFilePath)
    {
        string _src = srcFilePath.Replace('\\', '/');
        string _dest = destFilePath.Replace('\\', '/');

        if (File.Exists(_dest))
        {
            FileDelete(_dest);
        }
        if (Directory.Exists(_dest))
        {
            FolderDelete(_dest);
        }
        FileCopy(_src, _dest);
    }


    public static void FileCopy(string srcFilePath, string destFilePath)
    {
        File.Copy(srcFilePath, destFilePath);
    }

    public static void FileMove(string srcFilePath, string destFilePath)
    {
        File.Move(srcFilePath, destFilePath);
    }

    public static void FileDelete(string delFilePath)
    {
        File.Delete(delFilePath);
    }

    //删除文件夹
    public static void FolderDelete(string delFolderPath)
    {
        string _dest = delFolderPath.Replace('\\', '/');
        if (_dest[delFolderPath.Length - 1] != '/')
        {
            _dest += '/';
        }
        //if (delFolderPath[delFolderPath.Length - 1] != Path.DirectorySeparatorChar)
        //    delFolderPath += Path.DirectorySeparatorChar;
        //string[] fileList = Directory.GetFileSystemEntries(delFolderPath);

        if (!Directory.Exists(_dest))
            return;

        foreach (string item in Directory.GetFileSystemEntries(_dest))
        {
            if (File.Exists(item))
            {
                FileInfo fi = new FileInfo(item);
                if (fi.Attributes.ToString().IndexOf("ReadOnly") != -1)//改变只读文件属性，否则删不掉
                    fi.Attributes = FileAttributes.Normal;
                File.Delete(item);
            }//删除其中的文件
            else
                FolderDelete(item);//递归删除子文件夹
        }
        Directory.Delete(_dest, true);//删除已空文件夹
    }

    //删除指定文件夹下的所有子文件和子文件夹
    public static void SubFolderDelete(string delFolderPath)
    {
        string _dest = delFolderPath.Replace('\\', '/');
        if (_dest[delFolderPath.Length - 1] != '/')
        {
            _dest += '/';
        }

        //if (delFolderPath[delFolderPath.Length - 1] != Path.DirectorySeparatorChar)
        //    delFolderPath += Path.DirectorySeparatorChar;
        //string[] fileList = Directory.GetFileSystemEntries(delFolderPath);

        foreach (string item in Directory.GetFileSystemEntries(_dest))
        {
            if (File.Exists(item))
            {
                FileInfo fi = new FileInfo(item);
                if (fi.Attributes.ToString().IndexOf("ReadOnly") != -1)//改变只读文件属性，否则删不掉
                    fi.Attributes = FileAttributes.Normal;
                File.Delete(item);
            }//删除其中的文件
            else
                FolderDelete(item);//递归删除子文件夹
        }
        //Directory.Delete(delFolderPath);//删除已空文件夹
    }

    //文件夹copy
    public static void FolderCopySync(string srcFolderPath, string destFolderPath, bool removeOrigin)
    {
        string _src = normalizeDirPath(srcFolderPath);
        string _dest = normalizeDirPath(destFolderPath);

        //检查目标目录是否以目标分隔符结束，如果不是则添加之
        //if (destFolderPath[destFolderPath.Length - 1] != Path.DirectorySeparatorChar)
        //    destFolderPath += Path.DirectorySeparatorChar;
        //判断目标目录是否存在，如果不在则创建之
        if (!Directory.Exists(_dest))
            Directory.CreateDirectory(_dest);
        string[] fileList = Directory.GetFileSystemEntries(_src);
        foreach (string file in fileList)
        {
            if (Directory.Exists(file))
                FolderCopySync(file, _dest + Path.GetFileName(file), removeOrigin);
            else
            {
                FileInfo fi = new FileInfo(file);
                if (fi.Attributes.ToString().IndexOf("ReadOnly") != -1)//改变只读文件属性，否则删不掉
                    fi.Attributes = FileAttributes.Normal;
                try
                {
                    File.Copy(file, _dest + Path.GetFileName(file), true);
                    if (removeOrigin)
                    {
                        File.Delete(file);
                    }
                }
                catch (Exception e)
                {

                }
            }

        }
    }
    public static string normalizeDirPath( string path)
    {
        string newpath = path.Replace('\\', '/');
        if (newpath[path.Length - 1] != '/')
        {
            newpath += '/';
        }

        return newpath;
    }

    public static void FolderMove(string srcFolderPath, string destFolderPath)
    {
        string _src = normalizeDirPath(srcFolderPath);
        string _dest = normalizeDirPath(destFolderPath);

        //检查目标目录是否以目标分隔符结束，如果不是则添加之
        //if (destFolderPath[destFolderPath.Length - 1] != Path.DirectorySeparatorChar)
        //    destFolderPath += Path.DirectorySeparatorChar;
        //判断目标目录是否存在，如果不在则创建之
        if (!Directory.Exists(_dest))
            Directory.CreateDirectory(_dest);
        string[] fileList = Directory.GetFileSystemEntries(_src);
        foreach (string file in fileList)
        {
            if (Directory.Exists(file))
            {
                FolderMove(file, _dest + Path.GetFileName(file));
                //Directory.Delete(file);
            }
            else
                File.Move(file, _dest + Path.GetFileName(file));
        }
        Directory.Delete(_src);
    }

    public static IEnumerator FolderCopyAsyn(string frompath, string topath, bool removeOrigin, Action funcStart = null, Action<int, int, string> funcProc = null, Action funcDone = null)
    {
        if (funcStart != null)
            funcStart();

        if (Directory.Exists(frompath))
        {
            string[] files = Directory.GetFiles(frompath, "*.*", SearchOption.AllDirectories);
            frompath.Replace('\\', '/');
            topath.Replace('\\', '/');

            int curSize = 0;
            int totalSize = files.Length;

            foreach (var file in files)
            {
                file.Replace('\\', '/');

                string tofilepath = file;
                tofilepath = tofilepath.Replace(frompath, topath);

                if (File.Exists(tofilepath)) File.Delete(tofilepath);
                string todir = Path.GetDirectoryName(tofilepath);

                if (!Directory.Exists(todir))
                {
                    Directory.CreateDirectory(todir);
                }
                    
                if (Application.platform == RuntimePlatform.Android)
                {
                    UnityWebRequest req = UnityWebRequest.Get("file://"+file);
                    yield return req.SendWebRequest();

                    if (!req.isNetworkError && req.isDone)
                    {
                        File.WriteAllBytes(tofilepath, req.downloadHandler.data);
                        Debug.LogError("FolderCopyAsyn done" + tofilepath + " size:" + req.downloadHandler.data.Length);
                    }
                    else
                    {
                        Debug.LogError("FolderCopyAsyn error" + tofilepath + " error:" + req.error);
                    }
                }
                else
                {
                    File.Copy(file, tofilepath, true);
                }

                if (removeOrigin)
                {
                    File.Delete(file);
                }
                curSize++;

                if (funcProc != null)
                    funcProc(curSize, totalSize, tofilepath);
            }
        }

        if (funcDone != null)
        {
            funcDone();
        }
    }

    //把ZipFile的几个类暴露出来
    public static void CreateZipFromDirectory(string sourceDirectoryName, string destinationArchiveFileName)
    {
        ZipFile.CreateFromDirectory(sourceDirectoryName, destinationArchiveFileName);
    }

    public static void CreateZipFromDirectory(string sourceDirectoryName, string destinationArchiveFileName, System.IO.Compression.CompressionLevel compressionLevel, bool includeBaseDirectory)
    {
        ZipFile.CreateFromDirectory(sourceDirectoryName, destinationArchiveFileName, compressionLevel, includeBaseDirectory);
    }

    public static void CreateZipFromDirectory(string sourceDirectoryName, string destinationArchiveFileName, System.IO.Compression.CompressionLevel compressionLevel, bool includeBaseDirectory, System.Text.Encoding entryNameEncoding)
    {
        ZipFile.CreateFromDirectory(sourceDirectoryName, destinationArchiveFileName, compressionLevel, includeBaseDirectory, entryNameEncoding);
    }

    //暴露给Lua的时候，需要暴露错误
    public static string ExtractToDirectory(string sourceArchiveFileName, string destinationDirectoryName)
    {
        string retStr = "";
        try
        {
            ZipFile.ExtractToDirectory(sourceArchiveFileName, destinationDirectoryName);
        }
        catch (Exception e)
        {
            retStr = e.ToString();
        }
        return retStr;
    }

    //暴露给Lua的时候，需要暴露错误
    public static string ExtractToDirectory(string sourceArchiveFileName, string destinationDirectoryName, System.Text.Encoding entryNameEncoding)
    {
        string retStr = "";
        try
        {
            ZipFile.ExtractToDirectory(sourceArchiveFileName, destinationDirectoryName, entryNameEncoding);
        }
        catch (Exception e)
        {
            retStr = e.ToString();
        }
        return retStr;
    }

    public static string getFileName( string filepath)
    {
        return Path.GetFileName(filepath);
    }

    public static string getFilePath( string filepath)
    {
        return Path.GetDirectoryName(filepath);
    }

    public static string ExtractToDirectoryNew(string sourceArchiveFileName, string destinationDirectoryName)
    {
        try
        {
            Uncompress fileUnpack = new Uncompress();
            fileUnpack.UnZip(sourceArchiveFileName, destinationDirectoryName);
            return "";
        }
        catch (Exception e)
        {

            return e.ToString();
        }
    }

    public static string ReadAllText(string fileName)
    {
        return File.ReadAllText(fileName);
    }

    public static void WriteAllText(string path, string fileContent)
    {
        File.WriteAllText(path, fileContent);
    }

    //配置文件的加解密方案
    //加密
    static byte[] EncryptToBytes(string plainText, byte[] Key, byte[] IV)
    {
        //转下码
        string str = plainText;

        // Check arguments.
        if (plainText == null || plainText.Length <= 0)
            throw new ArgumentNullException("plainText");
        if (Key == null || Key.Length <= 0)
            throw new ArgumentNullException("Key");
        if (IV == null || IV.Length <= 0)
            throw new ArgumentNullException("IV");
        byte[] encrypted;
        // Create an RijndaelManaged object
        // with the specified key and IV.
        using (RijndaelManaged rijAlg = new RijndaelManaged())
        {
            rijAlg.Key = Key;
            rijAlg.IV = IV;

            // Create an encryptor to perform the stream transform.
            ICryptoTransform encryptor = rijAlg.CreateEncryptor(rijAlg.Key, rijAlg.IV);

            // Create the streams used for encryption.
            using (MemoryStream msEncrypt = new MemoryStream())
            {
                using (CryptoStream csEncrypt = new CryptoStream(msEncrypt, encryptor, CryptoStreamMode.Write))
                {
                    using (StreamWriter swEncrypt = new StreamWriter(csEncrypt))
                    {

                        //Write all data to the stream.
                        swEncrypt.Write(str);
                    }
                    encrypted = msEncrypt.ToArray();
                }
            }
        }

        // Return the encrypted bytes from the memory stream.
        return encrypted;

        //return Convert.ToBase64String(encrypted);
    }
    //解密
    static string DecryptStringFromBytes(byte[] cipherText, byte[] Key, byte[] IV)
    {
        //byte[] toCipher = Convert.FromBase64String(cipherText);
        // Check arguments.
        if (cipherText == null || cipherText.Length <= 0)
            throw new ArgumentNullException("cipherText");
        if (Key == null || Key.Length <= 0)
            throw new ArgumentNullException("Key");
        if (IV == null || IV.Length <= 0)
            throw new ArgumentNullException("IV");

        // Declare the string used to hold
        // the decrypted text.
        string plaintext = null;

        // Create an RijndaelManaged object
        // with the specified key and IV.
        using (RijndaelManaged rijAlg = new RijndaelManaged())
        {
            rijAlg.Key = Key;
            rijAlg.IV = IV;

            // Create a decryptor to perform the stream transform.
            ICryptoTransform decryptor = rijAlg.CreateDecryptor(rijAlg.Key, rijAlg.IV);

            // Create the streams used for decryption.
            using (MemoryStream msDecrypt = new MemoryStream(cipherText))
            {
                using (CryptoStream csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                {
                    using (StreamReader srDecrypt = new StreamReader(csDecrypt))
                    {
                        // Read the decrypted bytes from the decrypting stream
                        // and place them in a string.
                        plaintext = srDecrypt.ReadToEnd();
                    }
                }
            }
        }

        return plaintext;
    }

    //Lua 函数，读取文件，解密后返回
    public static string LuaReadAndDecrypt(string filePath)
    {
        try
        {
            byte[] fileContext = File.ReadAllBytes(filePath);
            return DecryptStringFromBytes(fileContext, _confKey, _confIV);
        }
        catch (Exception e)
        {
            Debug.LogError(e);
            return "";
        }
    }

    //Lua函数，加密后，保存在filePath上
    public static int LuaEncryptAndSave(string context, string filePath)
    {
        //byte[] encryptStr;
        try
        {
            byte[] encryptStr = EncryptToBytes(context, _confKey, _confIV);

            //创建文件夹
            CreateFilePath(filePath);
            File.WriteAllBytes(filePath, encryptStr);
        }
        catch (Exception e)
        {
            Debug.LogError(e);
            return -1;
        }
        return 0;
    }


    private static byte[] _confKey = { 0xC2, 0x8C, 0x67, 0x21, 0xCE, 0x5A, 0xEE, 0xE8, 0xD4, 0x31, 0x27, 0x86, 0xD3, 0xA4, 0xD0, 0x3E, 0x28, 0x1F, 0xC3, 0x55, 0x62, 0xBC, 0xA5, 0xED, 0x8C, 0x6D, 0x2A, 0x3F, 0x29, 0x99, 0x1B, 0x3B };
    private static byte[] _confIV = { 0x22, 0x66, 0xC8, 0x24, 0xA9, 0xFD, 0x91, 0xE7, 0x9D, 0x3A, 0x57, 0x55, 0x28, 0xC9, 0x84, 0x02 };

    private static string ToHexString(byte[] bytes)
    {
        string byteStr = string.Empty;
        if (bytes != null || bytes.Length != 0)
        {
            foreach (var item in bytes)
            {
                byteStr += string.Format("{0:X2} ", item);
            }
        }
        return byteStr;
    }

}