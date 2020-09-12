# benchmarking

PlatON vs EOS性能对比测试说明。

## 准备

### 服务器

本次测试采用AWS的c5d.4xlarge服务器，Intel(R) Xeon(R) 8124M 16核 3.0GHz，32G内存，300G SSD硬盘。

数量：30台

系统：Ubuntu 18.04.4 LTS

### 依赖软件

除PlatON和EOS官方要求的常规软件（如git、gcc等）外，本次测试需要安装以下软件：
1. ansible(2.9.12+，只需在主控节点安装)
2. nginx(1.14.0，作为PlatON二进制包的下载仓库，只需在主控节点安装)
3. supervisor(3.3.1，在部署节点安装)
4. jq (jq-1.5-1+)
5. curl(7.58.0+)

### 配置集群

1. 将 `scripts` 目录下的`ansible`目录拷贝到主控节点（可以任意指定）的`/etc/ansible`下
2. 编辑 `/etc/ansible/inventories/hosts` 文件，添加集群信息，如：

```
[node_mnsh]
18.138.238.82   node-001
...

[producer]
18.138.238.82
...

[generator]
18.141.217.208
...
```

### 配置 ansible 免密登录

```bash 
# 配置免密 /etc/ansible/inventories/group_vars/all.yml文件需要加入sudo密码
# 如果中途加入新的从机器，直接执行初始化系统步骤
$ ansible node -m ping
# 生成key
$ ssh-keygen
$ cp ~/.ssh/id_rsa.pub /etc/ansible/files/ssh/ssh_key
# 初始化系统
$ ansible-playbook /etc/ansible/playbooks/common/init.yml
```

## PlatON

### 部署集群节点

1. 源码安装PlatON

