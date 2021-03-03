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
    print("\t", "JD Script Format Share Code Tools")
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
    for idx, path in enumerate(paths):
        fo = open(path, "r")

        info = {}
        for line in fo.readlines():
            line = line.strip()
            if getMiddleStr(line, "【账号1（", "）") != "":
                info["user_name"] = getMiddleStr(line, "【账号1（", "）")
            if getMiddleStr(line, "东东工厂】", "\0") != "":
                info["DDFACTORY_SHARECODES"] = getMiddleStr(line, "东东工厂】", "\0")
            if getMiddleStr(line, "京喜工厂】", "\0") != "":
                info["DREAM_FACTORY_SHARE_CODES"] = getMiddleStr(line, "京喜工厂】", "\0")
            if getMiddleStr(line, "京喜农场】", "\0") != "":
                info["JXNC_SHARECODES"] = getMiddleStr(line, "京喜农场】", "\0")
            if getMiddleStr(line, "京东萌宠】", "\0") != "":
                info["PETSHARECODES"] = getMiddleStr(line, "京东萌宠】", "\0")
            if getMiddleStr(line, "种豆得豆】", "\0") != "":
                info["PLANT_BEAN_SHARECODES"] = getMiddleStr(line, "种豆得豆】", "\0")
            if getMiddleStr(line, "crazyJoy】", "\0") != "":
                info["JDJOY_SHARECODES"] = getMiddleStr(line, "crazyJoy】", "\0")
            if getMiddleStr(line, "闪购盲盒】", "\0") != "":
                info["JDSGMH_SHARECODES"] = getMiddleStr(line, "闪购盲盒】", "\0")
            if getMiddleStr(line, "京东农场】", "\0") != "":
                info["FRUITSHARECODES"] = getMiddleStr(line, "京东农场】", "\0")
            if getMiddleStr(line, "财富岛】", "\0") != "":
                info["JDCFD_SHARECODES"] = getMiddleStr(line, "财富岛】", "(每次都变化,不影响)")

        fo.close()

        print("\033[1;36m" + "账号" + str(idx + 1) + "：", info["user_name"] + "\033[0m")
        print("东东工厂：", info["DDFACTORY_SHARECODES"])
        print("京喜工厂：", info["DREAM_FACTORY_SHARE_CODES"])
        print("京喜农场：", info["JXNC_SHARECODES"])
        print("京东萌宠：", info["PETSHARECODES"])
        print("种豆得豆：", info["PLANT_BEAN_SHARECODES"])
        print("crazyJoy：", info["JDJOY_SHARECODES"])
        print("闪购盲盒：", info["JDSGMH_SHARECODES"])
        print("京东农场：", info["FRUITSHARECODES"])
        print("财富岛：", info["JDCFD_SHARECODES"], "\n")


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
            searchFile(path="./", file_name="get")
            queryAllShareCode(shareCodeFilePaths)
        elif section == "0":
            print("-" * 50)
            print("\033[32m已退出\033[0m\n")
            break
        else:
            print("-" * 50)
            print("\033[31m输入有误，请重新输入～\033[0m")
            continue

        res = input("\033[33m是否继续选择操作，Y / N \033[0m\n")
        if res.upper() == "Y":
            continue
        else:
            print("-" * 50)
            print("\033[32m已退出\033[0m\n")
            break


if __name__ == "__main__":
    main()
