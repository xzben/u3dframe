using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ZorderManager
{
    public class ZOrderNode : MonoBehaviour
    {
        private int m_globalZorder = -1;  // 设置了全局zorder 则就不在需要统一管理了
        private int m_localZorder = 0;         // 真实当前的local zorder

        public int localZorder = 0;     //提供给编辑器使用
        public bool m_isRoot = false;
        public int  m_beginZorder = 0;
        public int  m_endZorder = 0;

        private List<ZOrderNode> m_childs = new List<ZOrderNode>();
        private ZOrderNode m_parent = null;
        private Canvas m_canvas = null;
        private ZOrderNode m_root = null;

        public void SetRoot(int beginOrder, int endOrder)
        {
            m_isRoot = true;
            m_beginZorder = beginOrder;
            m_endZorder = endOrder;
            localZorder = m_beginZorder;
            m_localZorder = m_beginZorder;
            updateNodeZorder(m_beginZorder);
        }

        public void updateRootChildZorders()
        {
            if (!isRoot()) return;

            setChildsZorders(m_beginZorder);
        }

        public bool isRoot()
        {
            return m_isRoot;
        }

        public ZOrderNode getParent()
        {
            return m_parent;
        }

        public int getZorder()
        {
            return m_localZorder;
        }

        public List<ZOrderNode> getChilds()
        {
            return m_childs;
        }

        public void  addChild(ZOrderNode node)
        {
            if(!m_childs.Contains(node))
                m_childs.Add(node);
        }

        public void removeChild(ZOrderNode node)
        {
            if (!m_childs.Contains(node)) return;
            m_childs.Remove(node);
        }

        private ZOrderNode getZorderRoot()
        {
            if (m_root != null) return m_root;
            Transform parent = gameObject.transform.parent;
            ZOrderNode curChild = this;
            ZOrderNode root = null;

            while (root == null && parent != null)
            {
                ZOrderNode node = parent.GetComponent<ZOrderNode>();
                if(node == null)
                {
                    node = parent.gameObject.AddComponent<ZOrderNode>();
                }

                if (node.isRoot())
                    root = node;

                curChild.DetachFromParent();
                node.addChild(curChild);
                curChild.m_parent = node;
                curChild = node;
                parent = parent.parent;
            }

            m_root = root;

            return root;
        }

        private void Awake()
        {
        }

        public void SetLocalZOrder(int zorder)
        {
            ZOrderNode root = getZorderRoot();
            m_localZorder = zorder;
            localZorder = zorder;

            if (root)
                root.updateRootChildZorders();
        }

        public void SetGlobalZOrder(int zorder)
        {
            ZOrderNode root = getZorderRoot();
            m_globalZorder = zorder;

            if(root)
                root.updateRootChildZorders();
            else
                updateNodeZorder(m_globalZorder);
        }

        public int getChildMaxLocalZorder()
        {
            int zorder = 0;
            foreach (ZOrderNode node in m_childs)
            {
                if(node.m_localZorder > zorder)
                {
                    zorder = node.m_localZorder;
                }
            }

            return zorder;
        }
        public void ResetRoot()
        {
            m_root = null;
        }

        public void SetToCurMaxLocalZorder()
        {
            ZOrderNode root = getZorderRoot();
            if (root == null) return;

            int maxZorder = 0;
            if (m_parent)
                maxZorder = m_parent.getChildMaxLocalZorder();
            m_localZorder = maxZorder;
            localZorder = maxZorder;

            root.updateRootChildZorders();
        }

        public void DetachFromParent()
        {
            if( m_parent)
            {
                m_parent.removeChild(this);
                m_parent = null;
            }

            if(m_root)
            {
                m_root.updateRootChildZorders();
            }

        }

        public bool isSetGlobal()
        {
            return m_globalZorder != -1;
        }

        public void clearGlobalZorder()
        {
            m_globalZorder = -1;
            this.SetLocalZOrder(m_localZorder);
        }

        public void SortChildByZorders()
        {
            m_childs.Sort(delegate (ZOrderNode node1, ZOrderNode node2)
            {
                int zorder1 = node1.getZorder();
                int zoder2 = node2.getZorder();

                return zorder1.CompareTo(zoder2);
            });
        }

        public int setChildsZorders(int beginZorder)
        {
            SortChildByZorders();
            int zorder = beginZorder;
            foreach (ZOrderNode node in m_childs)
            {
                if(!node.isSetGlobal())
                {
                    zorder++;
                    node.updateNodeZorder(zorder);
                    zorder = node.setChildsZorders(zorder);
                }
                else
                {
                    node.updateNodeZorder(node.m_globalZorder);
                    node.setChildsZorders(node.m_globalZorder);
                }
            }

            return zorder;
        }

        public void updateNodeZorder(int zorder)
        {
            Canvas canvas = GetCanvas();
            canvas.overrideSorting = true;
            canvas.sortingOrder = zorder;
        }

        public Canvas GetCanvas()
        {
            if(m_canvas == null)
            {
                m_canvas = gameObject.GetComponent<Canvas>();
                if (m_canvas == null)
                {
                    m_canvas = gameObject.AddComponent<Canvas>();
                    gameObject.AddComponent<UnityEngine.UI.GraphicRaycaster>();
                }
            }

            return m_canvas;
        }

        // Update is called once per frame
        public virtual void Update()
        {
            if(localZorder != m_localZorder)
            {
                SetLocalZOrder(localZorder);
            }
        }

        private void OnDestroy()
        {
            DetachFromParent();
        }
    }
}