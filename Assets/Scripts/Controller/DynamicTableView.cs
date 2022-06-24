using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DynamicTableView : TableView
{
    public GameObject[] m_other_cell_items = null;
    private LuaFunction m_func_get_cell_size = null;
    private LuaFunction m_func_get_cell_type_index = null;
    private Dictionary<int, float> m_cell_pos_map = null;
    private Dictionary<int, float> m_cell_size_map = null;
    private Dictionary<int, int> m_cell_type_map = null;

    private Dictionary<int, List<GameObject>> m_freeCellList = null;

    public void SetCellSizeFunc(LuaFunction func)
    {
        m_func_get_cell_size = func;
    }

    public void SetCellTypeIndex(LuaFunction func)
    {
        m_func_get_cell_type_index = func;
    }

    private float getCellSize(int index, LuaTable data)
    {
        if (m_func_get_cell_size == null) return 0.0f;

        float size = m_func_get_cell_size.Invoke<int, LuaTable, float>(index, data);

        return size;
    }

    private int getCellTypeIndex(int index, LuaTable data)
    {
        if (m_func_get_cell_type_index == null) return 0;
        
        int type_index = m_func_get_cell_type_index.Invoke<int, LuaTable, int>(index, data);

        return type_index;
    }

    private GameObject getCellPrefab(int typeIndex)
    {
        if (typeIndex == 0) return m_cell;
        if(typeIndex > m_other_cell_items.Length)
        {
            Debug.LogError("type index error:" + typeIndex + " max index is:" + m_other_cell_items.Length);
        }
        return m_other_cell_items[typeIndex - 1];
    }

    private GameObject getFreeCellItem(int typeIndex)
    {
        List<GameObject> list = null;
        GameObject ret = null;

        if (!m_freeCellList.TryGetValue(typeIndex, out list))
        {
            return null;
        }

        if(list.Count > 0)
        {
            ret = list[0];
            list.RemoveAt(0);
        }

        return ret;
    }

    protected override void freeCell(int index, GameObject cell)
    {
        int typeIndex = m_cell_type_map[index];

        List<GameObject> list = null;
        if( !m_freeCellList.TryGetValue(typeIndex, out list))
        {
            list = new List<GameObject>();
            m_freeCellList.Add(typeIndex, list);
        }

        list.Add(cell);
    }

    public override void InitComponent()
    {
        base.InitComponent();
        m_cell_pos_map = new Dictionary<int, float>();
        m_cell_size_map = new Dictionary<int, float>();
        m_cell_type_map = new Dictionary<int, int>();
        m_freeCellList = new Dictionary<int, List<GameObject>>();
    }
    protected override void InitView()
    {
        if(m_func_get_cell_size == null)
        {
            Debug.LogError("请设置一个有效的func获取cell size");
            return;
        }

        m_totalCellCount = this.getCellCount();

        float totalCellSize = 0;
        float pos = m_GapStart;

        for(int i = 0; i < m_totalCellCount ; i++)
        {
            int index = i + 1;
            LuaTable data = getCellData(index);
            float size = getCellSize(index, data);
            int typeIndex = getCellTypeIndex(index, data);

            m_cell_size_map[i] = size;
            m_cell_pos_map[i] = pos;
            m_cell_type_map[i] = typeIndex;
            pos += size + m_cellInterval;
            totalCellSize += size;
        }

        m_cell_pos_map[m_totalCellCount] = pos;

        Vector2 contentSize = m_contentRectTransform.sizeDelta;
        if (m_currentDir == ViewDirection.Vertical)//设置内容面板锚点，对齐方式，纵向滑动为向上对齐
        {
            m_totalViewSize.y = totalCellSize + m_GapStart + m_GapEnd + (m_totalCellCount - 1) * m_cellInterval;
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
            m_totalViewSize.x = totalCellSize + m_GapStart + m_GapEnd + (m_totalCellCount - 1) * m_cellInterval;
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

    protected override GameObject getValidCell(int index)
    {
        int typeIndex = m_cell_type_map[index];
        GameObject cell = getFreeCellItem(typeIndex);
        if(cell == null)
        {
            GameObject prefab = getCellPrefab(typeIndex);
            cell = GameObject.Instantiate(prefab) as GameObject;
        }

        return cell;
    }

    private int indexFromOffset(float offset)
    {
        int low = 0;
        int count = this.getCellCount();
        int high = count - 1;
        float search = offset;

        while(high >= low)
        {
            int index = low + (high - low) / 2;
            float cellStart = m_cell_pos_map[index];
            float cellEnd = m_cell_pos_map[index + 1];

            if(search >= cellStart && search <= cellEnd)
            {
                return index;
            }
            else if(search < cellStart)
            {
                high = index - 1;
            }
            else
            {
                low = index + 1;
            }
        }

        if (low <= 0)
            return 0;

        if (low >= count - 1)
            return count - 1;

        return -1;
    }
    protected override void CalCellIndex()
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
        }

        int startIndex = indexFromOffset(startOffset);//子项对象开始下标
        int endIndex = indexFromOffset(endOffset); ;//子项对象结束下标
        
        if (startIndex == m_startIndex && endIndex == m_endIndex) return;

        m_startIndex = startIndex;
        m_endIndex = endIndex;
        UpdateCells();
    }

    protected override Vector3 getCellPos(int index)
    {
        Vector3 pos = new Vector3(0, 0, 0);

        if (m_currentDir == ViewDirection.Vertical)
        {
            pos.x = 0;
            pos.y = -1*m_cell_pos_map[index-1];
            pos.z = 0;
        }
        else
        {
            float posX = m_GapStart + (index - 1) * (m_cellSize.x + m_cellInterval);
            pos.x = m_cell_pos_map[index-1];
            pos.y = 0;
            pos.z = 0;
        }

        return pos;
    }

    protected override void setCellPos(GameObject cell, int index)
    {
        RectTransform cellRectTrans = cell.GetComponent<RectTransform>();
        float size = m_cell_size_map[index-1];

        //设置子项对象位置
        if (m_currentDir == ViewDirection.Vertical)
        {
            if (!m_keepCellSize)
                cellRectTrans.sizeDelta = new Vector2(m_visibleViewSize.x - m_cellGap * 2, size);
            else
                cellRectTrans.sizeDelta = new Vector2(cellRectTrans.sizeDelta.x, size);
        }
        else
        {
            if (!m_keepCellSize)
                cellRectTrans.sizeDelta = new Vector2(size, cellRectTrans.sizeDelta.y);
        }

        cellRectTrans.anchoredPosition3D = getCellPos(index);
    }
}
