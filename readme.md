# Centstead
这是一个 PHP 调试环境 , 基于 centos,laravel/homestead.

# 介绍

基于开发的实际需求,PHP开发者通常需要一个贴近生产环境,又易于维护的测试与开发环境.以往的选择:

1. xampp, wamp, phpstudy… 集成环境，启动方便，占用小，但是需要往往不能提供 curl,pgsql,imagick… 插件, 自行编译成本很高。
2. 基于虚拟机手工搭建一个linux环境，然而虚拟机的初始化过程却相当费时费力。

似乎`易用`与`贴近生产环境`很难平衡。 然而 Vagrant 的到来为我们提供了这种可能. Vagrant 提供了一个便捷的方式来管理和设置虚拟机。

Vagrant 提出了盒子的概念. 一个盒子即是一个初始化过的虚拟系统, 需要的时候可以基于盒子快速生成虚拟机, 出现错误时又可以在几分钟之内快速销毁重建。

Centstead 就是一个高度定制的 CentOS + php 盒子, 你可以通过 Centstead 提供的脚本 与 vagrant 命令方便的管理你的虚拟环境。

##### Centstead 预置软件： (可基于配置快速切换版本)

+ CentOS 7
+ PHP  5.4 / 5.5 / 5.6 / 7.0
+ Mysql  5.5 / 5.6 / 5.7
+ MariaDB  5.5 / 10 / 10.1
+ PostgreSQL  9.2 / 9.3 / 9.4 / 9.5
+ Composer
+ Nginx
+ Redis
+ Sqllite3
+ Supervisor
+ Xdebug
+ Nodejs (npm webpack gulp bower)
+ memcached
+ Beanstalkd

#文档
#### [开始](#start)
#### [基础配置](#base-config)
#### [共享文件夹](#share-folder)
#### [Nginx 网站配置](#sites-config)
#### [定制环境软件](#environment-soft)
#### [文件拷贝](#copy-file)
#### [计划任务](#schedule)
#### [Laravel 队列监听](#queues)
#### [数据库自动创建](#create-database)
#### [SSH连接/管理虚拟环境](#ssh)
#### [自定义虚拟环境](#customize)
### 附录
#### [Vagrant 介绍/技巧](#vagrant)
#### [团队配合](#teamwork)
#### [Fuck GFW](#fuck-gfw)
#### [参与捉虫](#involvement)

<h1 id="start">开始</h1>

### 安装 & 设置

##### 首次安装

