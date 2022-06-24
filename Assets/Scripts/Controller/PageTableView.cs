using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.UI;

public class PageTableView : TableView
{
    // Start is called before the first frame update
    public float m_stepOffset = 0.5f;
    public int m_maxStep = 5;
    public float m_startLoadingLength = 100;
    public bool m_needPageUpLoad = true;
    public bool m_needPageDonwLoad = true;
    public string m_loadingTips = "数据加载中";
    public GameObject m_loadNodePrefab = null;
    public Font m_loadFont = null;
    public Color m_fontColor = new Color(255, 255, 255, 255);
    
    private GameObject m_loadingNode = null;
    private bool m_addedUpLoading = false;
    private bool m_addedDownLoading = false;
    private float m_startAddGap = 0;
    private float m_endAddGap = 0;
    private LuaFunction m_doLoadCallback = null;
    private float m_costTime = 0.5f;
    private int m_step = 0;
    private int m_lastDataSize = 0;
    private int m_dataChangeSize = 0;
    private bool m_flagClearLoading = false;
    private LuaFunction m_updateLoadFunc = null;
    private RectTransform m_viewPort = null;

    public override void InitComponent()
    {
        base.InitComponent();
        m_viewPort = m_scrollRect.viewport;
        m_costTime = m_stepOffset;
        if (m_startLoadingLength < 50)
            m_startLoadingLength = 50;
    }

    private float getLoadingNodeLength()
    {
        float loadingNodeLength = 0;
        if (m_loadingNode && m_loadingNode.activeSelf)
        {
            RectTransform transform = m_loadingNode.GetComponent<RectTransform>();
            if (m_currentDir == ViewDirection.Horizontal)
            {
                loadingNodeLength = transform.sizeDelta.x;
            }
            else
            {
                loadingNodeLength = transform.sizeDelta.y;
            }
        }

        return loadingNodeLength;
    }

    private void clearAddGap()
    {
        if (m_startAddGap > 0)
            m_GapStart -= m_startAddGap;
        if (m_endAddGap > 0)
            m_GapEnd -= m_endAddGap;

        m_GapStart = m_GapStart < 0 ? 0 : m_GapStart;
        m_GapEnd = m_GapEnd < 0 ? 0 : m_GapEnd;
        m_startAddGap = 0;
        m_endAddGap = 0;
    }

    private void clearLoadingNode()
    {
        if (m_loadingNode)
        {
            m_loadingNode.SetActive(false);
        }
        clearAddGap();
        m_addedDownLoading = false;
        m_addedUpLoading = false;
    }


    private RectTransform createLoadingNode(bool isDown)
    {
        RectTransform transform = null;
        if (m_loadingNode == null)
        {
            if(m_loadNodePrefab == null)
            {
                m_loadingNode = new GameObject();
                m_loadingNode.name = "loadingNode";
                transform = m_loadingNode.AddComponent<RectTransform>();
                m_loadingNode.AddComponent<Text>();
                Text text = m_loadingNode.GetComponent<Text>();
                text.fontSize = 20;
                text.text = getLoadingText(0);
                text.font = m_loadFont;
                text.fontSize = 30;
                text.alignment = TextAnchor.MiddleCenter;
                text.color = m_fontColor;
                if (m_currentDir == ViewDirection.Vertical)
                    transform.sizeDelta = new Vector2(m_visibleViewSize.x, 50);
                else
                    transform.sizeDelta = new Vector2(50, m_visibleViewSize.y);
            }
            else
            {
                m_loadingNode = GameObject.Instantiate(m_loadNodePrefab);
                transform = m_loadingNode.GetComponent<RectTransform>();
                Vector2 oldSize = transform.sizeDelta;
                if (m_currentDir == ViewDirection.Vertical)
                    transform.sizeDelta = new Vector2(m_visibleViewSize.x, oldSize.y);
                else
                    transform.sizeDelta = new Vector2(oldSize.x, m_visibleViewSize.y);

                doCallUpdateNode(true, 0);
            }
        }
        else
        {
            transform = m_loadingNode.GetComponent<RectTransform>();
        }
        
        transform.SetParent(m_viewPort);
        float x = 0f;
        float y = 0f;

        if (m_currentDir == ViewDirection.Vertical)
        {
            if (isDown)
            {
                transform.anchorMin = new Vector2(0.5f, 0f);
                transform.anchorMax = new Vector2(0.5f, 0f);
                transform.pivot = new Vector2(0.5f, 0f);
            }
            else
            {
                transform.anchorMin = new Vector2(0.5f, 1f);
                transform.anchorMax = new Vector2(0.5f, 1f);
                transform.pivot = new Vector2(0.5f, 1f);
            }
        }
        else
        {
            if (isDown)
            {
                transform.anchorMin = new Vector2(1, 0.5f);
                transform.anchorMax = new Vector2(1, 0.5f);
                transform.pivot = new Vector2(1, 0.5f);
            }
            else
            {
                transform.anchorMin = new Vector2(0, 0.5f);
                transform.anchorMax = new Vector2(0, 0.5f);
                transform.pivot = new Vector2(0, 0.5f);
            }
        }
        transform.anchoredPosition3D = new Vector3(0f, 0f, 0f);
        transform.localScale = new Vector3(1f, 1f, 1f);
        
        if(m_doLoadCallback != null)
        {
            m_doLoadCallback.BeginPCall();
            m_doLoadCallback.Push(isDown);
            m_doLoadCallback.PCall();
            m_doLoadCallback.EndPCall();
        }
        return transform;
    }

