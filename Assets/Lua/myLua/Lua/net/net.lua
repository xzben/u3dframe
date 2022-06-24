net = {}

net.pb_cmd = require "net.pb_cmd"

net.C2S = net.pb_cmd.C2S
net.S2C = net.pb_cmd.S2C

net.proto_register = require "net.proto_register"
net.network = create_instance("net.network")
