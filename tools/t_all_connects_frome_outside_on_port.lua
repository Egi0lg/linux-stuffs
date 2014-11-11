#!/usr/bin/env lua
local qqwry = require("qqwry")

if arg[1] and arg[1]:match("(%-+h)") then
	local help_message = [=[This script descript how many connects from outside to localhost on specific port.
Uses: t-allconnectsfromoutside [port :: ( {80} | 192.168.0.103:80<locahost_ip:port> | 102:80)]  [is_analyze :: ({on}|off)]  [the_anaylze_print_type :: ({ip}|des)]
      between [] are options, before :: are the name of option, between {} are the default value of the option, between <> are additional remarks, | is "or".

The default display only 30 records, If you want show all records, add "-all" option at the any place that should be option.
e.g.: t-allconnectsfromoutsideonport -all 80 on ip
      t-allconnectsfromoutsideonport 80 on des -all
]=]
	print(help_message)
	os.exit()
end

local PORT,IS_ANALYZE,PRINT_TYPE
local ONLYSHOW30 = "on"; USEDNS = "off"
for i=1,#arg do
	if arg[i] == "-all" then
		ONLYSHOW30="off"
	elseif arg[i] == "-dns" then
		USEDNS="on"
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

local dns_ip = "@192.168.0.60"
local command_path_dig = "dig"
local command_path_lsof = "lsof"

local TMPFILE = TMPDIR .. "t_all_connects_from_outside_on_port_tmp"
local command = command_path_lsof .. ' -nPi:' .. ( PORT:match(":(%d+)") or PORT ) .. ' | grep "' .. PORT .. '\\->" > ' .. TMPFILE   -->    """" lsof -nPi:80 | grep ":80\->" > TMPFILE  """
--print(command)
os.execute(command)

local d_index = {}
local data = { t_ip={}, t_des={} }
local sum = 0

qqwry.open()
for line in io.lines(TMPFILE) do
		local ip = line:match(":%d+%->([%w%.]+):") ; ip_index = d_index[ip]
		local ip_des =  table.concat(qqwry.get(ip),"-"); ip_des_index = d_index[ip_des]
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

		local ip_des = v.des
		if USEDNS == "on" then
			local dns_query_command = command_path_dig .. " -x " .. v.ip .. " +short"  -- .. dns_ip
			local handle = io.popen(dns_query_command)
			local ip_name = handle:read("*a")
			ip_des = ip_des .. "\t" ..ip_name:sub(0,-2)
			handle:close()
		end
		print( string.format( "%s (%d)".. splitap .."%s", v.ip, v.c, ip_des ) )
	end
else
	for k,v in ipairs(data.t_des) do
		if ((ONLYSHOW30 == "on") and (k > 30)) then break end
		print( string.format("%s (%d)", v.des, v.c ))
	end
end