    protected override void CalCellIndex()
    {
        checkAddLoading();
        base.CalCellIndex();
    }

    private void checkAddLoading()
    {
        if (!m_needPageDonwLoad && !m_needPageUpLoad) return;

        float startOffset = 0f;
        float endOffset = 0f;

        bool pageDownOver = false;
        bool pageUpOver = false;

        Vector2 contentOffset = new Vector2(0, 0);
        contentOffset.x = -1 * m_contentRectTransform.anchoredPosition3D.x;
        contentOffset.y = m_contentRectTransform.anchoredPosition3D.y;

        if (m_currentDir == ViewDirection.Vertical)//纵向滑动
        {
            //当前可见区域起始y坐标
            if (contentOffset.y < 0)
            {
                startOffset = 0;
                if(Mathf.Abs(contentOffset.y ) > m_startLoadingLength)
                    pageUpOver = true;
            }
            else
            {
                startOffset = contentOffset.y;
            }

            float addLength = Mathf.Min(m_totalViewSize.y, m_visibleViewSize.y);
            endOffset = startOffset + addLength;//当前可见区域结束y坐标

            if (endOffset > m_totalViewSize.y)
            {
                if(Mathf.Abs(endOffset - m_totalViewSize.y) > m_startLoadingLength)
                    pageDownOver = true;
            }
        }
        else
        {
            //当前可见区域起始x坐标
            if (contentOffset.x < 0)
            {
                startOffset = 0;
                if( Mathf.Abs(contentOffset.x) > m_startLoadingLength)
                    pageUpOver = true;
            }
            else
            {
                startOffset = Mathf.Abs(contentOffset.x);
            }

            float addLength = Mathf.Min(m_totalViewSize.x, m_visibleViewSize.x);
            endOffset = startOffset + addLength;//当前可见区域结束y坐标

            if (endOffset > m_totalViewSize.x)
            {
                if( Mathf.Abs(endOffset - m_totalViewSize.x) > m_startLoadingLength)
                    pageDownOver = true;
            }
        }

        bool isHaveLoding = false;
        if(pageUpOver && m_needPageUpLoad)
        {
            isHaveLoding = addPageUpOverLoading();
        }

        if (pageDownOver && m_needPageDonwLoad)
        {
            isHaveLoding = addPageDownOverLoading();
        }
        
        if(isHaveLoding)
        {
            this.InitView();
            m_startIndex = -1;
            m_endIndex = -1;
        }
        else
        {
            
        }
    }
    private bool addPageUpOverLoading()
    {
        if (m_addedUpLoading)
        {
            return false;
        }
        RectTransform transform = createLoadingNode(false);
        transform.gameObject.SetActive(true);
        m_addedUpLoading = true;
        if(m_startAddGap <= 0)
        {
            m_startAddGap = getLoadingNodeLength();
            m_GapStart += m_startAddGap;
        }

        return true;
    }

