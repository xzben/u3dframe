
namespace LuaFramework {
    public class Protocal {
        ///BUILD TABLE
        public const int Connect = 1;     //连接服务器
        public const int Exception = 2;     //异常掉线
        public const int Disconnect = 3;     //正常断线 
        public const int ConnectFailed = 4; //连接失败
        public const int Message = 5; //socket消息
    }
}