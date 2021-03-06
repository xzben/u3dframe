//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_FileDowloadWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.FileDowload), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("downloadFile", downloadFile);
		L.RegFunction("uploadFile", uploadFile);
		L.RegFunction("download", download);
		L.RegFunction("upload", upload);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("s_instance", get_s_instance, set_s_instance);
		L.RegVar("Inst", get_Inst, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int downloadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			LuaFramework.FileDowload obj = (LuaFramework.FileDowload)ToLua.CheckObject<LuaFramework.FileDowload>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			System.Action<float> arg2 = (System.Action<float>)ToLua.CheckDelegate<System.Action<float>>(L, 4);
			System.Action<bool> arg3 = (System.Action<bool>)ToLua.CheckDelegate<System.Action<bool>>(L, 5);
			obj.downloadFile(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int uploadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 6);
			LuaFramework.FileDowload obj = (LuaFramework.FileDowload)ToLua.CheckObject<LuaFramework.FileDowload>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			System.Action<float> arg3 = (System.Action<float>)ToLua.CheckDelegate<System.Action<float>>(L, 5);
			System.Action<bool,string> arg4 = (System.Action<bool,string>)ToLua.CheckDelegate<System.Action<bool,string>>(L, 6);
			obj.uploadFile(arg0, arg1, arg2, arg3, arg4);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int download(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			LuaFramework.FileDowload obj = (LuaFramework.FileDowload)ToLua.CheckObject<LuaFramework.FileDowload>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			System.Action<float> arg2 = (System.Action<float>)ToLua.CheckDelegate<System.Action<float>>(L, 4);
			System.Action<bool> arg3 = (System.Action<bool>)ToLua.CheckDelegate<System.Action<bool>>(L, 5);
			System.Collections.IEnumerator o = obj.download(arg0, arg1, arg2, arg3);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int upload(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 6);
			LuaFramework.FileDowload obj = (LuaFramework.FileDowload)ToLua.CheckObject<LuaFramework.FileDowload>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			System.Action<float> arg3 = (System.Action<float>)ToLua.CheckDelegate<System.Action<float>>(L, 5);
			System.Action<bool,string> arg4 = (System.Action<bool,string>)ToLua.CheckDelegate<System.Action<bool,string>>(L, 6);
			System.Collections.IEnumerator o = obj.upload(arg0, arg1, arg2, arg3, arg4);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_s_instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, LuaFramework.FileDowload.s_instance);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Inst(IntPtr L)
	{
		try
		{
			ToLua.Push(L, LuaFramework.FileDowload.Inst);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_s_instance(IntPtr L)
	{
		try
		{
			LuaFramework.FileDowload arg0 = (LuaFramework.FileDowload)ToLua.CheckObject<LuaFramework.FileDowload>(L, 2);
			LuaFramework.FileDowload.s_instance = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

