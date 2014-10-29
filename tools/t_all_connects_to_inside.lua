#!/usr/bin/env lua

if  arg[1] and arg[1]:match("(%-+h)") then
	print("uses : t-allconnectstoinside [off]")
	os.exit()
end

local ISOFF = false
if arg[1] and arg[1] == "off" then
	ISOFF = true
end

local dns_ip = "@192.168.0.60"
local command_path_dig = "dig"
local command_path_lsof = "lsof"

local TMPDIR = os.getenv("TMPDIR") or "/tmp/"
if TMPDIR:sub(-1) ~= "/"  then TMPDIR = TMPDIR .. "/" end

local TMPFILE = TMPDIR .. "t_all_connects_to_inside_tmp"
local command = command_path_lsof .. ' -nPi:80 |grep ":80 (ESTABLISHED)"  > ' .. TMPFILE

os.execute(command)

local data ={}
local d_index = {}
local sum = 0

for line in io.lines(TMPFILE) do
	if ISOFF then
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
if ISOFF then os.exit() end

local function desc(a,b) return a.c > b.c end
table.sort(data,desc)


print( ("="):rep(60) )
print("ip_addrs\tconnect_number\tserver_name")
for _,v in ipairs(data) do
	print(string.format("%s\t(%d)\t%s", v.name, v.c, v.ip))
end
print( ("-"):rep(60) )
print( ("totally have [ %d ] connects to inside."):format(sum) )
print( ("="):rep(60) )
