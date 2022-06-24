﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class TableViewWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(TableView), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("InitComponent", InitComponent);
		L.RegFunction("OnScrollValueChanged", OnScrollValueChanged);
		L.RegFunction("getCellData", getCellData);
		L.RegFunction("OnCellCreateAtIndex", OnCellCreateAtIndex);
		L.RegFunction("setCellClass", setCellClass);
		L.RegFunction("setUpdateCellFunc", setUpdateCellFunc);
		L.RegFunction("setCellAwakFunc", setCellAwakFunc);
		L.RegFunction("setData", setData);
		L.RegFunction("reloadData", reloadData);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("m_cell", get_m_cell, set_m_cell);
		L.RegVar("m_GapStart", get_m_GapStart, set_m_GapStart);
		L.RegVar("m_GapEnd", get_m_GapEnd, set_m_GapEnd);
		L.RegVar("m_cellGap", get_m_cellGap, set_m_cellGap);
		L.RegVar("m_keepCellSize", get_m_keepCellSize, set_m_keepCellSize);
		L.RegVar("m_cellInterval", get_m_cellInterval, set_m_cellInterval);
		L.RegVar("m_currentDir", get_m_currentDir, set_m_currentDir);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitComponent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			obj.InitComponent();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnScrollValueChanged(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			obj.OnScrollValueChanged(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int getCellData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			LuaInterface.LuaTable o = obj.getCellData(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnCellCreateAtIndex(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.GameObject o = obj.OnCellCreateAtIndex(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int setCellClass(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			LuaTable arg1 = ToLua.CheckLuaTable(L, 3);
			obj.setCellClass(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int setUpdateCellFunc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.setUpdateCellFunc(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int setCellAwakFunc(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.setCellAwakFunc(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int setData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
			LuaTable arg0 = ToLua.CheckLuaTable(L, 2);
			obj.setData(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int reloadData(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
				obj.reloadData();
				return 0;
			}
			else if (count == 2)
			{
				TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				obj.reloadData(arg0);
				return 0;
			}
			else if (count == 3)
			{
				TableView obj = (TableView)ToLua.CheckObject<TableView>(L, 1);
				bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				obj.reloadData(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: TableView.reloadData");
			}
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
	static int get_m_cell(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			UnityEngine.GameObject ret = obj.m_cell;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cell on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_GapStart(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float ret = obj.m_GapStart;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_GapStart on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_GapEnd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float ret = obj.m_GapEnd;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_GapEnd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_cellGap(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float ret = obj.m_cellGap;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cellGap on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_keepCellSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			bool ret = obj.m_keepCellSize;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_keepCellSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_cellInterval(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float ret = obj.m_cellInterval;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cellInterval on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_m_currentDir(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			TableView.ViewDirection ret = obj.m_currentDir;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_currentDir on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_cell(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			obj.m_cell = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cell on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_GapStart(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.m_GapStart = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_GapStart on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_GapEnd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.m_GapEnd = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_GapEnd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_cellGap(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.m_cellGap = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cellGap on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_keepCellSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.m_keepCellSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_keepCellSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_cellInterval(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.m_cellInterval = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_cellInterval on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_m_currentDir(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TableView obj = (TableView)o;
			TableView.ViewDirection arg0 = (TableView.ViewDirection)ToLua.CheckObject(L, 2, typeof(TableView.ViewDirection));
			obj.m_currentDir = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index m_currentDir on a nil value");
		}
	}
}

