import os

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
    6: "crazyJoys",
    7: "闪购盲盒",
    8: "东东农场",
    9: "财富岛",
}

shareCodeFilePaths = []


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
    print("8-东东农场")
    print("9-财富岛  ", "\t\t\t\t", end="")
    print("10-全部活动")
    print("11-查询助力码", "\t\t\t\t", end="")
    print("12-整理助力码")
    print("0-退出")
    print("-" * 50)


def singleHandle(share_name):
    line = input("请输入需要生成的编号，符号之间用空格隔开：\n")
    nums = list(map(int, line.split()))

    res = ""
    for num in nums:
        res += "${" + share_name + str(num) + "}@"

    print(share_name + "助力码生成结果为：", "\033[32m" + "- " + share_name + "=" + res[:-1] + "\033[0m\n")


def multiHandle():
    line = input("请输入需要生成的编号，符号之间用空格隔开：\n")
    nums = list(map(int, line.split()))

    res = ""
    print("\033[1;36m助力码生成结果如下：\033[0m\n")
    for idx in activitiesEn:
        for num in nums:
            res += "${" + activitiesEn[idx] + str(num) + "}@"

        print("# " + activitiesZh[idx] + "\n\033[32m" + "- " + activitiesEn[idx] + "=" + res[:-1] + "\033[0m\n")
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


def queryAllShareCode(paths):
    if len(paths) == 0:
        print("\033[31m检测到文件位置放置错误，请将该文件放置在项目根目录\033[0m")
        return

    for path in paths:
        fo = open(path, "r")

        infos = {}
        for line in fo.readlines():
            line = line.strip()
            # print(line)

            # 从账号1 start
            if getMiddleStr(line, "【账号1（", "）") != "":
                infos["USERNAME"] = getMiddleStr(line, "【账号1（", "）")
            if "账号1开始" in line:
                infos["START_LINE"] = line[16:]
            if "东东工厂" in line:
                infos["DDFACTORY_LINE"] = line[16:]
            if "京喜工厂" in line:
                infos["DREAM_FACTORY_LINE"] = line[16:]
            if "京喜农场" in line:
                infos["JXNC_LINE"] = line[16:]
            if "京东萌宠" in line:
                infos["PET_LINE"] = line[16:]
            if "种豆得豆" in line:
                infos["PLANT_BEAN_LINE"] = line[16:]
            if "crazyJoy" in line:
                infos["JDJOY_LINE"] = line[16:]
            if "闪购盲盒" in line:
                infos["JDSGMH_LINE"] = line[16:]
            if "京东农场" in line:
                infos["FRUIT_LINE"] = line[16:]
            if "财富岛" in line:
                infos["JDCFD_LINE"] = line[16:]

        fo.close()

        print("\n\033[1;36m" + "京东账号" + "：" + infos["USERNAME"] + "\033[0m")
        print(infos["START_LINE"])
        print(infos["DDFACTORY_LINE"])
        print(infos["DREAM_FACTORY_LINE"])
        print(infos["JXNC_LINE"])
        print(infos["PET_LINE"])
        print(infos["PLANT_BEAN_LINE"])
        print(infos["JDJOY_LINE"])
        print(infos["JDSGMH_LINE"])
        print(infos["FRUIT_LINE"])
        print(infos["JDCFD_LINE"])


