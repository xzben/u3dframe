using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridView : TableView
{
    public int m_fixedCount = 1;
    private float m_grideSideGap = 0;
    public float m_grideGap = 0;
    
    private int m_count = 0;  // 垂直滚动代表多少 列，水平滚动代表多少行
    private float m_cell_length = 0; //cell的长度
    public override void InitComponent()
    {
        base.InitComponent();
        m_grideSideGap = m_cellGap;
        if ( m_keepCellSize )
        {
            float length;
            float cell_length;

            if (m_currentDir == ViewDirection.Vertical)
            {
                length = m_visibleViewSize.x;
                cell_length = m_cellSize.x;
            }
            else
            {   
                length = m_visibleViewSize.y;
                cell_length = m_cellSize.y;
            }

            int count = Mathf.FloorToInt((length - 2 * m_grideSideGap + m_grideGap) / (cell_length + m_grideGap));
            float use_length = count * cell_length + (count - 1) * m_grideGap + 2 * m_grideSideGap;
            float remain_length = length - use_length;

            float add_length = remain_length / (count - 1 + 2);

            m_grideSideGap += add_length;
            m_grideGap += add_length;
            m_count = count;
            m_cell_length = cell_length;
        }
        else
        {
            float length;

            if (m_currentDir == ViewDirection.Vertical)
            {
                length = m_visibleViewSize.x;
            }
            else
            {
                length = m_visibleViewSize.y;
            }

            m_count = m_fixedCount;
            m_cell_length = (length - 2*m_grideSideGap - (m_count - 1) * m_grideGap)/m_count;
        }
    }
    protected override int getCellCount()
    {
        int size = m_datas.Length;

        if (size == 0) return 0;

        int count = Mathf.CeilToInt((size - 1) / m_count) + 1;

        return count;
    }

    protected override void convertStartEndIndex(ref int startIndex, ref int endIndex)
    {
        int size = m_datas.Length - 1;

        startIndex = startIndex*m_count;
        endIndex = (endIndex + 1) * m_count - 1;

        if (startIndex < 0) startIndex = 0;
        if (startIndex > size) startIndex = size;
        if (endIndex > size) endIndex = size;
    }

    protected override Vector3 getCellPos(int index)
    {
        Vector3 pos = new Vector3(0, 0, 0);
        if (m_currentDir == ViewDirection.Vertical)
        {
            int row = (index - 1) / m_count + 1;
            int col = index - m_count * (row - 1);

            float posY = m_GapStart + (row - 1) * (m_cellSize.y + m_cellInterval);
            float posX = m_grideSideGap + (col - 1) * (m_grideGap + m_cell_length) + m_cell_length / 2 - m_visibleViewSize.x / 2;
    
            pos.x = posX;
            pos.y = -posY;
            pos.z = 0;
        }
        else
        {
            int col = (index - 1) / m_count + 1;
            int row = index - (col - 1) * m_count;

            float posX = m_GapStart + (col - 1) * (m_cellSize.x + m_cellInterval);
            float posY = m_visibleViewSize.y / 2 - (m_grideSideGap + (row - 1) * (m_grideGap + m_cell_length) + m_cell_length / 2);

            pos.x = posX;
            pos.y = posY;
            pos.z = 0;
        }

        return pos;
    }

    protected override void setCellPos(GameObject cell, int index)
    {
        RectTransform cellRectTrans = cell.GetComponent<RectTransform>();

        //设置子项对象位置
        if (m_currentDir == ViewDirection.Vertical)
        {
            if (!m_keepCellSize)
            {
                cellRectTrans.sizeDelta = new Vector2(m_cell_length, cellRectTrans.sizeDelta.y);
            }
        }
        else
        {
            if (!m_keepCellSize)
                cellRectTrans.sizeDelta = new Vector2(cellRectTrans.sizeDelta.x, m_cell_length);
        }
        cellRectTrans.anchoredPosition3D = getCellPos(index);
    }
}
