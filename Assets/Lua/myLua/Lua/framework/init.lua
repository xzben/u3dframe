require("framework.functions.class")
require("framework.functions.help")

framework = {}
createAutoRequire(framework, require, {
	mvp = "framework.mvp";
})

log = require("framework.log.log")
utils = require("framework.utils.utils")
