/**
* 京喜财富岛新版
* 包含雇佣导游，建议每小时1次
京喜财富岛脚本
============QuantumultX==============
[task_local]
#京喜财富岛
0 1-23/1 * * * jd_cfd_new.js, tag=京喜财富岛, img-url=https://raw.githubusercontent.com/Orz-3/mini/master/Color/jd.png, enabled=true
================Loon===============
[Script]
cron "0 1-23/1 * * *" script-path=jd_cfd_new.js, tag=京喜财富岛
=============Surge===========
[Script]
京喜财富岛 = type=cron,cronexp="0 1-23/1 * * *",wake-system=1,timeout=3600,script-path=jd_cfd_new.js

============小火箭=========
 京喜财富岛 = type=cron,script-path=jd_cfd_new.js, cronexpr="0 1-23/1 * * *", timeout=3600, enable=true
*/

const $ = new Env('京喜财富岛新版');
const {format} = require('date-fns');
const axios = require('axios');
const USER_AGENT = require('./USER_AGENTS').USER_AGENT;
const CryptoJS = require('crypto-js')

let appId = 10028, fingerprint, token, enCryptMethodJD;
let cookie= '', cookiesArr= [], res = '', shareCodes = [];

let UserName, index, isLogin, nickName;
!(async () => {
    await requestAlgo();
    await requireConfig();

    for (let i = 0; i < cookiesArr.length; i++) {
        cookie = cookiesArr[i];
        UserName = decodeURIComponent(cookie.match(/pt_pin=([^; ]+)(?=;?)/) && cookie.match(/pt_pin=([^; ]+)(?=;?)/)[1])
        index = i + 1;
        isLogin = true;
        nickName = '';
        await TotalBean();
        console.log(`\n开始【京东账号${index}】${nickName || UserName}\n`);

        await makeShareCodes();

        // 任务1
        let tasks;
        /*
         tasks= await api('story/GetActTask', '_cfd_t,bizCode,dwEnv,ptag,source,strZone')
        for (let t of tasks.Data.TaskList) {
          if (t.dwCompleteNum === t.dwTargetNum && t.dwAwardStatus === 2) {
            res = await api('Award', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', {taskId: t.ddwTaskId})
            if (res.ret === 0) {
              console.log(`${t.strTaskName}领奖成功:`, res.data.prizeInfo)
            }
            await wait(1000)
          }
        }
         */


        // res = await api('story/SpecialUserOper',
        //   '_cfd_t,bizCode,ddwTriggerDay,dwEnv,dwType,ptag,source,strStoryId,strZone,triggerType',
        //   {strStoryId: 'stroy_1626065998453014_1', dwType: '2', triggerType: 0, ddwTriggerDay: 1626019200})
        // console.log('船到:', res)
        // await wait(31000)
        // res = await api('story/SpecialUserOper',
        //   '_cfd_t,bizCode,ddwTriggerDay,dwEnv,dwType,ptag,source,strStoryId,strZone,triggerType',
        //   {strStoryId: 'stroy_1626065998453014_1', dwType: '3', triggerType: 0, ddwTriggerDay: 1626019200})
        // console.log('下船:', res)

        // 导游
        res = await api('user/EmployTourGuideInfo', '_cfd_t,bizCode,dwEnv,ptag,source,strZone')
        if (!res.TourGuideList) {
            console.log('账号尚未完成新手指引，跳过账号')
            continue
        }
        for (let e of res.TourGuideList) {
            if (e.strBuildIndex !== 'food' && e.ddwRemainTm === 0) {
                let employ = await api('user/EmployTourGuide', '_cfd_t,bizCode,ddwConsumeCoin,dwEnv,dwIsFree,ptag,source,strBuildIndex,strZone',
                    {ddwConsumeCoin: e.ddwCostCoin, dwIsFree: 0, strBuildIndex: e.strBuildIndex})
                console.log(employ)
                await wait(3000)
            }
        }

        tasks = await mainTask('GetUserTaskStatusList', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', {taskId: 0});
        for (let t of tasks.data.userTaskStatusList) {
            if (t.dateType === 2) {
                // 每日任务
                if (t.awardStatus === 2 && t.completedTimes === t.targetTimes) {
                    console.log(1, t.taskName)
                    res = await mainTask('Award', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', {taskId: t.taskId})
                    console.log(res)
                    if (res.ret === 0) {
                        console.log(`${t.taskName}领奖成功:`, res.data.prizeInfo)
                    }
                    await wait(2000)
                } else if (t.awardStatus === 2 && t.completedTimes < t.targetTimes && (t.orderId === 2 || t.orderId === 3)) {
                    // console.log('做任务:', t.taskId, t.taskName, t.completedTimes, t.targetTimes)
                    res = await mainTask('DoTask', '_cfd_t,bizCode,configExtra,dwEnv,ptag,source,strZone,taskId', {taskId: t.taskId, configExtra: ''})
                    console.log('做任务:', res)
                    await wait(5000)
                }
            }
        }

        for (let b of ['food', 'fun', 'shop', 'sea']) {
            res = await api('user/GetBuildInfo', '_cfd_t,bizCode,dwEnv,dwType,ptag,source,strBuildIndex,strZone', {strBuildIndex: b})
            console.log(`${b}升级需要:`, res.ddwNextLvlCostCoin)
            await wait(1000)
            if (res.dwCanLvlUp === 1) {
                res = await api('user/BuildLvlUp', '_cfd_t,bizCode,ddwCostCoin,dwEnv,ptag,source,strBuildIndex,strZone', {ddwCostCoin: res.ddwNextLvlCostCoin, strBuildIndex: b})
                if (res.iRet === 0) {
                    console.log(`升级成功`)
                    await wait(2000)
                }
            }
            res = await api('user/CollectCoin', '_cfd_t,bizCode,dwEnv,dwType,ptag,source,strBuildIndex,strZone', {strBuildIndex: b, dwType: '1'})
            console.log(`${b}收金币:`, res.ddwCoin)
            await wait(1000)
        }
    }
    // if (cookiesArr.length === shareCodes.length) {

    // }
    for (let i = 0; i < cookiesArr.length; i++) {
        for (let j = 0; j < shareCodes.length; j++) {
            cookie = cookiesArr[i]
            res = await api('story/helpbystage', '_cfd_t,bizCode,dwEnv,ptag,source,strShareId,strZone', {strShareId: shareCodes[j]})
            console.log(res)
            await wait(1000)
            if (Number(res.iRet) === 2235) {
                console.log('当前账号没有助力次数了')
                continue
            }
        }
    }
})()

// interface Params {
//   strBuildIndex?: string,
//   ddwCostCoin?: number,
//   taskId?: number,
//   dwType?: string,
//   configExtra?: string,
//   strStoryId?: string,
//   triggerType?: number,
//   ddwTriggerDay?: number,
//   ddwConsumeCoin?: number,
//   dwIsFree?: number,
//   ddwTaskId?: string,
//   strShareId?: string,
//   strMarkList?: string
// }

function api(fn, stk, params = {}) {
    return new Promise(async resolve => {
        let url = `https://m.jingxi.com/jxbfd/${fn}?strZone=jxbfd&bizCode=jxbfd&source=jxbfd&dwEnv=7&_cfd_t=${Date.now()}&ptag=&_ste=1&_=${Date.now()}&sceneval=2&_stk=${encodeURIComponent(stk)}`
        if (['GetUserTaskStatusList', 'Award', 'DoTask'].includes(fn)) {
            console.log('api2')
            url = `https://m.jingxi.com/newtasksys/newtasksys_front/${fn}?strZone=jxbfd&bizCode=jxbfddch&source=jxbfd&dwEnv=7&_cfd_t=${Date.now()}&ptag=&_stk=${encodeURIComponent(stk)}&_ste=1&_=${Date.now()}&sceneval=2`
        }
        if (Object.keys(params).length !== 0) {
            let key;

            for (key in params) {
                if (params.hasOwnProperty(key))
                    url += `&${key}=${params[key]}`
            }
        }
        url += '&h5st=' + decrypt(stk, url)
        let {data} = await axios.get(url, {
            headers: {
                'Host': 'm.jingxi.com',
                'Referer': 'https://st.jingxi.com/',
                'User-Agent': USER_AGENT,
                'Cookie': cookie
            }
        })
        resolve(data)
    })
}

function mainTask(fn, stk, params) {
    return new Promise(async resolve => {
        let url = `https://m.jingxi.com/newtasksys/newtasksys_front/${fn}?strZone=jxbfd&bizCode=jxbfd&source=jxbfd&dwEnv=7&_cfd_t=${Date.now()}&ptag=&_stk=${encodeURIComponent(stk)}&_ste=1&_=${Date.now()}&sceneval=2`
        if (Object.keys(params).length !== 0) {
            let key;
            for (key in params) {
                if (params.hasOwnProperty(key))
                    url += `&${key}=${params[key]}`
            }
        }
        url += '&h5st=' + decrypt(stk, url)
        let {data} = await axios.get(url, {
            headers: {
                'X-Requested-With': 'com.jd.pingou',
                'Referer': 'https://st.jingxi.com/',
                'Host': 'm.jingxi.com',
                'User-Agent': USER_AGENT,
                'Cookie': cookie
            }
        })
        resolve(data)
    })
}

function makeShareCodes() {
    return new Promise(async resolve => {
        res = await api('user/QueryUserInfo', '_cfd_t,bizCode,ddwTaskId,dwEnv,ptag,source,strShareId,strZone', {ddwTaskId: '', strShareId: '', strMarkList: 'undefined'})
        console.log('助力码:', res.strMyShareId)
        shareCodes.push(Math.random() > 0.5 ? res.strMyShareId : '9BA4E10331B63F7501C7F9F00889E35CC648012DEAD86B71DB3EAC56591A2AFB')
        resolve()
    })
}

async function requestAlgo() {
    fingerprint = await generateFp();
    return new Promise(async resolve => {
        let {data} = await axios.post('https://cactus.jd.com/request_algo?g_ty=ajax', {
            "version": "1.0",
            "fp": fingerprint,
            "appId": appId,
            "timestamp": Date.now(),
            "platform": "web",
            "expandParams": ""
        }, {
            "headers": {
                'Authority': 'cactus.jd.com',
                'Pragma': 'no-cache',
                'Cache-Control': 'no-cache',
                'Accept': 'application/json',
                'User-Agent': USER_AGENT,
                'Content-Type': 'application/json',
                'Origin': 'https://st.jingxi.com',
                'Sec-Fetch-Site': 'cross-site',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Dest': 'empty',
                'Referer': 'https://st.jingxi.com/',
                'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.7'
            },
        })
        if (data['status'] === 200) {
            token = data.data.result.tk;
            let enCryptMethodJDString = data.data.result.algo;
            if (enCryptMethodJDString) enCryptMethodJD = new Function(`return ${enCryptMethodJDString}`)();
        } else {
            console.log(`fp: ${fingerprint}`)
            console.log('request_algo 签名参数API请求失败:')
        }
        resolve(200)
    })
}

function decrypt(stk, url) {
    const timestamp = (format(new Date(), 'yyyyMMddhhmmssSSS'))
    // console.log(timestamp, 'timestamp')
    let hash1;
    if (fingerprint && token && enCryptMethodJD) {
        hash1 = enCryptMethodJD(token, fingerprint.toString(), timestamp.toString(), appId.toString(), CryptoJS).toString(CryptoJS.enc.Hex);
    } else {
        const random = '5gkjB6SpmC9s';
        token = `tk01wcdf61cb3a8nYUtHcmhSUFFCfddDPRvKvYaMjHkxo6Aj7dhzO+GXGFa9nPXfcgT+mULoF1b1YIS1ghvSlbwhE0Xc`;
        fingerprint = 9686767825751161;
        // $.fingerprint = 7811850938414161;
        const str = `${token}${fingerprint}${timestamp}${appId}${random}`;
        hash1 = CryptoJS.SHA512(str, token).toString(CryptoJS.enc.Hex);
    }
    let st = '';
    stk.split(',').map((item, index) => {
        st += `${item}:${getQueryString(url, item)}${index === stk.split(',').length - 1 ? '' : '&'}`;
    })
    const hash2 = CryptoJS.HmacSHA256(st, hash1.toString()).toString(CryptoJS.enc.Hex);
    return encodeURIComponent(["".concat(timestamp.toString()), "".concat(fingerprint.toString()), "".concat(appId.toString()), "".concat(token), "".concat(hash2)].join(";"))
}

function requireConfig() {
    return new Promise(resolve => {
        console.log('开始获取配置文件\n')
        const jdCookieNode = require('./jdCookie.js');
        Object.keys(jdCookieNode).forEach((item) => {
            if (jdCookieNode[item]) {
                cookiesArr.push(jdCookieNode[item])
            }
        })
        console.log(`共${cookiesArr.length}个京东账号\n`)
        resolve()
    })
}

function TotalBean() {
    return new Promise(async resolve => {
        axios.get('https://me-api.jd.com/user_new/info/GetJDUserInfoUnion', {
            headers: {
                Host: "me-api.jd.com",
                Connection: "keep-alive",
                Cookie: cookie,
                "User-Agent": USER_AGENT,
                "Accept-Language": "zh-cn",
                "Referer": "https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&",
                "Accept-Encoding": "gzip, deflate, br"
            }
        }).then(res => {
            if (res.data) {
                let data = res.data
                if (data['retcode'] === "1001") {
                    isLogin = false; //cookie过期
                    return;
                }
                if (data['retcode'] === "0" && data['data'] && data.data.hasOwnProperty("userInfo")) {
                    nickName = data.data.userInfo.baseInfo.nickname;
                }
            } else {
                console.log('京东服务器返回空数据');
            }
        }).catch(e => {
            console.log('Error:', e)
        })
        resolve();
    })
}

function generateFp() {
    let e = "0123456789";
    let a = 13;
    let i = '';
    for (; a--;)
        i += e[Math.random() * e.length | 0];
    return (i + Date.now()).slice(0, 16)
}

function getQueryString(url, name) {
    let reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    let r = url.split('?')[1].match(reg);
    if (r != null) return unescape(r[2]);
    return '';
}

function wait(t) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve()
        }, t)
    })
}

