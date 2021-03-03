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


def show_menu():
    """Menu"""
    print("-" * 50)
    print("\t", "JD Script Format Share Code Tools")
    print("1-东东工厂", "\t\t\t\t", end="")
    print("2-京喜工厂")
    print("3-京喜农场", "\t\t\t\t", end="")
    print("4-京东萌宠")
    print("5-种豆得豆", "\t\t\t\t", end="")
    print("6-crazyJoys")
    print("7-闪购盲盒", "\t\t\t\t", end="")
    print("8-东东农场")
    print("9-财富岛  ", "\t\t\t\t", end="")
    print("10-全部活动")
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
