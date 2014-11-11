#!/usr/bin/env lua

if  arg[1] and arg[1]:match("(%-+h)") then
	local help_message = [=[This script descript how many connects to outside specific port frome localhost.
Uses : t-allconnectstooutsideonport [port :: ( {80} | 192.168.0.103:80<dst_ip:port> | 102:80)] [is_analyze :: ({on}|off)]")
       between [] are options, before :: are the name of option, between {} are the default value of the option, between <> are additional remarks, | is "or".
]=]
	print(help_message)
	os.exit()
end

local PORT = "80";IS_ANALYZE = false
if arg[1] then
	PORT = arg[1]
end
if arg[2] and arg[2] == "off" then
	IS_ANALYZE = true
end

local dns_ip = "@192.168.0.60"
local command_path_dig = "dig"
local command_path_lsof = "lsof"

local TMPDIR = os.getenv("TMPDIR") or "/tmp/"
if TMPDIR:sub(-1) ~= "/"  then TMPDIR = TMPDIR .. "/" end

local TMPFILE = TMPDIR .. "t_all_connects_to_outside_on_port_tmp"
local command = command_path_lsof .. ' -nPi:'.. ( PORT:match(":(%d+)") or PORT ) ..' |grep ":'..PORT..' (ESTABLISHED)"  > ' .. TMPFILE

os.execute(command)

local data ={}
local d_index = {}
local sum = 0

for line in io.lines(TMPFILE) do
	if IS_ANALYZE then
		print(line)
	else
		local ip = line:match(":%d+%->([%w%.]+):") ; ip_index = d_index[ip]

		if not ip_index then
			ip_index = #data+1
			d_index[ip] = ip_index
			data[ip_index] = {}

			local dns_query_command = command_path_dig .. " -x " .. ip .. " +short"  -- .. dns_ip
			local handle = io.popen(dns_query_command)
			local ip_name = handle:read("*a")
			handle:close()

			data[ip_index].c = 1
			data[ip_index].name = ip_name:sub(0,-2)
			data[ip_index].ip = ip
		else
			data[ip_index].c = data[ip_index].c + 1
		end
		sum = sum + 1
	end
end

os.remove(TMPFILE)
d_index = nil
if IS_ANALYZE then os.exit() end

local function desc(a,b) return a.c > b.c end
table.sort(data,desc)


print( ("="):rep(60) )
print("server_name\tconnect_number\tip_addrs")
for _,v in ipairs(data) do
	print(string.format("%s\t(%d)\t%s", v.name, v.c, v.ip))
end
print( ("-"):rep(60) )
print( ("totally have [ %d ] connects to inside."):format(sum) )
print( ("="):rep(60) )
