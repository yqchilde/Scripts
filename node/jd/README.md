# JD Script Building

                       _ ____    ____            _       _
                      | |  _ \  / ___|  ___ _ __(_)_ __ | |_
                   _  | | | | | \___ \ / __| '__| | '_ \| __|
                  | |_| | |_| |  ___) | (__| |  | | |_) | |_
                   \___/|____/  |____/ \___|_|  |_| .__/ \__|
                                                  |_|
                      ____        _ _     _ _
                     | __ ) _   _(_) | __| (_)_ __   __ _
                     |  _ \| | | | | |/ _\` | | '_ \ / _\` |
                     | |_) | |_| | | | (_| | | | | | (_| |
                     |____/ \__,_|_|_|\__,_|_|_| |_|\__, |
                                                    |___/

基于lxk大佬的docker镜像和各路JD脚本大佬汇总的Docker1一键构建工具，支持多账号

# Struct

```bash
.

├── .env                // 变量配置文件
├── README.md
├── author              // 存档脚本目录
├── backup              // 过期脚本目录
├── deploy.sh           // 一键构建脚本(已弃用)
├── jd_script.sh        // 自定义脚本远程加载脚本, 在环境变量 CUSTOM_LIST_FILE 里配置远程地址
├── docker-compose.yml  // docker-compose配置模板
└── jd_script_tool.py   // 脚本相关生成工具
```

# ScreenShot
![](https://pic.yqqy.top/blog/20210304234821.png?imageMogr2/format/webp/interlace/1)

# Thanks

感谢以前作者开源JD Script相关项目供我学习使用

[@lxk0301](https://gitee.com/lxk0301/jd_docker)

[@li-chenzhe](https://github.com/i-chenzhe/qx)

[@moposmall](https://github.com/whyour/hundun/tree/master/quanx)

[@whyour](https://github.com/lxk0301)
