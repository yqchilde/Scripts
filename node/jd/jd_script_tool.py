import os
import platform

activitiesEn = {
    1: "DDFACTORY_SHARECODES",
    2: "DREAM_FACTORY_SHARE_CODES",
    3: "JXNC_SHARECODES",
    4: "PETSHARECODES",
    5: "PLANT_BEAN_SHARECODES",
    6: "JDJOY_SHARECODES",
    7: "JDSGMH_SHARECODES",
    8: "FRUITSHARECODES",
    9: "JDCFD_SHARECODES",
}

activitiesZh = {
    1: "东东工厂",
    2: "京喜工厂",
    3: "京喜农场",
    4: "京东萌宠",
    5: "种豆得豆",
    6: "crazyJoy",
    7: "闪购盲盒",
    8: "京东农场",
    9: "财富岛",
}

activitiesMap = {
    "DDFACTORY_SHARECODES": "东东工厂",
    "DREAM_FACTORY_SHARE_CODES": "京喜工厂",
    "JXNC_SHARECODES": "京喜农场",
    "PETSHARECODES": "京东萌宠",
    "PLANT_BEAN_SHARECODES": "种豆得豆",
    "JDJOY_SHARECODES": "crazyJoy",
    "JDSGMH_SHARECODES": "闪购盲盒",
    "FRUITSHARECODES": "京东农场",
    "JDCFD_SHARECODES": "财富岛",
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
    print("")
    print("1-东东工厂", "\t\t\t\t", end="")
    print("2-京喜工厂")
    print("3-京喜农场", "\t\t\t\t", end="")
    print("4-京东萌宠")
    print("5-种豆得豆", "\t\t\t\t", end="")
    print("6-crazyJoy")
    print("7-闪购盲盒", "\t\t\t\t", end="")
    print("8-京东农场")
    print("9-财富岛  ", "\t\t\t\t", end="")
    print("10-全部活动")
    print("11-查询助力码", "\t\t\t\t", end="")
    print("12-整理助力码")
    print()
    print("\033[36m@-Help\033[0m", "\t\t\t\t\t", end="")
    print("\033[36m0-退出\033[0m")
    print("-" * 50)


def singleHandle(idx):
    line = input("\n单独生成" + activitiesZh[int(idx)] + "的助力码格式," + "请输入需要生成的编号，符号之间用空格隔开：\n")
    nums = list(map(int, line.split()))

    res = ""
    for num in nums:
        res += "${" + activitiesEn[int(idx)] + str(num) + "}@"

    print(activitiesZh[int(idx)] + "助力码生成结果为：",
          "\033[32m" + "- " + activitiesEn[int(idx)] + "=" + res[:-1] + "\033[0m\n")


def multiHandle():
    print("\n\033[33m生成所有活动的助力码格式\033[0m\n")
    line = input("请按照如下格式输入：1 3 2 代表区间[1,3] 过滤掉2的编号，即 1 3: \n")
    m, n, f = line.split()[0], line.split()[1], line.split()[2]

    res = ""
    print("\n\033[1;36m助力码生成结果如下：\033[0m\n")
    for i in activitiesEn:
        for j in range(int(m), int(n) + 1):
            if str(j) == f:
                continue
            res += "${" + activitiesEn[i] + str(j) + "}@"

        print("# " + activitiesZh[i] + "\n\033[32m" + "- " + activitiesEn[i] + "=" + res[:-1] + "\033[0m\n")
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
            if getMiddleStr(line, "【账号1（", "）") != "":
                infos["USERNAME"] = getMiddleStr(line, "【账号1（", "）")
            if "账号1开始" in line:
                infos["START_LINE"] = line[line.index("="):]
            if "东东工厂】" in line:
                infos["DDFACTORY_LINE"] = line[line.index("【账号1"):]
            if "京喜工厂】" in line:
                infos["DREAM_FACTORY_LINE"] = line[line.index("【账号1"):]
            if "京喜农场】" in line:
                infos["JXNC_LINE"] = line[line.index("【账号1"):]
            if "京东萌宠】" in line:
                infos["PET_LINE"] = line[line.index("【账号1"):]
            if "种豆得豆】" in line:
                infos["PLANT_BEAN_LINE"] = line[line.index("【账号1"):]
            if "crazyJoy】" in line:
                infos["JDJOY_LINE"] = line[line.index("【账号1"):]
            if "闪购盲盒】" in line:
                infos["JDSGMH_LINE"] = line[line.index("【账号1"):]
            if "京东农场】" in line:
                infos["FRUIT_LINE"] = line[line.index("【账号1"):]
            if "财富岛】" in line:
                infos["JDCFD_LINE"] = line[line.index("【账号1"):]

        fo.close()

        print("\n\033[1;36m" + "京东账号" + "：" + infos["USERNAME"] + "\033[0m")
        print(infos["START_LINE"])

        def printLine(line_name, active_name):
            if line_name not in infos:
                print("【账号1（" + infos["USERNAME"] + "）" + active_name + "】未获取到助力码，可能是账号黑了")
            else:
                print(infos[line_name])

        printLine("DDFACTORY_LINE", "东东工厂")
        printLine("DREAM_FACTORY_LINE", "京喜工厂")
        printLine("JXNC_LINE", "京喜农场")
        printLine("PET_LINE", "京东萌宠")
        printLine("PLANT_BEAN_LINE", "种豆得豆")
        printLine("JDJOY_LINE", "crazyJoy")
        printLine("JDSGMH_LINE", "闪购盲盒")
        printLine("FRUIT_LINE", "京东农场")
        printLine("JDCFD_LINE", "财富岛")


def formatFriendCode(path):
    print("请确保好友的助力码保存在 " + path + " 文件中")
    if not os.path.isfile(path):
        print(path + " 文件不存在")
        return
    print("开始整理...\n")

    fo = open(path, "r")

    infos = {}
    cnt = 1

    def setInfos(arg1, arg2, cnt):
        if getMiddleStr(line, "" + arg2 + "】", "\0") != "":
            if arg1 + str(cnt) in infos:
                infos[arg1 + str(cnt + 1)] = getMiddleStr(line, "" + arg2 + "】", "\0")
                cnt += 1
            else:
                infos[arg1 + str(cnt)] = getMiddleStr(line, "" + arg2 + "】", "\0")

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
                infos["USERNAME" + str(cnt + 1)] = getMiddleStr(line, "京东账号：", "\0")
                cnt += 1
            else:
                infos["USERNAME" + str(cnt)] = getMiddleStr(line, "京东账号：", "\0")

        if "USERNAME" + str(cnt) not in infos.keys():
            if getMiddleStr(line, "东东工厂】", "\0") != "":
                if "USERNAME" + str(cnt) in infos:
                    infos["USERNAME" + str(cnt + 1)] = getMiddleStr(line, "【账号1（", "）")
                    cnt += 1
                else:
                    infos["USERNAME" + str(cnt)] = getMiddleStr(line, "【账号1（", "）")

    print("\n\033[1;36m# 好友助力码整理结果如下：\033[0m")
    print("\n\033[32m" + "# 助力码顺序" + "\033[0m")
    for i in range(cnt):
        print("# 助力码" + str(i + 1) + "=" + infos["USERNAME" + str(i + 1)])

    def printShareCode(arg1, arg2):
        print("\n\033[32m" + "# " + arg2 + "" + "\033[0m")
        for i in range(cnt):
            if is_han(infos[arg1 + str(i + 1)][0]):
                print(arg1 + str(i + 1) + "=" + "none")
            else:
                print(arg1 + str(i + 1) + "=" + infos[arg1 + str(i + 1)])

    for share_code, active_name in activitiesMap.items():
        printShareCode(share_code, active_name)


def main():
    # 显示功能菜单
    show_menu()
    while True:

        section = input("请选择您要使用的功能：")
        print("您选择的操作是:[%s]" % section)

        if section in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]:
            singleHandle(section)
        elif section == "10":
            multiHandle()
        elif section == "11":
            searchFile(path="./", file_name="jd_get_share_code.log")
            queryAllShareCode(shareCodeFilePaths)
        elif section == "12":
            formatFriendCode("./friend_code.txt")
        elif section == "@":
            if platform.system() == "Darwin":
                print("检测到运行环境为MacOS,打开网页...")
                os.popen("python3 -mwebbrowser https://github.com/yqchilde/Scripts/tree/main/node/jd", "w")
            else:
                print("检测到运行环境为Linux,指路：https://github.com/yqchilde/Scripts/tree/main/node/jd")
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
