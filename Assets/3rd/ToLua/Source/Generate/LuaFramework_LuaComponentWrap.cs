//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_LuaComponentWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.LuaComponent), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("reset", reset);
		L.RegFunction("getNodeInfo", getNodeInfo);
		L.RegFunction("getLuaObject", getLuaObject);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("luaFilePath", get_luaFilePath, set_luaFilePath);
		L.RegVar("nodes", get_nodes, set_nodes);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int reset(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 4)
			{
				LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)ToLua.CheckObject<LuaFramework.LuaComponent>(L, 1);
				LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
				obj.reset(arg0, arg1, arg2);
				return 0;
			}
			else if (count == 5)
			{
				LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)ToLua.CheckObject<LuaFramework.LuaComponent>(L, 1);
				LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
				LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
				obj.reset(arg0, arg1, arg2, arg3);
				return 0;
			}
			else if (count == 6)
			{
				LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)ToLua.CheckObject<LuaFramework.LuaComponent>(L, 1);
				LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
				LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
				LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
				LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
				LuaFunction arg4 = ToLua.CheckLuaFunction(L, 6);
				obj.reset(arg0, arg1, arg2, arg3, arg4);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LuaFramework.LuaComponent.reset");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int getNodeInfo(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)ToLua.CheckObject<LuaFramework.LuaComponent>(L, 1);
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			LuaInterface.LuaTable o = obj.getNodeInfo(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int getLuaObject(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)ToLua.CheckObject<LuaFramework.LuaComponent>(L, 1);
			LuaInterface.LuaTable o = obj.getLuaObject();
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
	static int get_luaFilePath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)o;
			string ret = obj.luaFilePath;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaFilePath on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_nodes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)o;
			UnityEngine.GameObject[] ret = obj.nodes;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index nodes on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaFilePath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.luaFilePath = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaFilePath on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_nodes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LuaFramework.LuaComponent obj = (LuaFramework.LuaComponent)o;
			UnityEngine.GameObject[] arg0 = ToLua.CheckObjectArray<UnityEngine.GameObject>(L, 2);
			obj.nodes = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index nodes on a nil value");
		}
	}
}