function Env(t,e){"undefined"!=typeof process&&JSON.stringify(process.env).indexOf("GITHUB")>-1&&process.exit(0);class s{constructor(t){this.env=t}send(t,e="GET"){t="string"==typeof t?{url:t}:t;let s=this.get;return"POST"===e&&(s=this.post),new Promise((e,i)=>{s.call(this,t,(t,s,r)=>{t?i(t):e(s)})})}get(t){return this.send.call(this.env,t)}post(t){return this.send.call(this.env,t,"POST")}}return new class{constructor(t,e){this.name=t,this.http=new s(this),this.data=null,this.dataFile="box.dat",this.logs=[],this.isMute=!1,this.isNeedRewrite=!1,this.logSeparator="\n",this.startTime=(new Date).getTime(),Object.assign(this,e),this.log("",`🔔${this.name}, 开始!`)}isNode(){return"undefined"!=typeof module&&!!module.exports}isQuanX(){return"undefined"!=typeof $task}isSurge(){return"undefined"!=typeof $httpClient&&"undefined"==typeof $loon}isLoon(){return"undefined"!=typeof $loon}toObj(t,e=null){try{return JSON.parse(t)}catch{return e}}toStr(t,e=null){try{return JSON.stringify(t)}catch{return e}}getjson(t,e){let s=e;const i=this.getdata(t);if(i)try{s=JSON.parse(this.getdata(t))}catch{}return s}setjson(t,e){try{return this.setdata(JSON.stringify(t),e)}catch{return!1}}getScript(t){return new Promise(e=>{this.get({url:t},(t,s,i)=>e(i))})}runScript(t,e){return new Promise(s=>{let i=this.getdata("@chavy_boxjs_userCfgs.httpapi");i=i?i.replace(/\n/g,"").trim():i;let r=this.getdata("@chavy_boxjs_userCfgs.httpapi_timeout");r=r?1*r:20,r=e&&e.timeout?e.timeout:r;const[o,h]=i.split("@"),n={url:`http://${h}/v1/scripting/evaluate`,body:{script_text:t,mock_type:"cron",timeout:r},headers:{"X-Key":o,Accept:"*/*"}};this.post(n,(t,e,i)=>s(i))}).catch(t=>this.logErr(t))}loaddata(){if(!this.isNode())return{};{this.fs=this.fs?this.fs:require("fs"),this.path=this.path?this.path:require("path");const t=this.path.resolve(this.dataFile),e=this.path.resolve(process.cwd(),this.dataFile),s=this.fs.existsSync(t),i=!s&&this.fs.existsSync(e);if(!s&&!i)return{};{const i=s?t:e;try{return JSON.parse(this.fs.readFileSync(i))}catch(t){return{}}}}}writedata(){if(this.isNode()){this.fs=this.fs?this.fs:require("fs"),this.path=this.path?this.path:require("path");const t=this.path.resolve(this.dataFile),e=this.path.resolve(process.cwd(),this.dataFile),s=this.fs.existsSync(t),i=!s&&this.fs.existsSync(e),r=JSON.stringify(this.data);s?this.fs.writeFileSync(t,r):i?this.fs.writeFileSync(e,r):this.fs.writeFileSync(t,r)}}lodash_get(t,e,s){const i=e.replace(/\[(\d+)\]/g,".$1").split(".");let r=t;for(const t of i)if(r=Object(r)[t],void 0===r)return s;return r}lodash_set(t,e,s){return Object(t)!==t?t:(Array.isArray(e)||(e=e.toString().match(/[^.[\]]+/g)||[]),e.slice(0,-1).reduce((t,s,i)=>Object(t[s])===t[s]?t[s]:t[s]=Math.abs(e[i+1])>>0==+e[i+1]?[]:{},t)[e[e.length-1]]=s,t)}getdata(t){let e=this.getval(t);if(/^@/.test(t)){const[,s,i]=/^@(.*?)\.(.*?)$/.exec(t),r=s?this.getval(s):"";if(r)try{const t=JSON.parse(r);e=t?this.lodash_get(t,i,""):e}catch(t){e=""}}return e}setdata(t,e){let s=!1;if(/^@/.test(e)){const[,i,r]=/^@(.*?)\.(.*?)$/.exec(e),o=this.getval(i),h=i?"null"===o?null:o||"{}":"{}";try{const e=JSON.parse(h);this.lodash_set(e,r,t),s=this.setval(JSON.stringify(e),i)}catch(e){const o={};this.lodash_set(o,r,t),s=this.setval(JSON.stringify(o),i)}}else s=this.setval(t,e);return s}getval(t){return this.isSurge()||this.isLoon()?$persistentStore.read(t):this.isQuanX()?$prefs.valueForKey(t):this.isNode()?(this.data=this.loaddata(),this.data[t]):this.data&&this.data[t]||null}setval(t,e){return this.isSurge()||this.isLoon()?$persistentStore.write(t,e):this.isQuanX()?$prefs.setValueForKey(t,e):this.isNode()?(this.data=this.loaddata(),this.data[e]=t,this.writedata(),!0):this.data&&this.data[e]||null}initGotEnv(t){this.got=this.got?this.got:require("got"),this.cktough=this.cktough?this.cktough:require("tough-cookie"),this.ckjar=this.ckjar?this.ckjar:new this.cktough.CookieJar,t&&(t.headers=t.headers?t.headers:{},void 0===t.headers.Cookie&&void 0===t.cookieJar&&(t.cookieJar=this.ckjar))}get(t,e=(()=>{})){t.headers&&(delete t.headers["Content-Type"],delete t.headers["Content-Length"]),this.isSurge()||this.isLoon()?(this.isSurge()&&this.isNeedRewrite&&(t.headers=t.headers||{},Object.assign(t.headers,{"X-Surge-Skip-Scripting":!1})),$httpClient.get(t,(t,s,i)=>{!t&&s&&(s.body=i,s.statusCode=s.status),e(t,s,i)})):this.isQuanX()?(this.isNeedRewrite&&(t.opts=t.opts||{},Object.assign(t.opts,{hints:!1})),$task.fetch(t).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>e(t))):this.isNode()&&(this.initGotEnv(t),this.got(t).on("redirect",(t,e)=>{try{if(t.headers["set-cookie"]){const s=t.headers["set-cookie"].map(this.cktough.Cookie.parse).toString();s&&this.ckjar.setCookieSync(s,null),e.cookieJar=this.ckjar}}catch(t){this.logErr(t)}}).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>{const{message:s,response:i}=t;e(s,i,i&&i.body)}))}post(t,e=(()=>{})){if(t.body&&t.headers&&!t.headers["Content-Type"]&&(t.headers["Content-Type"]="application/x-www-form-urlencoded"),t.headers&&delete t.headers["Content-Length"],this.isSurge()||this.isLoon())this.isSurge()&&this.isNeedRewrite&&(t.headers=t.headers||{},Object.assign(t.headers,{"X-Surge-Skip-Scripting":!1})),$httpClient.post(t,(t,s,i)=>{!t&&s&&(s.body=i,s.statusCode=s.status),e(t,s,i)});else if(this.isQuanX())t.method="POST",this.isNeedRewrite&&(t.opts=t.opts||{},Object.assign(t.opts,{hints:!1})),$task.fetch(t).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>e(t));else if(this.isNode()){this.initGotEnv(t);const{url:s,...i}=t;this.got.post(s,i).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>{const{message:s,response:i}=t;e(s,i,i&&i.body)})}}time(t,e=null){const s=e?new Date(e):new Date;let i={"M+":s.getMonth()+1,"d+":s.getDate(),"H+":s.getHours(),"m+":s.getMinutes(),"s+":s.getSeconds(),"q+":Math.floor((s.getMonth()+3)/3),S:s.getMilliseconds()};/(y+)/.test(t)&&(t=t.replace(RegExp.$1,(s.getFullYear()+"").substr(4-RegExp.$1.length)));for(let e in i)new RegExp("("+e+")").test(t)&&(t=t.replace(RegExp.$1,1==RegExp.$1.length?i[e]:("00"+i[e]).substr((""+i[e]).length)));return t}msg(e=t,s="",i="",r){const o=t=>{if(!t)return t;if("string"==typeof t)return this.isLoon()?t:this.isQuanX()?{"open-url":t}:this.isSurge()?{url:t}:void 0;if("object"==typeof t){if(this.isLoon()){let e=t.openUrl||t.url||t["open-url"],s=t.mediaUrl||t["media-url"];return{openUrl:e,mediaUrl:s}}if(this.isQuanX()){let e=t["open-url"]||t.url||t.openUrl,s=t["media-url"]||t.mediaUrl;return{"open-url":e,"media-url":s}}if(this.isSurge()){let e=t.url||t.openUrl||t["open-url"];return{url:e}}}};if(this.isMute||(this.isSurge()||this.isLoon()?$notification.post(e,s,i,o(r)):this.isQuanX()&&$notify(e,s,i,o(r))),!this.isMuteLog){let t=["","==============📣系统通知📣=============="];t.push(e),s&&t.push(s),i&&t.push(i),console.log(t.join("\n")),this.logs=this.logs.concat(t)}}log(...t){t.length>0&&(this.logs=[...this.logs,...t]),console.log(t.join(this.logSeparator))}logErr(t,e){const s=!this.isSurge()&&!this.isQuanX()&&!this.isLoon();s?this.log("",`❗️${this.name}, 错误!`,t.stack):this.log("",`❗️${this.name}, 错误!`,t)}wait(t){return new Promise(e=>setTimeout(e,t))}done(t={}){const e=(new Date).getTime(),s=(e-this.startTime)/1e3;this.log("",`🔔${this.name}, 结束! 🕛 ${s} 秒`),this.log(),(this.isSurge()||this.isQuanX()||this.isLoon())&&$done(t)}}(t,e)}