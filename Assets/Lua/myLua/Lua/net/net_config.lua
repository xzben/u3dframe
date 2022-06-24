local PbCmd = require("net.pb_cmd")
local netConfig = {}

------------------------------------------------------
netConfig.C2S = {}

netConfig.C2S[PbCmd.C2S.HEART] 				= { message = "common.Heart";  };
netConfig.C2S[PbCmd.C2S.LOGIN] 				= { message = "normal.LoginReq"; };

---------------------------------------------------
netConfig.S2C = {}

netConfig.S2C[PbCmd.S2C.SESSION] 		= { message = "common.Emtpy" };
netConfig.S2C[PbCmd.S2C.ERROR] 			= { message = "common.Error" };
netConfig.S2C[PbCmd.S2C.HEART] 			= { message = "common.Heart" };
netConfig.S2C[PbCmd.S2C.LOGIN_OTHER] 	= { message = "common.Emtpy" };
netConfig.S2C[PbCmd.S2C.LOGIN] 			= { message = "normal.LoginResp" };

return netConfig