本次测试PlatON的代码分支为[develop](https://github.com/PlatONnetwork/PlatON-Go/tree/develop)，commitid: aeeca8337208a2c8f7ea418e36b94674beb10db5。

源码编译安装可参考[PlatON开发者文档](https://devdocs.platon.network/docs/zh-CN/Install_PlatON)。

2. 发布PlatON

使用 nginx 作为源仓库，存放二进制包

```bash
# 配置nginx资源下载转发规则
$ sudo vim /etc/nginx/conf.d/localhost.conf
server {
    listen  80;
    server_name  localhost;
    location /codes {
        alias /opt/codes;
    }
}
$ sudo sed -i '/sites-enabled/ s/^/#/g'  nginx.conf 
$ sudo systemctl reload nginx
# 新建包存放目录
$ mkdir -p /opt/codes/test/servers/20200907
$ sudo chown -R pchuant:pchuant /opt
# 将platon重命名platon_1，然后压缩为platon_1.bz2
$ cd /opt/codes/test/servers/20200907
$ bzip2 platon_1
# 下发platon执行文件到各部署节点，并创建软链接/usr/bin/platon
$ ansible-playbook /etc/ansible/playbooks/platon/deploy_binary.yml
Which host or group would you like to assign [Default: empty]: node_mnsh
Which version would you like to deploy [Default: empty]: 20200907-1
```

3. 生成及下发节点 nodekey 和 nodeblskey

编辑 `/etc/ansible/files/keys/hosts` 文件，添加集群主机信息，在 `/etc/ansible/files/keys` 目录下执行

```bash
$ ./nodekey.sh getkey
```

根据模板生成创世区块文件（替换初始共识节点列表），将生成的 `genesis.json` 文件上传到 `/etc/ansible/files/platon` 目录

4. 下发 supervisor 配置文件

```bash
# 安装supervisor服务
$ ansible-playbook /etc/ansible/playbooks/supervisor/install.yml
Which host or group would you like to assign [Default: empty]: node_mnsh
# 下发使用supervisor启动platon的配置文件
$ ansible-playbook /etc/ansible/playbooks/supervisor/platon.yml
Which host or group would you like to assign [Default: empty]: node_mnsh
# Supervisor 启动，修改过配置文件，则用reload替换start
$ ansible node -m node -a "supervisorctl reload"
```

5. 部署集群

```bash
# ansible-playbook /etc/ansible/playbooks/platon/deploy.yml
Which host or group would you like to assign [Default: empty]: node_mnsh
Which node name would you like to deploy [Default: empty]: platon
```

### 启动压测

1. 部署压测脚本

从集群中选择1~3个节点作为压测插件节点（建议选择非共识节点），登陆节点所在主机，将压测脚本`private_keys.json` 上传到用户目录下，比如 `/home/pchuant/private_keys.json`

2. 执行压测命令

```
curl -H "Content-Type: application/json"   -X POST --data '{"jsonrpc":"2.0","method":"txgen_start","params":[1,0,0,500,0,100,0,1,"/home/pchuant/private_keys.json",1,5000,15],"id":1}' http://localhost:6691
```

> 说明：
	前三个参数表示转账、evm合约、wasm合约交易类型，1 开启，0 不开启；
	第四个参数表示单位时间内发送交易总数；
	第五个参数表示活跃账户发送交易的总数，一般为小于第四个参数值；
	第六个参数表示每100毫秒触发一次发送交易命令；
	其余命令请参考[插件使用说明文档](/plugin/platon/插件说明.md)

## EOS

### 代码分支

本次测试EOS的代码分支为[master](https://github.com/EOSIO/eos/tree/master)，commitid:0d87dff8bee56179aa01472dd00a089b2aa7b9fa。

### 编译和安装

1. clone代码

本步骤请按官方指导完成，[参考](https://developers.eos.io/manuals/eos/latest/install/build-from-source/index)

2. 替换插件文件

请将`plugin/eosio/txn_test_gen_plugin.cpp`覆盖到`eos/plugins/txn_test_gen_plugin`

3. build&&install

安装官网指导，完成eos的编译和安装，EOS默认安装在`~/eosio/2.0`， 以下操作中以此目录为默认路径，如果指定了其他路径请自行调整。

4. 将安装好的EOS2.0同步到集群所有节点

对于集群内的节点，可以在其中一台主机上编译并安装， 安装完成后将`~/eosio/2.0`和本仓库的`scripts\eosio\bin`目录打包压缩，然后通过scp分发到集群内的其他节点，可以通过ansible对集群内的所有节点进行解压：

```
ansible 集群名 -m shell -a "tar -zxvf ~/eosio.tar.gz -C ~"
```

5. 添加环境变量

为操作方便，可以将`~/eosio/2.0/bin`添加到系统`PATH`
编辑`~/.bashrc`

```
export EOSHOME=$HOME/eosio
export PATH=$PATH:$EOSHOME/2.0/bin
```

然后执行以下命令使环境变量生效

```
source ~/.bashrc
```

> 注：以上步骤需要在所有集群内节点执行

### 部署

1. 生成hostsinfo

编辑`/etc/ansible/files/keys/config/hosts`文件，添加需要部署EOS节点的IP（注意第一个IP将被默认设置未天使节点，即eosio节点），然后执行脚本：

```
./genhostsinfo.sh
```

> 脚本中使用了默认的eosio公私钥，如果不想用默认值，请修改脚本替换

执行完成后，将在当前路径生成`hostsinfo`文件。

2. 分发配置文件到集群

在确保已经执行上述初始化环境步骤（主要是ansible配置scp免密）后，执行以下脚本：

```
./updatecfg.sh
```

脚本将自动分发配置文件到各主机上

3. 创建钱包

执行以下命令：

```
cleos wallet create -n bench --to-console
```
> 注：成功后输出密码，注意保存。 -n 后是钱包名，自己取。

4. 编辑unlock.sh

将上述步骤创建的钱包名及密码更新到`$HOME/eosio/bin/unlock.sh`脚本中。

5. 在天使节点上初始化

初始化的步骤很简单，只需要在天使节点的`$HOME/eosio/bin`目录下执行：

```
 ./init.sh
```

### 启动集群

执行以下命令：

```
ansible-playbook /etc/ansible/playbooks/eosio/start_producer.yml
```

提示输入需要启动producer（超级节点）的集群
完成后，执行以下命令以启动generator集群

```
ansible-playbook /etc/ansible/playbooks/eosio/start_generator.yml
```

### 启动压测

1. 创建测试账户

由于generator启动后需要加载独立的测试账户，在generator节点中需要执行以下命令以生成测试账户：

```
$HOME/eosio/bin/creategenAccount.sh
```

2. 质押和委托

节点注册producer和vote都需要私钥签名交易，所以在执行脚本前请手动将各个节点producer的私钥导入天使节点的钱包（bench）

```
cleos wallet import -n single --private-key  producer的私钥
```

导入成功后，在天使节点执行以下命令使超级节点（producer）成为共识节点

```
$HOME/eosio/bin/systeminit.sh
```

3. 准备合约

本次压测所需要的合约在`/benchmarking/contracts/eosio/eosio.contracts`，如果需要修改合约内容，请按[官方指导](https://developers.eos.io/manuals/eosio.cdt/latest/how-to-guides/compile/compile-a-contract-via-cli)对合约重新进行编译。
在进行压测前，需要将待测合约的编译好（需有.abi文件和.wasm文件），本例中将合约放到`~/eosio//home/jht/eosio/eosio.contracts`，如果不使用此路径，需要自己修改`/etc/ansible/files/keys/config/generator.ini`,将`txn-test-gen-is-abiserializer`和`txn-test-gen-token-abiserializer`做适应修改。

特别注意，天使节点（即第一个节点）必须用源码的方式编译eos和contracts，否则链初始化时会报找不到合约内容的错。

4. 启动压测

在generator节点中执行以下命令：

```
curl --data-binary '["", 0, 20, 20]' http://127.0.0.1:6666/v1/txn_test_gen/start_generation
```

> 说明：第一个参数为salt可以填空， 第二个参数是交易类型， 0为普通转账，2为KV合约压测，第三个参数为时间间隔，单位是毫秒，第四个参数是每个线程在单位间隔内产生交易的数量，上例中的效果为：每20ms每个线程产生20笔转账交易，线程数在`$HOME/eosio/config/generator.ini`中配置
