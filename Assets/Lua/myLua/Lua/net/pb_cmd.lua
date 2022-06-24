local PbCmd = {}

-------------- C2S ----------------------------

PbCmd.C2S = {}
PbCmd.C2S.HEART = 100    	--//--心跳
PbCmd.C2S.LOGIN = 101	   	--//--登录

-------------- S2C ----------------------------
PbCmd.S2C = {}
PbCmd.S2C.SESSION 		= 1		  	--//--收包确认
PbCmd.S2C.ERROR 		= 2 	  	--错误消息
PbCmd.S2C.LOGIN_OTHER 	= 3 	  	--//--其它地方登陆了
PbCmd.S2C.HEART 		= 100    	--//--心跳收报
PbCmd.S2C.LOGIN 		= 101 	  	--//--登录返回
PbCmd.S2C.REAL_AUTH				= 102; 	  --玩家实名认证

return PbCmd