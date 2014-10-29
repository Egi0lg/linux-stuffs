#!/usr/bin/env lua
local qqwry = require("qqwry")

if arg[1] and arg[1]:match("(%-+h)") then
	local help_message = [=[This script descript how many connect from outside to localhost on specific port.
The following description, between [] are option, between () are the default value of the option, | is "or".

Uses: t-allconnectsfromoutside [port [(80)] | locahost_ip:port [192.168.0.103:80 | 102:80]]  [is_analyze [(on)|off]]  [the_anaylze_print_type [(ip)|des]]

There are only showing 30 analyzed records by default, If you want show all analyzed records, add "-all" option at the any place that should be option.
e.g.: t-allconnectsfromoutside -all 80 on ip
      t-allconnectsfromoutside 80 on des -all
]=]
	print(help_message)
	os.exit()
end

local PORT,IS_ANALYZE,PRINT_TYPE
local ONLYSHOW30 = "on"
for i=1,#arg do
	if arg[i] == "-all" then
		ONLYSHOW30="off"
	else
		if not PORT then
			PORT = arg[i] or "80"
		elseif not IS_ANALYZE then
			IS_ANALYZE =  arg[i] or "on"   --> is analyze the data , "on" or "off"
		elseif not PRINT_TYPE then
			PRINT_TYPE = arg[i] or "ip" 	--> PRINT_TYPE is "ip" or "des"
		end
	end
end
PORT = PORT or "80"
IS_ANALYZE =  IS_ANALYZE or "on"
PRINT_TYPE =  PRINT_TYPE or "ip"

local TMPDIR = os.getenv("TMPDIR") or "/tmp/"
if TMPDIR:sub(-1) ~= "/"  then TMPDIR = TMPDIR .. "/" end

local TMPFILE = TMPDIR .. "t_all_connects_from_outside_tmp"
local command = 'lsof -nPi:' .. ( PORT:match(":(%d+)") or PORT ) .. ' | grep "' .. PORT .. '\\->" > ' .. TMPFILE   -->    """" lsof -nPi:80 | grep ":80\->" > TMPFILE  """
--print(command)
os.execute(command)

local d_index = {}
local data = { t_ip={}, t_des={} }
local sum = 0

qqwry.open()
for line in io.lines(TMPFILE) do
		local ip = line:match(":%d+%->([%w%.]+):") ; ip_index = d_index[ip]
		local ip_des =  table.concat(qqwry.get(ip),"-") ; ip_des_index = d_index[ip_des]
		sum = sum + 1

		if IS_ANALYZE ~= "on" then
			print( line .. " " ..ip_des)
		else
			if not  ip_index then
			    ip_index  = #data.t_ip + 1
			    d_index[ip] = ip_index
			end

			if not ip_des_index then
			    ip_des_index = #data.t_des + 1
			    d_index[ip_des] = ip_des_index
			end

			if not data.t_ip[ip_index] then
			    data.t_ip[ip_index] =  { ip=ip, des=ip_des, c=1 }
			else
			    data.t_ip[ip_index].c = data.t_ip[ip_index].c + 1
			end

			if not data.t_des[ip_des_index] then
			    data.t_des[ip_des_index] =  { des=ip_des, c=1 }
			else
			    data.t_des[ip_des_index].c = data.t_des[ip_des_index].c + 1
			end
		end
end
qqwry.close()
os.remove(TMPFILE)
d_index=nil


print( ("="):rep(60) )
print( ("totally have [ %d ] connects from outside."):format(sum) )
print( ("="):rep(60) )


if IS_ANALYZE ~= "on" then
	os.exit()
end

local function desc(a,b) return a.c > b.c end
table.sort(data.t_ip,desc)
table.sort(data.t_des,desc)

if PRINT_TYPE == "ip" then
	for k,v in ipairs(data.t_ip) do
		if ((ONLYSHOW30 == "on") and (k > 30)) then break end
		local splitap = "\t\t"
		if (#v.ip + #tostring(v.c))  <= 12 then splitap = "\t\t\t" end
		print( string.format( "%s (%d)".. splitap .."%s", v.ip, v.c, v.des ) )
	end
else
	for k,v in ipairs(data.t_des) do
		if ((ONLYSHOW30 == "on") and (k > 30)) then break end
		print( string.format("%s (%d)", v.des, v.c ))
	end
end
