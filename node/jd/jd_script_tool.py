import os
import platform

activitiesMap = {
    "京东农场": "FRUITSHARECODES",
    "京东萌宠": "PETSHARECODES",
    "种豆得豆": "PLANT_BEAN_SHARECODES",
    "东东工厂": "DDFACTORY_SHARECODES",
    "京喜工厂": "DREAM_FACTORY_SHARE_CODES",
    "京喜农场": "JXNC_SHARECODES",
    "京东赚赚": "JDZZ_SHARECODES",
    "crazyJoy": "JDJOY_SHARECODES",
    "闪购盲盒": "JDSGMH_SHARECODES",
    "财富岛": "JDCFD_SHARECODES",
    "签到领现金": "JD_CASH_SHARECODES",
    "环球挑战赛": "JDGLOBAL_SHARECODES",
    "口袋书店": "BOOKSHOP_SHARECODES",
}

shareCodeFilePaths = []
filter_list = ["(每次都变化,不影响)"]


def show_menu():
    """Menu"""
    print("-" * 50)
    print("       _ ____    ____            _       _   ")
    print("      | |  _ \  / ___|  ___ _ __(_)_ __ | |_ ")
    print("   _  | | | | | \___ \ / __| '__| | '_ \| __|")
    print("  | |_| | |_| |  ___) | (__| |  | | |_) | |_ ")
    print("   \___/|____/  |____/ \___|_|  |_| .__/ \__|")
    print("                                  |_|        ")
    print("              _____           _ ")
    print("             |_   _|__   ___ | |")
    print("               | |/ _ \ / _ \| |")
    print("               | | (_) | (_) | |")
    print("               |_|\___/ \___/|_|")
    print("\n")
    print("1-生成指定账号助力码")
    print("2-查询自己所有助力码")
    print("3-整理好友所有助力码")
    print()
    print("\033[36m@-Help\033[0m")
    print("\033[36m0-退出\033[0m")
    print("-" * 50)


def singleHandle(infos, cnt, idx, share_code):
    res = ""
    for num in range(1, cnt + 1):
        if idx == num:
            continue
        elif share_code + str(num) not in infos or is_han(infos[share_code + str(num)][0]):
            continue
        else:
            res += "${" + share_code + str(num) + "}@"

    return res[:-1]


def multiHandle():
    print("\n\033[33m生成指定账号的助力码格式\033[0m\n")
    line = input("请输入docker-compose配置中的顺序: \n")
    n = line.split()[0]
    print("您输入的编号是:[%s]" % n)

    res = ""
    print("\n\033[1;36m助力码生成结果如下：\033[0m\n")
    for k, v in activitiesMap.items():
        temp = ""
        if v.__contains__("_SHARE_CODES"):
            temp = v[:v.index("_SHARE_CODES")]
        elif v.__contains__("_SHARECODES"):
            temp = v[:v.index("_SHARECODES")]
        elif v.__contains__("SHARECODES"):
            temp = v[:v.index("SHARECODES")]

        res += "${" + temp + str(n) + "}@"

        print("# " + k + "\n\033[32m" + "- " + v + "=" + res[:-1] + "\033[0m\n")
        res = ""


def getMiddleStr(content, startIdx, endIdx):
    start = content.find(startIdx)
    end = content.find(endIdx)

    if start != -1 and endIdx == "\0":
        return content[start + len(startIdx):]
    elif start != -1 and end != -1:
        return content[start + len(startIdx):end]
    else:
        return ""


def searchFile(path='.', file_name=""):
    for item in os.listdir(path):
        item_path = os.path.join(path, item)

        if os.path.isdir(item_path):
            searchFile(item_path, file_name)

        elif os.path.isfile(item_path):
            if file_name in item:
                global shareCodeFilePaths
                shareCodeFilePaths.append(item_path)


def is_han(uchar):
    if u'\u4e00' <= uchar <= u'\u9fa5':
        return True
    else:
        return False


