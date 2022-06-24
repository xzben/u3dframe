using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LuaFramework {
    public class NetworkManager : Manager
    {
        private SocketClient m_socket;
        static readonly object m_lockObject = new object();
        static Queue<KeyValuePair<int, ByteBuffer>> mEvents = new Queue<KeyValuePair<int, ByteBuffer>>();

        SocketClient SocketClient
        {
            get
            {
                if (m_socket == null)
                    m_socket = new SocketClient();
                return m_socket;
            }
        }

        private void Awake()
        {
            Init();
        }

        void Init()
        {
            SocketClient.OnRegister();
        }

        ///------------------------------------------------------------------------------------
        public static void AddEvent(int _event, ByteBuffer data)
        {
            lock (m_lockObject)
            {
                mEvents.Enqueue(new KeyValuePair<int, ByteBuffer>(_event, data));
            }
        }

        void Update()
        {
            if (mEvents.Count > 0)
            {
                while (mEvents.Count > 0)
                {
                    KeyValuePair<int, ByteBuffer> _event = mEvents.Dequeue();

                    AppEventManager.OnSocketEvent(_event.Key, _event.Value);
                }
            }
        }

        public void SendConnect(string ip, int port)
        {
            SocketClient.SendConnect(ip, port);
        }

        public void Close()
        {
            SocketClient.Close();
        }

        public void Reset()
        {
            this.Close();
            mEvents.Clear();
        }

        public void SendMessage(ByteBuffer buffer)
        {
            SocketClient.SendMessage(buffer);
        }

        public void SendMessage(LuaByteBuffer buffer)
        {
            SocketClient.SendMessage(buffer);
        }
        void OnDestroy()
        {
            SocketClient.OnRemove();
            Debug.Log("~NetworkManager was destroy");
        }
    }
}