在使用 Centstead 之前，需要先安装 [Virtual Box](https://www.virtualbox.org/wiki/Downloads) 和 [Vagrant](https://www.vagrantup.com/downloads.html), 它们都提供 windows, mac ,linux 系统的安装程序。

##### 安装 Centstead Vagrant 盒子

###### 从 Vagrant 官方镜像安装

[VirtualBox](https://www.virtualbox.org/wiki/Downloads) 和 [Vagrant](https://www.vagrantup.com/downloads.html) 安装好了之后, 接着下载 Centstead 盒子, Centstead 默认提供了两个版本的盒子,供自行选择 :

1. 先锋版 virtualbox_avant.box ,预制 php 7.0 mysql 5.7
2. 通用版 virtualbox_usual.box ,预制 php 5.6 mysql 5.6

命令:
~~~bash
vagrant box add jason-chang/centstead-avant
或者
vagrant box add jason-chang/centstead-usual
~~~

###### 从网盘下载安装

下载地址: 

1. **[百度网盘](http://pan.baidu.com/s/1c15ybAS)**

下载完成后, `cd` 到 `.box` 所在目录, 将 box 添加到 Vagrant 环境.
~~~bash
cd downlods/path
vagrant box add ./avant.box --name=jason-chang/centstead-avant
或者
vagrant box add ./usual.box --name=jason-chang/centstead-usual
~~~

然后修改`config/config.yml` 打开 #version: ">=0" 前的注释。
(因为离线形式安装盒子无法定义版本信息, 如不开启此项, Vagrant校验版本后依然会从官方源下载盒子.)

#####通过 GitHub 克隆 Centstead

box 安装完成后, 克隆 `Centstead` 代码库到任意目录.

~~~bash
cd some/directory
git clone https://github.com/jason-chang/centstead.git centstead
~~~

克隆完成后,cd 到 `centstead` 目录下

1. 如果你使用 mac 或 linux , 运行 `bash init.sh` 命令来创建 centstead.yaml 配置文件.
2. 如果你使用 windows , 运行 `init.bat` 命令来创建 centstead.yaml 配置文件.

centstead.yaml 配置文件文件将创建于 config 目录.

centstead.yaml 是 centstead 主配置文件，几乎所有常用的变更都是通过修改 centstead.yaml 实现. 文件格式上它遵循 [yaml](https://zh.wikipedia.org/wiki/YAML) 标准.

至此使用 `centstead` 的脚手架工作都完成了, 
然后:
1. 根据盒子版本在**[基础配置](#base-config)** 设置 `box` 字段 和 `version` 字段 ,
2. 根据你的项目目录 **[配置共享文件夹](#share-folder)** ,
3. 根据你的项目域名 **[设置 nginx 站点](#sites-config)**,
4. 启动 Vagrantbox 就可以享受 centstead 的福利了.

##### 启动 Vagrant Box

配置好 `config/config.yaml` 文件后, 在 Centstead 目录下运行 `vagrant up` 命令, vagrant 将会启动虚拟机、配置共享文件夹、以及 Nginx 站点(并且写入主机的hosts).

然后,访问你设置的域名开始调试 php 程序吧!

销毁该机器，可以使用 `vagrant destroy`

为了更好的使用 centstead 请阅读 [Vagrant 介绍](#vagrant)

**推荐:**

同时推荐各位 , 使用支持 windows 和 mac 的 GUI 工具 [vagrant-manager](https://github.com/lanayotech/vagrant-manager) , 管理你的 Vagrant 虚拟机.

1. [windows 版本](https://github.com/lanayotech/vagrant-manager-windows)
2. [mac 版本](https://github.com/lanayotech/vagrant-manager)

<h1 id="base-config">基础配置</h1>

虚拟机 ip

~~~yaml
ip: "192.168.10.10"
~~~

虚拟机内存

~~~yaml
memory: 2048
~~~

虚拟机 cpu 核心数

~~~yaml
cpus: 1
~~~

虚拟机容器: Vagrant 默认可以提供 多种虚拟机容器, 包括 Vmware 和 VirtualBox, 但是 Vmware 支持是付费的, 本人无米暂时只能支持 VirtualBox

~~~yaml
provider: virtualbox
~~~

基础盒子名称

~~~yaml
box: jason-chang/centstead-usual
~~~

基础盒子版本, 此项默认关闭/注释, 离线安装盒子的用户请开启。

~~~yaml
#version: ">=0"
~~~

<h1 id="share-folder">共享文件夹</h1>

Centstead.yaml 文件中的 folders 属性列出了所有主机和 Centstead 虚拟机共享的文件夹，一旦这些目录中的文件有了修改，将会在本地和 Centstead 虚拟机之间保持同步，如果有需要的话，你可以配置多个共享文件夹（一般一个就够了）：

map: 主机文件目录
to: 映射到虚拟机的目录
type: 同步类型: 1.默认为空表示使用 shareFolder. 2. nfs （推荐） 表示使用 [nfs](https://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F) 同步.

~~~yaml
folders:
  - map: ~/Projects
    to: /home/vagrant/Projects
~~~

如果要开启 NFS，只需简单添加一个标识到同步文件夹配置：

~~~yaml
folders:
  - map: ~/Projects
    to: /home/vagrant/Projects
    type: nfs
~~~

<h1 id="sites-config">Nginx 网站配置</h1>

对 Nginx 不熟？没问题，通过 sites 属性你可以方便地将“域名”映射到 Centstead 虚拟机的指定目录，Centstead.yaml 中默认已经配置了一个示例站点。
和共享文件夹一样，你也可以配置多个站点：
（不同于 homestead, Centstead 的站点是基于项目的, 每个项目支持多个子站点）

conf: 项目最终保存成的配置文件
servers: 项目包含的域名 servers
map: 支持的 域名 server name 多个域名可以空格分隔.
to：指向的项目根入口目录.
type: 站点类型, 支持的配置值:

1. 不设置/default(普通php站index.php为入口)
2. static(静态文件站)
3. proxy (反向代理站)
4. laravel (项目网站)
5. thinkphp (thinkphp网站)
6. symfony (symfony2网站)

port：http 监听端口
ssl: https 监听端口

aliases：所有在 centstead 中配置的站点 centstead 将智能的加入主机的 hosts 文件中, 这样当 vagrant 启动完成的时候后，可以直接浏览配置的域名了。

*centstead 默认取 map 值加入 hosts 文件，但是由于 hosts 文件并不是非常强大, 类似 `**.demo.app` 的泛解析域名将不能支持, `aliases` 就是为此提供的自定义接口, 如果配置存在 `aliases` 则抓取 `aliases` 加入 `hosts` 文件*

示例:

~~~yaml
sites:
  - conf: demo.app
    servers:
      - map: static.demo.app
        to: /home/vagrant/Projects/Demo/static
        type: static

      - map: "demo.app *.demo.app"
        to: /home/vagrant/Projects/Demo
        aliases: "demo.app a.demo.app u.demo.app www.demo.app"
        # port: 80
        # ssl: 443
~~~

默认情况下，每个站点都可以通过 HTTP（端口号：8000）和 HTTPS（端口号：44300）进行访问.

配置完成后, 执行 `vagrant up` 就可以通过浏览器调试指定的网站了.
如果是已经启动过的环境请执行 `vagrant provision` 应用新的站点配置.

<h1 id="environment-soft">定制环境软件</h1>

为了更加贴近实际的生产环境, 我们往往需要配置特定的 php, mysql, postgre 版本. centstead 为此提供了非常简便的配置支持.

*编辑 `centstead.yaml` 后别玩忘了执行 `vagrant provision`.*

#### PHP版本切换

通过 `php:` 配置实现
支持的值: php54, php55, php56 php70 对应不同 php 版本.

例如:
~~~yaml
php: php70
~~~

提示: Centstead 已经默认配置好所有 php 版本的 xdebug 支持,

只需要配合 xdebug helper + phpstorm/eclipse …… 远程调试 php 了, 默认调用调试端口 9000.

所有 php 版本均默认安装了, redis, memcached, postgre, mysql, gd, imgick, mbstring, mcrypt, curl, openssl, xdebug 插件, 
但是如果 你还需要 安装 yar 呢怎么办, 去 [自定义虚拟环境](#customize) 看看.

#### Mysql/MariaDB版本切换

通过 `mysql:` 配置实现
支持的值: mysql55, mysql56, mysql57, mariadb55, mariadb10, mariadb101 对应不同 Mysql/MariaDB 版本.

例如:
~~~yaml
mysql: mariadb101
~~~

提示: Centstead 已经默认将主机的 33060 端口映射到 虚拟主机的 3306 端口,

并且添加了 用户名：vagrant 密码: vagrant 权限与 root 相同的 mysql 用户，

故此可以通过 vagrant 用户连接 localhost:33060 管理虚拟机Mysql/MariaDB数据库

#### PostgreSql版本切换

通过 `pgsql:` 配置实现
支持的值 pgsql92, pgsql93, pgsql94, pgsql95, 对应不同 PostgreSql 版本.

例如:
~~~yaml
pgsql: pgsql95
~~~

提示: 虽然国内目前使用, PostgreSql 的用户越来越多, 但是始终不如 mysql 多, 所以默认盒子并没有安装 PostgreSql, 但是配置此值稍等几分, PostgreSql 就配置好了 默认的 可以通过.

Centstead 已经默认将主机的 54320 端口映射到 虚拟主机的 5432 端口,

并且添加了 用户名：vagrant 密码: vagrant 权限与 root 相同的 postgre 用户，

故此可以通过 vagrant 用户连接 localhost:54320 管理虚拟机 PostgreSql 数据库.

<h1 id="copy-file">文件拷贝</h1>

初始化过程中我们可能需要将部分文件拷贝到虚拟环境, 配置可以参考如下

~~~yaml
# 拷贝文件到虚拟机
copy:
  - from: ~/copy.demo
    to: /home/vagrant/copy.demo
~~~

提示: 拷贝文件支持 目录和文件, 但是不支持覆盖, 如果要同步修改, 请使用共享文件夹配置.

<h1 id="schedule">计划任务</h1>

无论测试环境还是生产环境我们都需要执行一些长期轮训的任务, 通过 centstead 你可以方便的创建 crond 任务.

name: 任务名称
user：任务执行的用户
interval: 任务的执行频率
command: 任务的执行命令

示例：

~~~yaml
schedules:
  - name: redis_demo
    user: vagrant
    interval: "* 0 */1 * *"
    command: "/usr/bin/redis-cli -h localhost DEL 'some-throttle'"
~~~

<h1 id="queues">Laravel 队列监听</h1>

如果你是一名 Laravel 开发者这里提供了 一个便捷的方式创建, Laravel 队列监听。

name: supervisor任务名称
driver：队列的驱动
queue: 队列名称
dir: 项目`artisan`所在目录

示例：
~~~yaml
queues:
  - name: demo.app.mails
    driver: redis
    queue: emails
    dir: /home/vagrant/Code/Demo
~~~

重要提示：
	
由于 vagrant 共享文件夹的挂载晚于 linux supervisor 系统服务, 每次 `vagrant halt` 重启虚拟机后, 可能发现队列监听失效了. 
请等待共享文件夹挂载完毕后，连入 [SSH](#ssh), 然后执行 `sudo systemctl restart supervisord.service` 重启队列监听.
然后可以通过 `ps aux | grep artisan` 命令验证队列监听是否在工作。

<h1 id="create-database">数据库自动创建</h1>

通常我们可能希望为不同的项目, 创建不同的虚拟机环境, 那么为什么不在虚拟机配置时自动生成相应数据库呢？

centstead 做到了, 配置非常简单. 例如:
~~~yaml
databases:
	- name: vagrant
    - name: vagrant
      db: pgsql
~~~

db: 数据库容器, 默认mysql.

<h1 id="ssh">SSH连接/管理虚拟环境</h1>

#### 链接 SSH
Centstead 已经默认将主机的 2222 端口映射到 虚拟主机的 22 端口,
所以你可以 ssh://vagrant:vagrant@127.0.0.1:2222 连接虚拟环境

#### Vagrant 用户
Centstead 默认添加了 用户名：vagrant 密码: vagrant 权限与 root 相同的 linux 用户，

故此可以通过 vagrant 用户连接 localhost:2222 管理虚拟机.

另外由于 vagrant 具有完全的 sudo 权限, 如果你需要执行一个 root 权限的操作, 可以参考如下

~~~bash
sudo yum install php-yar
~~~

#### 切换到 root 用户

1. 你可以使用 vagrant 用户登录, 输入 `su -` 密码 vagrant 切换到 root 用户。
2. Centstead 默认修改内置的 root 用户密码为 vagrant, 可以直接使用 root 用户连接。

#### 公钥认证

如果你 配置了 `authorize:` 类似如下
~~~yaml
authorize: ~/.ssh/id_rsa.pub
~~~
则可以通过公钥认证, 以vagruant 用户的,链接到虚拟机, 这一配置默认是开启的。

#### 私钥导入虚拟环境

大多数情况我们的开发工作, 会是在 实机环境,

但是偶尔还是会在虚拟环境执行一些, github 或者 gitlab 的 pull/push 操作.

为虚拟机单独生成并导入一个秘钥？ NO

配置 `keys:` 就好了, 示例
~~~yaml
keys:
  - ~/.ssh/id_rsa
~~~

Centstead 就会将指定的私钥文件导入到虚拟环境。

<h1 id="customize">自定义虚拟环境</h1>

没有任何一个软件, 能够完全满足定制化的需求。
如果我们的虚拟环境, 需要其他的运行时环境, 或者 php 插件怎么办？

Centstead 为这种需求提供了一个钩子文件,就是 centstead.yaml 同级目录下的 after.sh .

每次 `vagrant provision` 执行的最后都会执行这个钩子.

接上边安装 yar 的需求,我们就可以编辑 `after.sh` 如下:

~~~bash
#!/bin/sh

# 安装 yar 插件
yum install php-yar
systemctl restart php-fpm.service
~~~

<h1>附录</h1>

<h1 id="vagrant">Vagrant 介绍</h1>

Vagrant 一个环境部署的脚手架工具, 在实际的应用中, 它可以支持 aws-ec2 docker …… 众多的类容器环境的部署.
然而本应用中直接把 vagrant 视作管理 Vmware/VirtualBox…… 多种虚拟环境的统一接口.

#### Vagrant 常用命令
~~~bash
vagrant up
~~~

初始化并且启动一个虚拟环境( 初次执行 up 操作时会执行 provision 操作，以后将不再执行。 )
    
~~~bash
vagrant halt
~~~

关闭虚拟环境

~~~bash
vagrant provision
~~~

对虚拟环境重新执行初始化操作.

Centstead 的 "创建nginx 站点"，"定制环境软件"，"共享文件夹"， "拷贝文件"， "自定义虚拟环境"， "计划任务创建"都是在这一层执行.

所以如果对上述内容修改以后都要执行 `vagrant provision` 应用更改.
    
~~~bash
vagrant suspend
~~~

暂停虚拟环境
    
~~~bash
vagrant resume
~~~

恢复虚拟环境
    
~~~bash
vagtant destroy
~~~

摧毁虚拟环境
    
##### 更多内容请看 官方文档
	
[Vagrant Docs](https://www.vagrantup.com/docs/)

<h1 id="teamwork">团队配合</h1>

<h1 id="fuck-gfw">Fuck GFW</h1>

`vagrant provision` 前请注意由于GFW的原因,初始化过程中可能经常失败,请尽量使用个人ADSL网络,操作前尽量重连ADSL更换IP, 然后默念三声 `日你妹方校长`

(GFW会根据IP计算HTTPS流量,HTTPS流量高后被断链的几率将增大)

在执行 `init.bat` `init.sh` 的过程中, 需要安装部分 vagrant 插件,同样可能会因为 gfw 导致失败. 

执行之前可以 `set http_proxy=http://127.0.0.1:1080/`, 为 cmd 或者 bash 设置一个 http 代*理.

<h1 id="involvement">参与捉虫</h1>

邮件: chaoyue.chang#qq.com
微信: sisisiy
欢迎自由拍砖 !!
反馈问题及提出改进请发 [Issue](https://github.com/jason-chang/centstead/issues/new) 或者 [Pull Request](https://github.com/jason-chang/centstead/compare).