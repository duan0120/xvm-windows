# X Version Manager

**xvm** 是一款小巧的，融合了 **node**， **golang**， **python** 等的版本管理工具，虽然没有专门的工具那么强大，但小巧且命令统一

## 安装方式

```
git clone https://github.com/duan0120/xvm-windows.git %USERPROFILE%/.xvm
```

配置环境变量

```
XVM_ROOT=%USERPROFILE%/.xvm
```
将下面路径加入到**%PATH%**中

```
%XVM_ROOT%\versions\node\default
%XVM_ROOT%\versions\go\default\bin
%XVM_ROOT%\versions\python\default
%XVM_ROOT%\versions\python\default\Scripts
```

## 使用方式

查看版本

```
xvm -v
```

获取帮助

```
xvm -h
xvm help node
```

### node

查看版本

```
xvm node ls-remote
xvm node ls-remote --lts
xvm node list
```

安装指定版本

```
xvm node install v18.19.1
```

卸载指定版本

```
xvm node uninstall v18.19.1
```

切换版本

```
xvm node use v18.19.1
```

### golang

查看版本

```
xvm go ls-remote
xvm go list
```

安装指定版本

```
xvm go install go1.19.2
xvm go install go1.13.10 --arch=amd64
```

如果需要指定下载地址，可以在 **%XVM_ROOT%/.xvm/scripts/go-scripts/proxy** 文件中指定，如 https://golang.google.cn

卸载指定版本

```
xvm go uninstall go1.19.2
```

切换版本

```
xvm go use go1.19.2
```

### python

查看版本

```
xvm python ls-remote
xvm python list
```

安装指定版本

```
xvm python install 3.12.1 // default arch=arm64
xvm python install 3.12.1 --arch=arm64
xvm python install 3.12.1 --arch=386
```

创建虚拟环境

```
xvm python alias test 3.12.1
```

激活虚拟环境

```
xvm python use test
```

卸载指定版本

```
xvm python uninstall 3.12.1
xvm python uninstall test
```

切换版本

```
xvm python use 3.12.1
```