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
├── deploy.sh           // 一键构建脚本
├── docker-compose.yml  // docker-compose配置模板
└── my_crontab_list.sh  // linux crontab定时任务
```

# Running

**前提：** 

 	1. 按照模板配置好 `docker-compose.yml`
 	2. 同目录创建 `deploy.sh` 并将该项目中`deploy.sh`代码拷贝进去
 	3. 同目录创建 `.env` 文件，按照 `.env` 模板配置好自己的信息

**注意：** 

 	1. `.env` 文件中 `SCRIPT_NAME` 变量是配置docker多账号的，每个docker容器名用 `@` 符号隔开
 	2. `.env` 文件中除了 `SCRIPT_NAME` 变量，其他变量是非必须和本项目模板保持一致的，可自行扩展
 	3. 本项目中重要的是 `deploy.sh` 文件，其他均可以自行扩展

---

**运行：**

​	`bash deploy.sh`

**更新：**

​	已通过 crontab 添加了定时拉取脚本任务，手动更新请再次执行 `bash deploy.sh` 

# Thanks

感谢以前作者开源JD Script相关项目供我学习使用

[@lxk0301](https://gitee.com/lxk0301/jd_docker)

[@li-chenzhe](https://github.com/i-chenzhe/qx)

[@moposmall](https://github.com/whyour/hundun/tree/master/quanx)

[@whyour](https://github.com/lxk0301)