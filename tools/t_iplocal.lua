#!/usr/bin/env lua
local ip = arg[1]
local qqwry = require("qqwry")

local function uses()
	print("Uses : t-iplocal ipadrss\ne.g.:# t_iplocal.lua 192.168.0.1")
	os.exit()
end

if not ip then
	print("please input query ip.")
	uses()
end

if ip:match("(%-+h)") then
	uses()
elseif ip == "-v" then
	print( table.concat(qqwry.version())  )
else
	print( table.concat(qqwry.query(ip)) )
end
