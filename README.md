# X Version Manager

**xvm** is a lightweight version managers tool that integrates version management for **node**, **golang**, **python**, etc. Although it may not be as powerful as specialized tools, it is compact and has unified commands.

## Installation

```
git clone https://github.com/duan0120/xvm.git ~/.xvm
```

Configure environment variables
```
XVM_ROOT=%USERPROFILE%/.xvm
```
Add the following paths to **%PATH%**

```
%XVM_ROOT%\versions\node\default
%XVM_ROOT%\versions\go\default\bin
```

## Usage

Check version

```
xvm -v
```

Get help

```
xvm -h
xvm help node
```

### node

List available versions

```
xvm node ls-remote
xvm node ls-remote --lts
xvm node list
```

Install specific version

```
xvm node install v18.19.1
```

Uninstall specific version

```
xvm node uninstall v18.19.1
```

Switch version

```
xvm node use v18.19.1
```

### golang

List available versions

```
xvm go ls-remote
xvm go list
```

Install specific version

```
xvm go install go1.19.2
xvm go install go1.13.10 --arch=amd64
```

Uninstall specific version

```
xvm go uninstall go1.19.2
```

Switch version

```
xvm go use go1.19.2
```