    private bool addPageDownOverLoading()
    {
        if (m_addedDownLoading) return false; ;
        RectTransform transform = createLoadingNode(true);
        transform.gameObject.SetActive(true);
        m_addedDownLoading = true;
        if (m_endAddGap <= 0)
        {
            m_endAddGap = getLoadingNodeLength();
            m_GapEnd += m_endAddGap;
        }

        return true;

    }

    private string getLoadingText(int step)
    {
        string str = m_loadingTips;

        if (m_currentDir == ViewDirection.Horizontal)
        {
            for (int i = 1; i <= step; i++)
            {
                str += ".\r\n";
            }

            return str;
        }
        else
        {
            for (int i = 1; i <= step; i++)
            {
                str += ".";
            }

            return str;
        }
    }

    private void doCallUpdateNode(bool isInit, float deltaTime)
    {
        if(m_updateLoadFunc!= null)
        {
            m_updateLoadFunc.BeginPCall();
            m_updateLoadFunc.Push(m_loadingNode);
            m_updateLoadFunc.Push(isInit);
            m_updateLoadFunc.Push(deltaTime);
            m_updateLoadFunc.PCall();
            m_updateLoadFunc.EndPCall();
        }
    }
    private void Update()
    {
        if (m_loadingNode == null) return;

        if(m_updateLoadFunc != null)
        {
            doCallUpdateNode(false, Time.deltaTime);
        }

        if(m_loadNodePrefab == null)
        {
            if (m_loadingNode && m_loadingNode.activeSelf)
            {
                m_costTime -= Time.deltaTime;
                if (m_costTime <= 0)
                {
                    m_costTime = m_stepOffset;
                    m_step++;
                    if (m_step > m_maxStep) m_step = 0;

                    Text text = m_loadingNode.GetComponent<Text>();
                    if (text)
                    {
                        text.text = getLoadingText(m_step);
                    }
                }
            }
        }
       
    }

    public bool isFullShow()
    {
        if(m_currentDir == ViewDirection.Vertical)
        {
            return m_totalViewSize.y > m_visibleViewSize.y;
        }
        else
        {
            return m_totalViewSize.x > m_visibleViewSize.x;
        }
    }
    public void setUpdateNodeFunc(LuaFunction func)
    {
        m_updateLoadFunc = func;
    }
    public override void reloadData(bool keepOffset = false, bool forceUpdate = false)
    {
        clearAddGap();
        bool fullshow = isFullShow();
        InitView();

        bool changePos = false;
        Vector3 newPos = m_contentRectTransform.anchoredPosition3D;
        if (!keepOffset)
        {
            newPos = Vector2.zero;
        }
        else if(m_addedUpLoading && m_dataChangeSize > 0 && fullshow)
        {
            if(m_currentDir == ViewDirection.Vertical)
            {
                float changeLenght = m_dataChangeSize * (m_cellSize.y + m_cellInterval);
                float loadNodeLength = getLoadingNodeLength();
                newPos.y += changeLenght - loadNodeLength;
            }
            else
            {
                float changeLenght = m_dataChangeSize * (m_cellSize.x + m_cellInterval);
                float loadNodeLength = getLoadingNodeLength();
                newPos.x -= changeLenght - loadNodeLength;
            }
        }

        if (newPos != m_contentRectTransform.anchoredPosition3D)
        {
            m_contentRectTransform.anchoredPosition3D = newPos;
            changePos = true;
        }

        m_startIndex = -1;
        m_endIndex = -1;
        if (!changePos)
            CalCellIndex();
        clearLoadingNode();
    }
    public override void setData(LuaTable datas)
    {
        m_dataChangeSize = datas.Length - m_lastDataSize; 
        m_lastDataSize = datas.Length;
        base.setData(datas);
    }

    public void setDoLoadCallback(LuaFunction callback)
    {
        m_doLoadCallback = callback;
    }
}
