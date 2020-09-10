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
2. jq (jq-1.5-1+)
3. curl(7.58.0+)

### 配置集群

1. 将'scripts'目录下的'ansible'目录拷贝到主控节点（可以任意指定）的'/etc/ansible'下
2. 编辑'/etc/ansible/inventories/hosts'文件，添加集群信息，如：

```
[node_mnsh]
18.138.238.82   hostname=aws-sgp-vm-mnsh-001
18.140.198.20   hostname=aws-sgp-vm-mnsh-002
13.251.88.135   hostname=aws-sgp-vm-mnsh-003
18.141.213.225  hostname=aws-sgp-vm-mnsh-004
13.229.153.202  hostname=aws-sgp-vm-mnsh-005
3.0.48.130      hostname=aws-sgp-vm-mnsh-006
3.1.26.215      hostname=aws-sgp-vm-mnsh-007
3.1.209.253     hostname=aws-sgp-vm-mnsh-008
13.251.35.165   hostname=aws-sgp-vm-mnsh-009
18.141.153.79   hostname=aws-sgp-vm-mnsh-010
13.212.30.46    hostname=aws-sgp-vm-mnsh-011
13.212.16.54    hostname=aws-sgp-vm-mnsh-012
18.141.212.157  hostname=aws-sgp-vm-mnsh-013
13.229.141.36   hostname=aws-sgp-vm-mnsh-014
13.251.60.250   hostname=aws-sgp-vm-mnsh-015
13.229.147.27   hostname=aws-sgp-vm-mnsh-016
18.141.210.25   hostname=aws-sgp-vm-mnsh-017
18.141.212.192  hostname=aws-sgp-vm-mnsh-018
18.140.237.236  hostname=aws-sgp-vm-mnsh-019
18.141.163.90   hostname=aws-sgp-vm-mnsh-020
18.140.199.221  hostname=aws-sgp-vm-mnsh-021
13.212.18.153   hostname=aws-sgp-vm-mnsh-022
18.140.231.65   hostname=aws-sgp-vm-mnsh-023
13.229.154.110  hostname=aws-sgp-vm-mnsh-024
18.141.217.208  hostname=aws-sgp-vm-mnsh-025
13.251.102.47   hostname=aws-sgp-vm-mnsh-026
3.0.200.130     hostname=aws-sgp-vm-mnsh-027
13.212.69.242   hostname=aws-sgp-vm-mnsh-028
3.1.64.105      hostname=aws-sgp-vm-mnsh-029

[producer]
18.138.238.82
18.140.198.20
13.251.88.135
18.141.213.225
13.229.153.202
3.0.48.130
3.1.26.215
3.1.209.253
13.251.35.165
18.141.153.79
13.212.30.46
13.212.16.54
18.141.212.157
13.229.141.36
13.251.60.250
13.229.147.27
18.141.210.25
18.141.212.192
18.140.237.236
18.141.163.90
18.140.199.221
13.212.18.153
18.140.231.65
13.229.154.110
18.141.217.208
13.251.102.47
3.0.200.130
13.212.69.242
3.1.64.105
3.0.200.157

[generator]
18.141.217.208
13.251.102.47
3.0.200.130
13.212.69.242
3.1.64.105
```

## PlatON

## EOS

### 代码分支

本次才是EOS的代码分支为[master](https://github.com/EOSIO/eos/tree/master)，commitid:0d87dff8bee56179aa01472dd00a089b2aa7b9fa。

1. clone代码

本步骤请按官方指导完成，[参考](https://developers.eos.io/manuals/eos/latest/install/build-from-source/index)

2. 替换插件文件

请将'plugin/eosio/txn_test_gen_plugin.cpp'覆盖到'eos/plugins/txn_test_gen_plugin'

3. build&&install

安装官网指导，完成eos的编译和安装，EOS默认安装在'~/eosio/2.0'， 以下操作中以此目录为默认路径，如果指定了其他路径请自行调整。

4. 添加环境变量

编辑'~/.bashrc', 将EOSIO二进制所在目录添加到PATH

```
export EOSHOME=$HOME/eosio
export PATH=$PATH:$EOSHOME/2.0/bin
```

然后执行以下命令使环境变量生效

```
source ~/.bashrc
```

5. 生成hostsinfo

编辑'/etc/ansible/files/keys/config/hosts'文件，添加需要部署EOS节点的IP（注意第一个IP将被默认设置未天使节点，即eosio节点），然后执行脚本：

```
./genhostsinfo.sh
```

执行完成后，将在当前路径生成'hostsinfo'文件。

6. 分发配置文件到集群

在确保已经执行上述初始化环境步骤（主要是ansible配置scp免密）后，执行以下脚本：

```
./updatecfg.sh
```

脚本将自动分发配置文件到各主机上

7. 创建钱包

执行以下命令：

```
cleos wallet create -n bench --to-console
```
> 注：成功后输出密码，注意保存。 -n 后是钱包名，自己取。

8. 编辑unlock.sh

将上述步骤创建的钱包名及密码更新到'$HOME/eosio/bin/unlock.sh'脚本中。

9. 在天使节点上初始化

初始化的步骤很简单，只需要在天使节点的'$HOME/eosio/bin'目录下执行：

```
 ./init.sh
```

10. 启动集群

执行以下命令：

```
ansible-playbook /etc/ansible/playbooks/eosio/start_producer.yml
```

提示输入需要启动producer（超级节点）的集群
完成后，执行以下命令以启动generator集群

```
ansible-playbook /etc/ansible/playbooks/eosio/start_generator.yml
```

11. 创建测试账户

由于generator启动后需要加载独立的测试账户，在generator节点中需要执行以下命令以生成测试账户：

```
$HOME/eosio/bin/creategenAccount.sh
```

12. 账户创建成功后，在天使节点执行以下命令使超级节点（producer）成为共识节点

```
$HOME/eosio/bin/systeminit.sh
```

13. 启动压测

在generator节点中执行以下命令：

```
curl --data-binary '["", 0, 20, 20]' http://127.0.0.1:6666/v1/txn_test_gen/start_generation
```

> 说明：第一个参数为salt可以填空， 第二个参数是交易类型， 0为普通转账，2为KV合约压测，第三个参数为时间间隔，单位是毫秒，第四个参数是每个线程在单位间隔内产生交易的数量，上例中的效果为：每20ms每个线程产生20笔转账交易，线程数在'$HOME/eosio/config/generator.ini'中配置
