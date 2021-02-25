import time
import requests
import configparser
from helium import *


def read_ini(section, option):
    config = configparser.ConfigParser()
    config.read("./conf.ini")
    return config.get(section, option)


def check_goods():
    start_chrome('https://m.zhipinmall.com/detail/1556#skuId=3616', headless=True)

    time.sleep(0.5)

    click('立即购买')

    wait_until(Text('选择规格').exists)

    if Text('已售罄').exists:
        print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), ' 当前商品还没有货!')
        kill_browser()
        check_goods()
    else:
        print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), '检测到已补货！！！')
        print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()), '发送QQ通知-，-')

        data = {"msg": "检测到已补货！！！"}
        requests.post('https://qmsg.zendee.cn/send/' + read_ini('hemu', 'qmsg_key'), data=data)
        return


check_goods()
