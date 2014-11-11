

linux-stuffs
============

本项目记录的是我在linux使用和系统维护方面的一些笔记以及自己写的一些工具。陆续更新中...

包含的内容
----------

- [tshark_man_chinese.pdf](https://github.com/leolovenet/linux-stuffs/raw/master/tshark_man_chinese.pdf) 抓包工具**wireshark**命令行版本`tshark`的中文man帮助。对于在服务器上抓包来说简直是有如神助的好工具，但是使用起来不是那么容易，所以翻译整理了一下，并配上了实例说明。

- [lsof_man_chinese.pdf](https://github.com/leolovenet/linux-stuffs/raw/master/lsof_man_chinese.pdf) 为命令`lsof`的中文使用举例，事实证明，通过例子来学习命令是最快的。

- [tools](https://github.com/leolovenet/linux-stuffs/tree/master/tools)是一些自己写的工具集。

###tools 安装方法###

1. 在服务器安装[LuaDist](http://luadist.org/)的`lua`执行环境。
2. 运行命令`luadist install lua-iconv`安装 `lua-iconv`库。
3. 自己下载[纯真数据库](http://update.cz88.net/soft/setup.zip)，将里面的`qqwry.dat`文件与本项目内的`qqwry.lua`文件一同放入到`LuaDist`安装目录下的`/lib/lua`目录。
4. 下载本项目内的`lua`脚本放到`LuaDist`安装目录下地`bin`目录内，然后直接运行 `t-build.sh`  ，这会生成编译后的`t-`开头的命令；或者将`LuaDist`的`bin`目录添加到`PATH`环境变量中，并向对应脚本添加可执行权限，直接运行脚本即可。

###tools 内部脚本说明###

>- [t-build.sh](https://github.com/leolovenet/linux-stuffs/blob/master/tools/t-build.sh) 为将下面的工具脚本编译为可执行文件，输出以`t-`开头的命令程序，你可以忽略此步骤，而将下面脚本赋予可执行权限后直接执行。

>- [t_all_connects_from_outside_on_port.lua](https://github.com/leolovenet/linux-stuffs/blob/master/tools/t_all_connects_from_outside_on_port.lua) 为用lua写的脚本，封装了`lsof`和`dig`命令(所以你需要先运行`yum -y install lsof bind-utils`)实现**实时查看当前服务器的连接数信息**，包括查看每ip的连接数，并利用`传真ip库`将ip转换成为了实际地址。输出样式如下：
    ```
        =====================================================
        totally have [ 687 ] connects from outside.
        =====================================================
        183.13.65.48 (36)		广东省深圳市-电信
        113.109.37.161 (23)		广东省广州市天河区-电信
        211.103.170.35 (7)		北京市-电信通三元桥IDC机房
        117.136.44.5 (7)		河南省郑州市-移动
        119.97.146.148 (6)		湖北省武汉市-电信
        222.179.142.34 (6)		重庆市合川区-电信
        221.201.98.210 (6)		辽宁省大连市-联通ADSL
    ```
    >  或者以下面的样式输出
    ```
        =================================================
        totally have [ 731 ] connects from outside.
        =================================================
        广东省深圳市-电信 (114)
        美国-加利福尼亚州圣克拉拉县山景市谷歌公司 (62)
        美国-雅虎公司 (55)
        河南省郑州市-联通 (30)
        美国-Microsoft公司 (20)
        北京市-联通互联网数据中心 (15)
        天津市-联通 (14)
    ```

>- [t_all_connects_to_outside_on_port.lua](https://github.com/leolovenet/linux-stuffs/blob/master/tools/t_all_connects_to_outside_on_port.lua) 为运行在负载均衡服务器上，查看当前对内部服务器的每服务器的连接数。输出样式如下：
    ```
        ================================================
        server_name     connect_number	ip_addrs    
        web1        	(31)	        192.168.0.20
        web7        	(31)	        192.168.0.26
        web4        	(30)	        192.168.0.23
        web3        	(25)	        192.168.0.22
        web5        	(24)	        192.168.0.24
        web6        	(23)	        192.168.0.25
        nas4        	(16)	        192.168.0.123
        ==============================================
        totally have [ 180 ] connects to inside.
        ==============================================
    ```

>- [t_iplocal.lua](https://github.com/leolovenet/linux-stuffs/blob/master/tools/t_iplocal.lua)为一个简单地命令行下对`纯真ip库的封装`，可以直接运行该命令查看某个ip的地理位置信息。例如：
    ```bash
        $ t_iplocal.lua 192.168.2.1
        #-> 局域网对方和您在同一内部网
    ```
>- [qqwry.lua](https://github.com/leolovenet/linux-stuffs/blob/master/tools/qqwry.lua)来源于[这里](https://github.com/lancelijade/qqwry.lua) 。