def formatFriendCode(path):
    print("请确保好友的助力码保存在 " + path + " 文件中")
    if not os.path.isfile(path):
        print(path + " 文件不存在")
        return
    print("开始整理...\n")

    fo = open(path, "r")

    infos = {}
    cnt = 1
    for line in fo.readlines():
        line = line.strip()
        if getMiddleStr(line, "东东工厂】", "\0") != "":
            if "USERNAME" + str(cnt) in infos:
                infos["USERNAME" + str(cnt + 1)] = getMiddleStr(line, "【账号1（", "）")
                cnt += 1
            else:
                infos["USERNAME" + str(cnt)] = getMiddleStr(line, "【账号1（", "）")
        if getMiddleStr(line, "东东工厂】", "\0") != "":
            if "DDFACTORY_SHARECODES" + str(cnt) in infos:
                infos["DDFACTORY_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "东东工厂】", "\0")
                cnt += 1
            else:
                infos["DDFACTORY_SHARECODES" + str(cnt)] = getMiddleStr(line, "东东工厂】", "\0")
        if getMiddleStr(line, "京喜工厂】", "\0") != "":
            if "DREAM_FACTORY_SHARE_CODES" + str(cnt) in infos:
                infos["DREAM_FACTORY_SHARE_CODES" + str(cnt + 1)] = getMiddleStr(line, "京喜工厂】", "\0")
                cnt += 1
            else:
                infos["DREAM_FACTORY_SHARE_CODES" + str(cnt)] = getMiddleStr(line, "京喜工厂】", "\0")
        if getMiddleStr(line, "京喜农场】", "\0") != "":
            if "JXNC_SHARECODES" + str(cnt) in infos:
                infos["JXNC_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "京喜农场】", "\0")
                cnt += 1
            else:
                infos["JXNC_SHARECODES" + str(cnt)] = getMiddleStr(line, "京喜农场】", "\0")
        if getMiddleStr(line, "京东萌宠】", "\0") != "":
            if "PETSHARECODES" + str(cnt) in infos:
                infos["PETSHARECODES" + str(cnt + 1)] = getMiddleStr(line, "京东萌宠】", "\0")
                cnt += 1
            else:
                infos["PETSHARECODES" + str(cnt)] = getMiddleStr(line, "京东萌宠】", "\0")
        if getMiddleStr(line, "种豆得豆】", "\0") != "":
            if "PLANT_BEAN_SHARECODES" + str(cnt) in infos:
                infos["PLANT_BEAN_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "种豆得豆】", "\0")
                cnt += 1
            else:
                infos["PLANT_BEAN_SHARECODES" + str(cnt)] = getMiddleStr(line, "种豆得豆】", "\0")
        if getMiddleStr(line, "crazyJoy】", "\0") != "":
            if "JDJOY_SHARECODES" + str(cnt) in infos:
                infos["JDJOY_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "crazyJoy】", "\0")
                cnt += 1
            else:
                infos["JDJOY_SHARECODES" + str(cnt)] = getMiddleStr(line, "crazyJoy】", "\0")
        if getMiddleStr(line, "闪购盲盒】", "\0") != "":
            if "JDSGMH_SHARECODES" + str(cnt) in infos:
                infos["JDSGMH_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "闪购盲盒】", "\0")
                cnt += 1
            else:
                infos["JDSGMH_SHARECODES" + str(cnt)] = getMiddleStr(line, "闪购盲盒】", "\0")
        if getMiddleStr(line, "京东农场】", "\0") != "":
            if "FRUITSHARECODES" + str(cnt) in infos:
                infos["FRUITSHARECODES" + str(cnt + 1)] = getMiddleStr(line, "京东农场】", "\0")
                cnt += 1
            else:
                infos["FRUITSHARECODES" + str(cnt)] = getMiddleStr(line, "京东农场】", "\0")
        if getMiddleStr(line, "财富岛】", "(每次都变化,不影响)") != "":
            if "JDCFD_SHARECODES" + str(cnt) in infos:
                infos["JDCFD_SHARECODES" + str(cnt + 1)] = getMiddleStr(line, "财富岛】", "(每次都变化,不影响)")
                cnt += 1
            else:
                infos["JDCFD_SHARECODES" + str(cnt)] = getMiddleStr(line, "财富岛】", "(每次都变化,不影响)")

    print("\n\033[1;36m好友助力码整理结果如下：\033[0m")

    print("\n\033[32m" + "# 助力码顺序" + "\033[0m")
    for i in range(cnt):
        print("# 助力码" + str(i + 1) + "=" + infos["USERNAME" + str(i + 1)])

    print("\n\033[32m" + "# 东东工厂" + "\033[0m")
    for i in range(cnt):
        print("DDFACTORY_SHARECODES" + str(i + 1) + "=" + infos["DDFACTORY_SHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 京喜工厂" + "\033[0m")
    for i in range(cnt):
        print("DREAM_FACTORY_SHARE_CODES" + str(i + 1) + "=" + infos["DREAM_FACTORY_SHARE_CODES" + str(i + 1)])

    print("\n\033[32m" + "# 京喜农场" + "\033[0m")
    for i in range(cnt):
        print("JXNC_SHARECODES" + str(i + 1) + "=" + infos["JXNC_SHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 京东萌宠" + "\033[0m")
    for i in range(cnt):
        print("PETSHARECODES" + str(i + 1) + "=" + infos["PETSHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 种豆得豆" + "\033[0m")
    for i in range(cnt):
        print("PLANT_BEAN_SHARECODES" + str(i + 1) + "=" + infos["PLANT_BEAN_SHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# crazyJoy" + "\033[0m")
    for i in range(cnt):
        print("JDJOY_SHARECODES" + str(i + 1) + "=" + infos["JDJOY_SHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 闪购盲盒" + "\033[0m")
    for i in range(cnt):
        print("JDSGMH_SHARECODES" + str(i + 1) + "=" + infos["JDSGMH_SHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 京东农场" + "\033[0m")
    for i in range(cnt):
        print("FRUITSHARECODES" + str(i + 1) + "=" + infos["FRUITSHARECODES" + str(i + 1)])

    print("\n\033[32m" + "# 财富岛" + "\033[0m")
    for i in range(cnt):
        print("JDCFD_SHARECODES" + str(i + 1) + "=" + infos["JDCFD_SHARECODES" + str(i + 1)])


def main():
    # 显示功能菜单
    show_menu()
    while True:

        section = input("请选择您要使用的功能：")
        print("您选择的操作是:[%s]" % section)

        if section in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]:
            singleHandle(activitiesEn[int(section)])
        elif section == "10":
            multiHandle()
        elif section == "11":
            searchFile(path="./", file_name="jd_get_share_code.log")
            queryAllShareCode(shareCodeFilePaths)
        elif section == "12":
            formatFriendCode("./friend_code.txt")
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
