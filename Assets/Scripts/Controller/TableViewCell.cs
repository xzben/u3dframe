using UnityEngine;
using System.Collections;
using LuaInterface;

public class TableViewCell : MonoBehaviour
{
    private int      m_curIndex = -1;
    private LuaTable m_curData = null;
    private LuaFunction m_updateFunc = null;
    private LuaFunction m_initFunc = null;

    public void doInit()
    {
        if (m_initFunc != null)
        {
            m_initFunc.BeginPCall();
            m_initFunc.Push(gameObject);
            m_initFunc.Push(this);
            m_initFunc.PCall();
            m_initFunc.EndPCall();
        }
    }

    public void createLuaObject(LuaTable cellclass, LuaTable cellArgs)
    {
        LuaFunction createFunc = cellclass.GetLuaFunction("new");
        if( createFunc != null)
        {
            createFunc.BeginPCall();
            createFunc.Push(gameObject);
            createFunc.Push(cellArgs);
            createFunc.PCall();
            createFunc.EndPCall();
        }
        else
        {
            Debug.LogError("invalid cell class");
        }
    }
    public void reset(LuaFunction updateFunc)
    {
        m_updateFunc = updateFunc;
    }

    public void setInitFunc(LuaFunction initFunc)
    {
        m_initFunc = initFunc;
    }

    public LuaTable getData()
    {
        return m_curData;
    }

    private void Start()
    {
        
    }

    public int getCurIndex()
    {
        return m_curIndex;
    }

    public void UpdateCell(int index, LuaTable data, bool forceUpdate = false)
    {
        if (forceUpdate == false && m_curIndex == index && m_curData == data) return;
        m_curIndex = index;
        m_curData = data;

        if(m_updateFunc != null)
        {
            m_updateFunc.BeginPCall();
            m_updateFunc.Push(gameObject);
            m_updateFunc.Push(index);
            m_updateFunc.Push(data);
            m_updateFunc.PCall();
            m_updateFunc.EndPCall();
        }
    }
}
