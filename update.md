## iOS network diagnostics sdk release note

### v-1.0.3(2019.03.01)

* support `ping` function
* support `traceroute` function
* DNS parsing(`nslookup`)
* Support for querying whether the service port is available
* Get the device public ip info 


### v-1.0.7(2019.03.22)

* Add `tcp ping` function
* Add `udp traceroute` function
* Fixed some bugs

### v-1.0.10(2019.06.17)

* Add LAN ip scanning function

### v-1.0.11(2019.07.01)

* Fix bug: When the `tracert` reaches the destination host, the type of the icmp packet is filtered incorrectly. The replay package should be filtered instead of the timeout package.

## iOS网络诊断SDK版本更新记录

###v-1.0.3(2019.03.01)

* `ping`功能
* `traceroute`功能
* 根据域名查ip功能(`nslookup`)
* 查询服务端口功能
* 获取设备公网ip信息

### v-1.0.7(2019.03.22)

* 添加 `tcp ping`功能
* 添加 `udp traceroute`功能
* 修复了部分bug

### v-1.0.10(2019.06.17)

* 添加局域网ip扫描功能

### v-1.0.11(2019.07.01)

* 修复bug: tracert到达目的主机时，过滤包的类型错误，应该直接过滤replay包而不是timeout包。