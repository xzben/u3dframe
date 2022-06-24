using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;


/*
	Lua AddComponent后，Unity会马上执行Awake 和 OnEnable，所以第一次AddAwake和AddOnEnable是不会被执行的，需要手动执行一次
    这里写在C#层了，特殊处理下 AddAwake 和 AddOnEnable 函数
*/
public class LuaEvent : MonoBehaviour
{
    public UnityAction aAwakeFunc = null;
    public UnityAction aOnEnableFunc = null;
    public UnityAction aUpdateFunc = null;
    public UnityAction aStartFunc = null;
    public UnityAction aOnDisableFunc = null;
    public UnityAction aLateUpdateFunc = null;
    public UnityAction aFixedUpdateFunc = null;
    public UnityAction aOnDestroyFunc = null;
    public UnityAction aResetFunc = null;
    public UnityAction aOnApplicationQuitFunc = null;

    //调用luaFunction
    public void ToCallLuaFunc(LuaFunction luafunc)
    {
        if (luafunc == null || luafunc.GetLuaState() == null) return;
        luafunc.BeginPCall();
        luafunc.PCall();
        luafunc.EndPCall();
    }

    public void AddAwake(LuaFunction luafunc)
    {
        this.aAwakeFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
        aAwakeFunc();
    }

    void Awake()
    {
        if (aAwakeFunc != null)
        {
            aAwakeFunc();
        }
    }

    public void RemoveAwake()
    {
        this.aAwakeFunc = null;
    }

    public void AddOnEnable(LuaFunction luafunc)
    {
        this.aOnEnableFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
        aOnEnableFunc();
    }

    public void RemoveOnEnable()
    {
        this.aOnEnableFunc = null;
    }

    void OnEnable()
    {
        if (aOnEnableFunc != null)
        {
            aOnEnableFunc();
        }
    }

    public void AddOnDisable(LuaFunction luafunc)
    {
        this.aOnDisableFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    void OnDisable()
    {
        if (aOnDisableFunc != null)
        {
            aOnDisableFunc();
        }
    }

    public void RemoveOnDisable()
    {
        this.aOnDisableFunc = null;
    }

    public void AddStart(LuaFunction luafunc)
    {
        this.aStartFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }


    void Start()
    {
        if (aStartFunc != null)
        {
            aStartFunc();
        }
    }

    public void RemoveStart()
    {
        this.aStartFunc = null;
    }

    public void AddUpdate(LuaFunction luafunc)
    {
        this.aUpdateFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    public void RemoveUpdate()
    {
        aUpdateFunc = null;
    }


    void Update()
    {
        if (aUpdateFunc != null)
        {
            aUpdateFunc();
        }
    }

    public void AddLateUpdate(LuaFunction luafunc)
    {
        this.aLateUpdateFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    void LateUpdate()
    {
        if (aLateUpdateFunc != null)
        {
            aLateUpdateFunc();
        }
    }

    public void RemoveLateUpdate()
    {
        this.aLateUpdateFunc = null;
    }

    public void AddFixedUpdate(LuaFunction luafunc)
    {
        this.aFixedUpdateFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }


    void FixedUpdate()
    {
        if (aFixedUpdateFunc != null)
        {
            aFixedUpdateFunc();
        }
    }

    public void RemoveFixedUpdate()
    {
        this.aFixedUpdateFunc = null;
    }

    public void AddReset(LuaFunction luafunc)
    {
        this.aResetFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    void Reset()
    {
        if (aResetFunc != null)
        {
            aResetFunc();
        }
    }

    public void RemoveReset()
    {
        this.aResetFunc = null;
    }

    public void AddOnApplicationQuit(LuaFunction luafunc)
    {
        this.aOnApplicationQuitFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    void OnApplicationQuit()
    {
        if (aOnApplicationQuitFunc != null)
        {
            aOnApplicationQuitFunc();
        }
    }

    public void RemoveOnApplicationQuit()
    {
        this.aOnApplicationQuitFunc = null;
    }

    public void AddOnDestroy(LuaFunction luafunc)
    {
        this.aOnDestroyFunc = delegate () {
            ToCallLuaFunc(luafunc);
        };
    }

    void OnDestroy()
    {
        if (aOnDestroyFunc != null)
        {
            aOnDestroyFunc();
        }
    }

    public void RemoveOnDestroy()
    {
        this.aOnDestroyFunc = null;
    }
}