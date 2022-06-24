using LuaInterface;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TableView : MonoBehaviour
{
    public enum ViewDirection
    {
        Horizontal,//横向滑动
        Vertical//纵向滑动
    }
    /// <summary>
    /// 子项对象
    /// </summary>
    public GameObject m_cell;

    /// <summary>
    /// 面板总尺寸(宽或高)
    /// </summary>
    protected Vector2 m_totalViewSize;

    /// <summary>
    /// 可见面板尺寸(宽或高)
    /// </summary>
    protected Vector2 m_visibleViewSize;

    /// <summary>
    /// 子项尺寸(宽或高)
    /// </summary>
    protected Vector2 m_cellSize;

    [Tooltip("在tableview的列表头部留白不显示的宽度")]
    public float m_GapStart = 0;
    [Tooltip("在tableview的列表尾部留白不显示的宽度")]
    public float m_GapEnd = 0;
    [Tooltip("在 keep cell size 为false的情况下，自动扩展的item左右留白的宽度")]
    public float m_cellGap = 0;
    [Tooltip("是否保持原始item的size，如果false 垂直滚动会自动拉宽，水平滚动则自动拉高")]
    public bool m_keepCellSize = false;
    [Tooltip("表示cell之间的间隙")]
    public float m_cellInterval = 0;
    /// <summary>
    /// 可滑动距离
    /// </summary>
    protected float m_totalScrollDistance;

    /// <summary>
    /// 子项总数量
    /// </summary>
    protected int m_totalCellCount = 0;

    /// <summary>
    /// 开始下标
    /// </summary>
    protected int m_startIndex;

    /// <summary>
    /// 结束下标
    /// </summary>
    protected int m_endIndex;
    /// <summary>
    /// 可见子项集合
    /// </summary>
    protected Dictionary<int, GameObject> m_cells;

    /// <summary>
    /// 可重用子项集合
    /// </summary>
    protected List<GameObject> m_reUseCellList;

    /// <summary>
    /// 当前滑动方向
    /// </summary>
    public ViewDirection m_currentDir = ViewDirection.Vertical;

    /// <summary>
    /// ScrollRect组件
    /// </summary>
    protected ScrollRect m_scrollRect;

    /// <summary>
    /// RectTransform组件
    /// </summary>
    protected RectTransform m_rectTransform;

    /// <summary>
    /// 内容面板RectTransform组件
    /// </summary>
    protected RectTransform m_contentRectTransform;

    protected LuaTable m_datas = null;

    protected LuaTable m_cellClass;
    protected LuaTable m_cellArgs;
    protected LuaFunction m_updateFunc = null;
    protected LuaFunction m_cellAwakFunc = null;
    protected Vector2 m_lastOffset = Vector2.zero;
    protected bool m_forceUpdate = false;
    /// <summary>
    /// 初始化组件
    /// </summary>
    public virtual void InitComponent()
    {
        m_scrollRect = this.GetComponent<ScrollRect>();
        m_rectTransform = this.GetComponent<RectTransform>();
        m_contentRectTransform = m_scrollRect.content;

        m_cells = new Dictionary<int, GameObject>();
        m_reUseCellList = new List<GameObject>();
        m_cellSize = m_cell.GetComponent<RectTransform>().sizeDelta;

        m_scrollRect.horizontal = m_currentDir == ViewDirection.Horizontal ? true : false;
        m_scrollRect.vertical = m_currentDir == ViewDirection.Horizontal ? false : true;

        Rect rect = m_rectTransform.rect;
        m_visibleViewSize = new Vector2(rect.width, rect.height);
        if (m_currentDir == ViewDirection.Vertical)//获取可见面板高度，子项对象高度
        {
            m_contentRectTransform.anchorMin = new Vector2(0.5f, 1f);
            m_contentRectTransform.anchorMax = new Vector2(0.5f, 1f);
            m_contentRectTransform.pivot = new Vector2(0.5f, 1f);

        }
        else//获取可见面板宽度，子项对象宽度
        {
            m_contentRectTransform.anchorMin = new Vector2(0f, 0.5f);
            m_contentRectTransform.anchorMax = new Vector2(0f, 0.5f);
            m_contentRectTransform.pivot = new Vector2(0f, 0.5f);
        }
        m_contentRectTransform.sizeDelta = m_visibleViewSize;
        m_contentRectTransform.anchoredPosition = Vector2.zero;
    }


    protected virtual int getCellCount()
    {
        if (m_datas == null) return 0;
        return m_datas.Length;
    }

    /// <summary>
    /// 初始化面板
    /// </summary>
    protected virtual void InitView()
    {
        m_totalCellCount = this.getCellCount();
           
        Vector2 contentSize = m_contentRectTransform.sizeDelta;
        if (m_currentDir == ViewDirection.Vertical)//设置内容面板锚点，对齐方式，纵向滑动为向上对齐
        {
            m_totalViewSize.y = m_cellSize.y * m_totalCellCount + m_GapStart + m_GapEnd + (m_totalCellCount - 1) * m_cellInterval;
            m_totalViewSize.x = m_visibleViewSize.x;
            m_totalScrollDistance = m_totalViewSize.y - m_visibleViewSize.y;

            contentSize.y = m_totalViewSize.y;
            contentSize.x = m_visibleViewSize.x;
            m_contentRectTransform.anchorMin = new Vector2(0.5f, 1f);
            m_contentRectTransform.anchorMax = new Vector2(0.5f, 1f);
            m_contentRectTransform.pivot = new Vector2(0.5f, 1f);
        }
        else//设置内容面板锚点，对齐方式，横向滑动为向左对齐
        {
            m_totalViewSize.x = m_cellSize.x * m_totalCellCount + m_GapStart + m_GapEnd + (m_totalCellCount - 1) * m_cellInterval;
            m_totalViewSize.y = m_visibleViewSize.y;
            m_totalScrollDistance = m_totalViewSize.x - m_visibleViewSize.x;

            contentSize.x = m_totalViewSize.x;
            contentSize.y = m_visibleViewSize.y;
            m_contentRectTransform.anchorMin = new Vector2(0f, 0.5f);
            m_contentRectTransform.anchorMax = new Vector2(0f, 0.5f);
            m_contentRectTransform.pivot = new Vector2(0f, 0.5f);
        }

        //设置内容面板尺寸
        m_contentRectTransform.sizeDelta = contentSize;
    }

    /// <summary>
    /// 重写ScrollRect OnValueChanged方法，此方法在每次滑动时都会被调用
    /// </summary>
    /// <param name="offset"></param>
    public virtual void OnScrollValueChanged(Vector2 offset)
    {
        CalCellIndex();
    }

    //计算可见区域子项对象开始跟结束下标
    protected virtual void CalCellIndex()
    {
        float startOffset = 0f;
        float endOffset = 0f;
        Vector2 contentOffset = new Vector2(0, 0);
        contentOffset.x = -1 * m_contentRectTransform.anchoredPosition3D.x;
        contentOffset.y = m_contentRectTransform.anchoredPosition3D.y;
       

        float cellSize = 0;
        if (m_currentDir == ViewDirection.Vertical)//纵向滑动
        {
            //当前可见区域起始y坐标
            if (contentOffset.y < 0)
                startOffset = 0;
            else
                startOffset = contentOffset.y;

            endOffset = startOffset + m_visibleViewSize.y;//当前可见区域结束y坐标

            endOffset = endOffset > m_totalViewSize.y ? m_totalViewSize.y : endOffset;
            cellSize = m_cellSize.y;
        }
        else
        {
            //当前可见区域起始x坐标
            if (contentOffset.x < 0)
                startOffset = 0;
            else
                startOffset = Mathf.Abs(contentOffset.x);
            endOffset = startOffset + m_visibleViewSize.x;//当前可见区域结束y坐标

            endOffset = endOffset > m_totalViewSize.x ? m_totalViewSize.x : endOffset;
            cellSize = m_cellSize.x;
        }

        int startIndex = Mathf.FloorToInt((startOffset - m_GapStart) / (cellSize + m_cellInterval));//子项对象开始下标
        startIndex = startIndex < 0 ? 0 : startIndex;
        int endIndex = Mathf.CeilToInt((endOffset - m_GapStart) / (cellSize + m_cellInterval));//子项对象结束下标
        endIndex = endIndex > (m_totalCellCount - 1) ? (m_totalCellCount - 1) : endIndex;

        if (startIndex == m_startIndex && endIndex == m_endIndex) return;

        m_startIndex = startIndex;
        m_endIndex = endIndex;
        UpdateCells();
    }

    protected virtual void convertStartEndIndex(ref int startIndex, ref int endIndex)
    {
    
    }


    protected virtual void freeCell(int index, GameObject cell)
    {
        m_reUseCellList.Add(cell);
    }

    //管理子项对象集合
    protected void UpdateCells()
    {
        int startIndex = m_startIndex;
        int endIndex = m_endIndex;
        this.convertStartEndIndex(ref startIndex, ref endIndex);

        List<int> delList = new List<int>();
        foreach (KeyValuePair<int, GameObject> pair in m_cells)
        {
            if (pair.Key < startIndex || pair.Key > endIndex)//回收超出可见范围的子项对象
            {
                delList.Add(pair.Key);
                freeCell(pair.Key, pair.Value);
                pair.Value.SetActive(false);
            }
        }

        //移除超出可见范围的子项对象
        foreach (int index in delList)
        {
            m_cells.Remove(index);
        }

        if(getCellCount() > 0)
        {
            //根据开始跟结束下标，重新生成子项对象
            for (int i = startIndex; i <= endIndex; i++)
            {
                GameObject cell = null;

                if (!m_cells.TryGetValue(i, out cell))
                {
                    cell = OnCellCreateAtIndex(i);
                }
                updateCellData(cell, i + 1, getCellData(i + 1));
            }
        }
  
    }

    public LuaTable getCellData( int index)
    {
        if (m_datas == null) return null;

        if (m_datas.Length >= index && index >= 1)
            return m_datas[index] as LuaTable;
        else
            return null;
    }

    protected virtual GameObject getValidCell(int index)
    {
        GameObject cell = null;
        if (m_reUseCellList.Count > 0)//有可重用子项对象时，复用之
        {
            cell = m_reUseCellList[0];
            m_reUseCellList.RemoveAt(0);
        }
        else 
        {
            cell = GameObject.Instantiate(m_cell) as GameObject;
        }
        return cell;
    }

    //创建子项对象
    public GameObject OnCellCreateAtIndex(int index)
    {
        GameObject cell = this.getValidCell( index );

        TableViewCell cellCmp = cell.GetComponent<TableViewCell>();
        if (cellCmp == null)
        {
            cellCmp = cell.AddComponent<TableViewCell>();
            if (this.m_cellClass == null)
            {
                if (this.m_updateFunc == null)
                {
                    Debug.LogError("please set cell [ lua_cell_class | cell_update func ] now is no one is valid");
                }
                else
                {
                    cellCmp.reset(this.m_updateFunc);
                }

                if (null != this.m_cellAwakFunc)
                {
                    cellCmp.setInitFunc(m_cellAwakFunc);
                    cellCmp.doInit();
                }
            }
            else
            {
                cellCmp.createLuaObject(this.m_cellClass, this.m_cellArgs);
            }
        }

        cell.transform.SetParent(m_contentRectTransform);
        cell.transform.localScale = Vector3.one;
        m_cells.Add(index, cell);

        return cell;
    }

    protected virtual Vector3 getCellPos( int index)
    {
        Vector3 pos = new Vector3(0 ,0, 0);
        if (m_currentDir == ViewDirection.Vertical)
        {
            float posY = m_GapStart + (index - 1) * (m_cellSize.y + m_cellInterval);
            pos.x = 0;
            pos.y = -posY;
            pos.z = 0;
        }
        else
        {
            float posX = m_GapStart + (index - 1) * (m_cellSize.x + m_cellInterval);
            pos.x = posX;
            pos.y = 0;
            pos.z = 0;
        }

        return pos;
    }

    protected virtual void setCellPos(GameObject cell, int index)
    {
        RectTransform cellRectTrans = cell.GetComponent<RectTransform>();
        //设置子项对象位置
        if (m_currentDir == ViewDirection.Vertical)
        {
            if (!m_keepCellSize)
                cellRectTrans.sizeDelta = new Vector2(m_visibleViewSize.x - m_cellGap * 2, cellRectTrans.sizeDelta.y);
        }
        else
        {
            if (!m_keepCellSize)
                cellRectTrans.sizeDelta = new Vector2(cellRectTrans.sizeDelta.x, m_visibleViewSize.y - m_cellGap * 2);
        }
        cellRectTrans.anchoredPosition3D = getCellPos(index);
    }
    private void updateCellData(GameObject cell, int index, LuaTable data)
    {
        RectTransform cellRectTrans = cell.GetComponent<RectTransform>();
        if (m_currentDir == ViewDirection.Vertical)
        {
            cellRectTrans.anchorMin = new Vector2(0.5f, 1f);
            cellRectTrans.anchorMax = new Vector2(0.5f, 1f);
            cellRectTrans.pivot = new Vector2(0.5f, 1f);
            
        }
        else
        {
            cellRectTrans.anchorMin = new Vector2(0f, 0.5f);
            cellRectTrans.anchorMax = new Vector2(0f, 0.5f);
            cellRectTrans.pivot = new Vector2(0f, 0.5f);

        }

        this.setCellPos(cell, index);

        cell.SetActive(true);
        cell.transform.SetAsLastSibling();

        TableViewCell tvcell = cell.GetComponent<TableViewCell>();
        tvcell.UpdateCell(index, data, m_forceUpdate);
    }

    private void Awake()
    {
        InitComponent();
        ScrollRect rect = this.GetComponent<ScrollRect>();

        int count = rect.onValueChanged.GetPersistentEventCount();
        if (count <= 0)
        {
            rect.onValueChanged.AddListener(this.OnScrollValueChanged);
        }
        else
        {
            bool isFindMethod = false;
            for( int i = 0; i < count; i++)
            {
                var target = rect.onValueChanged.GetPersistentTarget(i);
                String methodName = rect.onValueChanged.GetPersistentMethodName(i);
                if (methodName == "OnScrollValueChanged" && target == this)
                { 
                    isFindMethod = true;
                    break;
                }
            }
            if(!isFindMethod)
            {
                rect.onValueChanged.AddListener(this.OnScrollValueChanged);
            }
        }
    }

    public void setCellClass(LuaTable cellclass, LuaTable cellArgs)
    {
        m_cellClass = cellclass;
        m_cellArgs = cellArgs;
    }

    public void setUpdateCellFunc( LuaFunction updateFunc)
    {
        m_updateFunc = updateFunc;
    }

    public void setCellAwakFunc( LuaFunction cellAwakFunc)
    {
        m_cellAwakFunc = cellAwakFunc;
    }
    public virtual void setData(LuaTable datas)
    {
        m_datas = datas;
    }


    public virtual void reloadData(bool keepOffset = false, bool forceUpdate = false)
    {
        m_startIndex = -1;
        m_endIndex = -1;
        m_forceUpdate = forceUpdate;
        InitView();
        if (!keepOffset)
        {
            m_contentRectTransform.anchoredPosition = Vector2.zero;
        }
        CalCellIndex();
        m_forceUpdate = false;
    }
}