def queryAllShareCode(paths):
    if len(paths) == 0:
        print("\n\033[31m查询失败！可能原因如下：\033[0m")
        print("\033[31m1. 项目日志中并没有收集到助力码，请手动运行一次\033[0m")
        print("\033[31m2. 该脚本文件没有放置在项目根目录下\033[0m")
        return

    for path in paths:
        fo = open(path, "r")

        infos = {}
        for line in fo.readlines():
            line = line.strip()

            # 从账号1 start
            if getMiddleStr(line, "【京东账号 1 （", "）") != "":
                infos["USERNAME"] = getMiddleStr(line, "【京东账号 1 （", "）")

            for share_code, active_name in activitiesMap.items():
                if "【京东账号 1 （" in line and active_name in line:
                    infos[share_code] = line

        fo.close()

        print("\n\033[1;36m" + "京东账号" + "：" + infos["USERNAME"] + "\033[0m")

        def printLine(line_name, active_name):
            if line_name not in infos:
                print("【京东账号 1 （" + infos["USERNAME"] + "）" + active_name + "好友互助码】未获取到助力码，可能是该项目黑了")
            else:
                print(infos[line_name])

        for share_code, active_name in activitiesMap.items():
            printLine(share_code, active_name)


def formatFriendCode(path):
    print("请确保好友的助力码保存在 " + path + " 文件中")
    if not os.path.isfile(path):
        print(path + " 文件不存在")
        return
    print("开始整理...\n")
    print("-" * 80)

    fo = open(path, "r")

    infos = {}
    cnt = 1

    def setInfos(arg1, arg2, cnt):
        if getMiddleStr(line, "" + arg2 + "】", "\0") != "":
            if arg1 + str(cnt) in infos:
                infos[arg1 + str(cnt + 1)] = getMiddleStr(line,
                                                          "" + arg2 + "】", "\0")
                cnt += 1
            else:
                infos[arg1 + str(cnt)] = getMiddleStr(line,
                                                      "" + arg2 + "】", "\0")

    for line in fo.readlines():
        line = line.strip()

        # 过滤数据
        if any(dirty in line for dirty in filter_list):
            for filter_str in filter_list:
                line = line.replace(filter_str, "")

        # 填充数据
        for share_code, active_name in activitiesMap.items():
            setInfos(share_code, active_name, cnt)

        # 定义账号
        if getMiddleStr(line, "京东账号：", "\0") != "":
            if "USERNAME" + str(cnt) in infos:
                infos["USERNAME" + str(cnt + 1)
                      ] = getMiddleStr(line, "京东账号：", "\0")
                cnt += 1
            else:
                infos["USERNAME" +
                      str(cnt)] = getMiddleStr(line, "京东账号：", "\0")

    print("\n\033[1;36m# 好友助力码整理结果如下：\033[0m")
    print("\n\033[32m" + "# 助力码顺序（推荐按照docker-compose多容器配置顺序整理 friend_code.txt 并生成）" + "\033[0m")
    for i in range(cnt):
        print("# 助力码" + str(i + 1) + "=" + infos["USERNAME" + str(i + 1)])

    def printShareCode(arg1, arg2):
        print("\n\033[32m" + "# " + arg2 + "" + "\033[0m")
        for i in range(cnt):
            if arg1 + str(i + 1) not in infos:
                print(arg1 + str(i + 1) + "=" + "没有助力码，请检查friend_code.txt文件")
            else:
                print(arg1 + str(i + 1) + "=" + infos[arg1 + str(i + 1)])

    for share_code, active_name in activitiesMap.items():
        printShareCode(share_code, active_name)

        # 格式化助力码
        print()
        for j in range(cnt):
            print(share_code + "_SHARECODE" + str(j + 1) + "=" + singleHandle(infos, cnt, j + 1, share_code))


def main():
    # 显示功能菜单
    show_menu()
    while True:

        section = input("请选择您要使用的功能：")
        print("您选择的操作是:[%s]" % section)

        if section == "1":
            multiHandle()
        elif section == "2":
            searchFile(path="./", file_name="sharecodeCollection.log")
            queryAllShareCode(shareCodeFilePaths)
        elif section == "3":
            formatFriendCode("./friend_code.txt")
        elif section == "@":
            if platform.system() == "Darwin":
                print("检测到运行环境为MacOS,打开网页...")
                os.popen(
                    "python3 -mwebbrowser https://github.com/yqchilde/Scripts/tree/main/node/jd", "w")
            else:
                print(
                    "检测到运行环境为Linux,指路：https://github.com/yqchilde/Scripts/tree/main/node/jd")
        elif section == "0":
            print("-" * 50)
            print("\033[32m已退出\033[0m\n")
            break
        else:
            print("-" * 50)
            print("\033[31m输入有误，请重新输入～\033[0m")
            continue

        res = input("\n\033[33m是否继续选择操作，Y / N \033[0m\n")
        if res.upper() == "Y":
            continue
        else:
            print("-" * 50)
            print("\033[32m已退出\033[0m\n")
            break


if __name__ == "__main__":
    main()
