"use strict";
/*
* 京喜财富岛
* 包含雇佣导游，建议每小时1次
============Quantumultx===============
[task_local]
#京喜财富岛
10 * * * * jd_cash.js, tag=京喜财富岛, img-url=https://raw.githubusercontent.com/Orz-3/mini/master/Color/jd.png, enabled=true

================Loon==============
[Script]
cron "10 * * * *" script-path=jd_cash.js,tag=京喜财富岛

===============Surge=================
京喜财富岛 = type=cron,cronexp="10 * * * *",wake-system=1,timeout=3600,script-path=jd_cash.js

============小火箭=========
京喜财富岛 = type=cron,script-path=jd_cash.js, cronexpr="10 * * * *", timeout=3600, enable=true
*/
const $ = new Env('京喜财富岛新版');
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var date_fns_1 = require("date-fns");
var axios_1 = require("axios");
var TS_USER_AGENTS_1 = require("./TS_USER_AGENTS");
var CryptoJS = require('crypto-js');
var appId = 10028, fingerprint, token, enCryptMethodJD;
var cookie = '', cookiesArr = [], res = '', shareCodes;
var UserName, index, isLogin, nickName;
!(function () { return __awaiter(void 0, void 0, void 0, function () {
    var i, tasks, _i, _a, e, employ, _b, _c, t, _d, _e, b;
    return __generator(this, function (_f) {
        switch (_f.label) {
            case 0: return [4 /*yield*/, requestAlgo()];
            case 1:
                _f.sent();
                return [4 /*yield*/, requireConfig()];
            case 2:
                _f.sent();
                i = 0;
                _f.label = 3;
            case 3:
                if (!(i < cookiesArr.length)) return [3 /*break*/, 30];
                cookie = cookiesArr[i];
                UserName = decodeURIComponent(cookie.match(/pt_pin=([^;]*)/)[1]);
                index = i + 1;
                isLogin = true;
                nickName = '';
                return [4 /*yield*/, TotalBean()];
            case 4:
                _f.sent();
                console.log("\n\u5F00\u59CB\u3010\u4EAC\u4E1C\u8D26\u53F7" + index + "\u3011" + (nickName || UserName) + "\n");
                tasks = void 0;
                return [4 /*yield*/, api('user/EmployTourGuideInfo', '_cfd_t,bizCode,dwEnv,ptag,source,strZone')];
            case 5:
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
                res = _f.sent();
                _i = 0, _a = res.TourGuideList;
                _f.label = 6;
            case 6:
                if (!(_i < _a.length)) return [3 /*break*/, 10];
                e = _a[_i];
                console.log(e.dwIsUnLock, e.strGuideName);
                if (!(e.strBuildIndex !== 'food' && e.ddwRemainTm === 0)) return [3 /*break*/, 9];
                return [4 /*yield*/, api('user/EmployTourGuide', '_cfd_t,bizCode,ddwConsumeCoin,dwEnv,dwIsFree,ptag,source,strBuildIndex,strZone', { ddwConsumeCoin: e.ddwCostCoin, dwIsFree: 0, strBuildIndex: e.strBuildIndex })];
            case 7:
                employ = _f.sent();
                console.log(employ);
                return [4 /*yield*/, wait(3000)];
            case 8:
                _f.sent();
                _f.label = 9;
            case 9:
                _i++;
                return [3 /*break*/, 6];
            case 10: return [4 /*yield*/, mainTask('GetUserTaskStatusList', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', { taskId: 0 })];
            case 11:
                tasks = _f.sent();
                _b = 0, _c = tasks.data.userTaskStatusList;
                _f.label = 12;
            case 12:
                if (!(_b < _c.length)) return [3 /*break*/, 19];
                t = _c[_b];
                if (!(t.dateType === 2)) return [3 /*break*/, 18];
                if (!(t.awardStatus === 2 && t.completedTimes === t.targetTimes)) return [3 /*break*/, 15];
                console.log(1, t.taskName);
                return [4 /*yield*/, mainTask('Award', '_cfd_t,bizCode,dwEnv,ptag,source,strZone,taskId', { taskId: t.taskId })];
            case 13:
                res = _f.sent();
                console.log(res);
                if (res.ret === 0) {
                    console.log(t.taskName + "\u9886\u5956\u6210\u529F:", res.data.prizeInfo);
                }
                return [4 /*yield*/, wait(2000)];
            case 14:
                _f.sent();
                return [3 /*break*/, 18];
            case 15:
                if (!(t.awardStatus === 2 && t.completedTimes < t.targetTimes && (t.orderId === 2 || t.orderId === 3))) return [3 /*break*/, 18];
                return [4 /*yield*/, mainTask('DoTask', '_cfd_t,bizCode,configExtra,dwEnv,ptag,source,strZone,taskId', { taskId: t.taskId, configExtra: '' })];
            case 16:
                // console.log('做任务:', t.taskId, t.taskName, t.completedTimes, t.targetTimes)
                res = _f.sent();
                console.log('做任务:', res);
                return [4 /*yield*/, wait(5000)];
            case 17:
                _f.sent();
                _f.label = 18;
            case 18:
                _b++;
                return [3 /*break*/, 12];
            case 19:
                _d = 0, _e = ['food', 'fun', 'shop', 'sea'];
                _f.label = 20;
            case 20:
                if (!(_d < _e.length)) return [3 /*break*/, 29];
                b = _e[_d];
                return [4 /*yield*/, api('user/GetBuildInfo', '_cfd_t,bizCode,dwEnv,dwType,ptag,source,strBuildIndex,strZone', { strBuildIndex: b })];
            case 21:
                res = _f.sent();
                console.log(b + "\u5347\u7EA7\u9700\u8981:", res.ddwNextLvlCostCoin);
                return [4 /*yield*/, wait(1000)];
            case 22:
                _f.sent();
                if (!(res.dwCanLvlUp === 1)) return [3 /*break*/, 25];
                return [4 /*yield*/, api('user/BuildLvlUp', '_cfd_t,bizCode,ddwCostCoin,dwEnv,ptag,source,strBuildIndex,strZone', { ddwCostCoin: res.ddwNextLvlCostCoin, strBuildIndex: b })];
            case 23:
                res = _f.sent();
                if (!(res.iRet === 0)) return [3 /*break*/, 25];
                console.log("\u5347\u7EA7\u6210\u529F");
                return [4 /*yield*/, wait(2000)];
            case 24:
                _f.sent();
                _f.label = 25;
            case 25: return [4 /*yield*/, api('user/CollectCoin', '_cfd_t,bizCode,dwEnv,dwType,ptag,source,strBuildIndex,strZone', { strBuildIndex: b, dwType: '1' })];
            case 26:
                res = _f.sent();
                console.log(b + "\u6536\u91D1\u5E01:", res.ddwCoin);
                return [4 /*yield*/, wait(1000)];
            case 27:
                _f.sent();
                _f.label = 28;
            case 28:
                _d++;
                return [3 /*break*/, 20];
            case 29:
                i++;
                return [3 /*break*/, 3];
            case 30: return [2 /*return*/];
        }
    });
}); })();
function api(fn, stk, params) {
    var _this = this;
    if (params === void 0) { params = {}; }
    return new Promise(function (resolve) { return __awaiter(_this, void 0, void 0, function () {
        var url, key, data;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    url = "https://m.jingxi.com/jxbfd/" + fn + "?strZone=jxbfd&bizCode=jxbfd&source=jxbfd&dwEnv=7&_cfd_t=" + Date.now() + "&ptag=&_ste=1&_=" + Date.now() + "&sceneval=2&_stk=" + encodeURIComponent(stk);
                    if (['GetUserTaskStatusList', 'Award', 'DoTask'].includes(fn)) {
                        console.log('api2');
                        url = "https://m.jingxi.com/newtasksys/newtasksys_front/" + fn + "?strZone=jxbfd&bizCode=jxbfddch&source=jxbfd&dwEnv=7&_cfd_t=" + Date.now() + "&ptag=&_stk=" + encodeURIComponent(stk) + "&_ste=1&_=" + Date.now() + "&sceneval=2";
                    }
                    if (Object.keys(params).length !== 0) {
                        key = void 0;
                        for (key in params) {
                            if (params.hasOwnProperty(key))
                                url += "&" + key + "=" + params[key];
                        }
                    }
                    url += '&h5st=' + decrypt(stk, url);
                    return [4 /*yield*/, axios_1["default"].get(url, {
                        headers: {
                            'Host': 'm.jingxi.com',
                            'Referer': 'https://st.jingxi.com/',
                            'User-Agent': TS_USER_AGENTS_1["default"],
                            'Cookie': cookie
                        }
                    })];
                case 1:
                    data = (_a.sent()).data;
                    resolve(data);
                    return [2 /*return*/];
            }
        });
    }); });
}
function mainTask(fn, stk, params) {
    var _this = this;
    if (params === void 0) { params = {}; }
    return new Promise(function (resolve) { return __awaiter(_this, void 0, void 0, function () {
        var url, key, data;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    url = "https://m.jingxi.com/newtasksys/newtasksys_front/" + fn + "?strZone=jxbfd&bizCode=jxbfd&source=jxbfd&dwEnv=7&_cfd_t=" + Date.now() + "&ptag=&_stk=" + encodeURIComponent(stk) + "&_ste=1&_=" + Date.now() + "&sceneval=2";
                    if (Object.keys(params).length !== 0) {
                        key = void 0;
                        for (key in params) {
                            if (params.hasOwnProperty(key))
                                url += "&" + key + "=" + params[key];
                        }
                    }
                    url += '&h5st=' + decrypt(stk, url);
                    return [4 /*yield*/, axios_1["default"].get(url, {
                        headers: {
                            'X-Requested-With': 'com.jd.pingou',
                            'Referer': 'https://st.jingxi.com/',
                            'Host': 'm.jingxi.com',
                            'User-Agent': TS_USER_AGENTS_1["default"],
                            'Cookie': cookie
                        }
                    })];
                case 1:
                    data = (_a.sent()).data;
                    resolve(data);
                    return [2 /*return*/];
            }
        });
    }); });
}
function requestAlgo() {
    return __awaiter(this, void 0, void 0, function () {
        var _this = this;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, generateFp()];
                case 1:
                    fingerprint = _a.sent();
                    return [2 /*return*/, new Promise(function (resolve) { return __awaiter(_this, void 0, void 0, function () {
                        var data, enCryptMethodJDString;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, axios_1["default"].post('https://cactus.jd.com/request_algo?g_ty=ajax', {
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
                                        'User-Agent': TS_USER_AGENTS_1["default"],
                                        'Content-Type': 'application/json',
                                        'Origin': 'https://st.jingxi.com',
                                        'Sec-Fetch-Site': 'cross-site',
                                        'Sec-Fetch-Mode': 'cors',
                                        'Sec-Fetch-Dest': 'empty',
                                        'Referer': 'https://st.jingxi.com/',
                                        'Accept-Language': 'zh-CN,zh;q=0.9,zh-TW;q=0.8,en;q=0.7'
                                    }
                                })];
                                case 1:
                                    data = (_a.sent()).data;
                                    if (data['status'] === 200) {
                                        token = data.data.result.tk;
                                        enCryptMethodJDString = data.data.result.algo;
                                        if (enCryptMethodJDString)
                                            enCryptMethodJD = new Function("return " + enCryptMethodJDString)();
                                    }
                                    else {
                                        console.log("fp: " + fingerprint);
                                        console.log('request_algo 签名参数API请求失败:');
                                    }
                                    resolve(200);
                                    return [2 /*return*/];
                            }
                        });
                    }); })];
            }
        });
    });
}
function decrypt(stk, url) {
    var timestamp = (date_fns_1.format(new Date(), 'yyyyMMddhhmmssSSS'));
    var hash1;
    if (fingerprint && token && enCryptMethodJD) {
        hash1 = enCryptMethodJD(token, fingerprint.toString(), timestamp.toString(), appId.toString(), CryptoJS).toString(CryptoJS.enc.Hex);
    }
    else {
        var random = '5gkjB6SpmC9s';
        token = "tk01wcdf61cb3a8nYUtHcmhSUFFCfddDPRvKvYaMjHkxo6Aj7dhzO+GXGFa9nPXfcgT+mULoF1b1YIS1ghvSlbwhE0Xc";
        fingerprint = 9686767825751161;
        // $.fingerprint = 7811850938414161;
        var str = "" + token + fingerprint + timestamp + appId + random;
        hash1 = CryptoJS.SHA512(str, token).toString(CryptoJS.enc.Hex);
    }
    var st = '';
    stk.split(',').map(function (item, index) {
        st += item + ":" + getQueryString(url, item) + (index === stk.split(',').length - 1 ? '' : '&');
    });
    var hash2 = CryptoJS.HmacSHA256(st, hash1.toString()).toString(CryptoJS.enc.Hex);
    return encodeURIComponent(["".concat(timestamp.toString()), "".concat(fingerprint.toString()), "".concat(appId.toString()), "".concat(token), "".concat(hash2)].join(";"));
}
function requireConfig() {
    return new Promise(function (resolve) {
        console.log('开始获取配置文件\n');
        var jdCookieNode = require('./jdCookie.js');
        Object.keys(jdCookieNode).forEach(function (item) {
            if (jdCookieNode[item]) {
                cookiesArr.push(jdCookieNode[item]);
            }
        });
        console.log("\u5171" + cookiesArr.length + "\u4E2A\u4EAC\u4E1C\u8D26\u53F7\n");
        resolve();
    });
}
function TotalBean() {
    var _this = this;
    return new Promise(function (resolve) { return __awaiter(_this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            axios_1["default"].get('https://me-api.jd.com/user_new/info/GetJDUserInfoUnion', {
                headers: {
                    Host: "me-api.jd.com",
                    Connection: "keep-alive",
                    Cookie: cookie,
                    "User-Agent": TS_USER_AGENTS_1["default"],
                    "Accept-Language": "zh-cn",
                    "Referer": "https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&",
                    "Accept-Encoding": "gzip, deflate, br"
                }
            }).then(function (res) {
                if (res.data) {
                    var data = res.data;
                    if (data['retcode'] === "1001") {
                        isLogin = false; //cookie过期
                        return;
                    }
                    if (data['retcode'] === "0" && data['data'] && data.data.hasOwnProperty("userInfo")) {
                        nickName = data.data.userInfo.baseInfo.nickname;
                    }
                }
                else {
                    console.log('京东服务器返回空数据');
                }
            })["catch"](function (e) {
                console.log('Error:', e);
            });
            resolve();
            return [2 /*return*/];
        });
    }); });
}
function generateFp() {
    var e = "0123456789";
    var a = 13;
    var i = '';
    for (; a--;)
        i += e[Math.random() * e.length | 0];
    return (i + Date.now()).slice(0, 16);
}
function getQueryString(url, name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = url.split('?')[1].match(reg);
    if (r != null)
        return unescape(r[2]);
    return '';
}
function wait(t) {
    return new Promise(function (resolve) {
        setTimeout(function () {
            resolve();
        }, t);
    });
}

// prettier-ignore
function Env(t,e){"undefined"!=typeof process&&JSON.stringify(process.env).indexOf("GITHUB")>-1&&process.exit(0);class s{constructor(t){this.env=t}send(t,e="GET"){t="string"==typeof t?{url:t}:t;let s=this.get;return"POST"===e&&(s=this.post),new Promise((e,i)=>{s.call(this,t,(t,s,r)=>{t?i(t):e(s)})})}get(t){return this.send.call(this.env,t)}post(t){return this.send.call(this.env,t,"POST")}}return new class{constructor(t,e){this.name=t,this.http=new s(this),this.data=null,this.dataFile="box.dat",this.logs=[],this.isMute=!1,this.isNeedRewrite=!1,this.logSeparator="\n",this.startTime=(new Date).getTime(),Object.assign(this,e),this.log("",`🔔${this.name}, 开始!`)}isNode(){return"undefined"!=typeof module&&!!module.exports}isQuanX(){return"undefined"!=typeof $task}isSurge(){return"undefined"!=typeof $httpClient&&"undefined"==typeof $loon}isLoon(){return"undefined"!=typeof $loon}toObj(t,e=null){try{return JSON.parse(t)}catch{return e}}toStr(t,e=null){try{return JSON.stringify(t)}catch{return e}}getjson(t,e){let s=e;const i=this.getdata(t);if(i)try{s=JSON.parse(this.getdata(t))}catch{}return s}setjson(t,e){try{return this.setdata(JSON.stringify(t),e)}catch{return!1}}getScript(t){return new Promise(e=>{this.get({url:t},(t,s,i)=>e(i))})}runScript(t,e){return new Promise(s=>{let i=this.getdata("@chavy_boxjs_userCfgs.httpapi");i=i?i.replace(/\n/g,"").trim():i;let r=this.getdata("@chavy_boxjs_userCfgs.httpapi_timeout");r=r?1*r:20,r=e&&e.timeout?e.timeout:r;const[o,h]=i.split("@"),n={url:`http://${h}/v1/scripting/evaluate`,body:{script_text:t,mock_type:"cron",timeout:r},headers:{"X-Key":o,Accept:"*/*"}};this.post(n,(t,e,i)=>s(i))}).catch(t=>this.logErr(t))}loaddata(){if(!this.isNode())return{};{this.fs=this.fs?this.fs:require("fs"),this.path=this.path?this.path:require("path");const t=this.path.resolve(this.dataFile),e=this.path.resolve(process.cwd(),this.dataFile),s=this.fs.existsSync(t),i=!s&&this.fs.existsSync(e);if(!s&&!i)return{};{const i=s?t:e;try{return JSON.parse(this.fs.readFileSync(i))}catch(t){return{}}}}}writedata(){if(this.isNode()){this.fs=this.fs?this.fs:require("fs"),this.path=this.path?this.path:require("path");const t=this.path.resolve(this.dataFile),e=this.path.resolve(process.cwd(),this.dataFile),s=this.fs.existsSync(t),i=!s&&this.fs.existsSync(e),r=JSON.stringify(this.data);s?this.fs.writeFileSync(t,r):i?this.fs.writeFileSync(e,r):this.fs.writeFileSync(t,r)}}lodash_get(t,e,s){const i=e.replace(/\[(\d+)\]/g,".$1").split(".");let r=t;for(const t of i)if(r=Object(r)[t],void 0===r)return s;return r}lodash_set(t,e,s){return Object(t)!==t?t:(Array.isArray(e)||(e=e.toString().match(/[^.[\]]+/g)||[]),e.slice(0,-1).reduce((t,s,i)=>Object(t[s])===t[s]?t[s]:t[s]=Math.abs(e[i+1])>>0==+e[i+1]?[]:{},t)[e[e.length-1]]=s,t)}getdata(t){let e=this.getval(t);if(/^@/.test(t)){const[,s,i]=/^@(.*?)\.(.*?)$/.exec(t),r=s?this.getval(s):"";if(r)try{const t=JSON.parse(r);e=t?this.lodash_get(t,i,""):e}catch(t){e=""}}return e}setdata(t,e){let s=!1;if(/^@/.test(e)){const[,i,r]=/^@(.*?)\.(.*?)$/.exec(e),o=this.getval(i),h=i?"null"===o?null:o||"{}":"{}";try{const e=JSON.parse(h);this.lodash_set(e,r,t),s=this.setval(JSON.stringify(e),i)}catch(e){const o={};this.lodash_set(o,r,t),s=this.setval(JSON.stringify(o),i)}}else s=this.setval(t,e);return s}getval(t){return this.isSurge()||this.isLoon()?$persistentStore.read(t):this.isQuanX()?$prefs.valueForKey(t):this.isNode()?(this.data=this.loaddata(),this.data[t]):this.data&&this.data[t]||null}setval(t,e){return this.isSurge()||this.isLoon()?$persistentStore.write(t,e):this.isQuanX()?$prefs.setValueForKey(t,e):this.isNode()?(this.data=this.loaddata(),this.data[e]=t,this.writedata(),!0):this.data&&this.data[e]||null}initGotEnv(t){this.got=this.got?this.got:require("got"),this.cktough=this.cktough?this.cktough:require("tough-cookie"),this.ckjar=this.ckjar?this.ckjar:new this.cktough.CookieJar,t&&(t.headers=t.headers?t.headers:{},void 0===t.headers.Cookie&&void 0===t.cookieJar&&(t.cookieJar=this.ckjar))}get(t,e=(()=>{})){t.headers&&(delete t.headers["Content-Type"],delete t.headers["Content-Length"]),this.isSurge()||this.isLoon()?(this.isSurge()&&this.isNeedRewrite&&(t.headers=t.headers||{},Object.assign(t.headers,{"X-Surge-Skip-Scripting":!1})),$httpClient.get(t,(t,s,i)=>{!t&&s&&(s.body=i,s.statusCode=s.status),e(t,s,i)})):this.isQuanX()?(this.isNeedRewrite&&(t.opts=t.opts||{},Object.assign(t.opts,{hints:!1})),$task.fetch(t).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>e(t))):this.isNode()&&(this.initGotEnv(t),this.got(t).on("redirect",(t,e)=>{try{if(t.headers["set-cookie"]){const s=t.headers["set-cookie"].map(this.cktough.Cookie.parse).toString();s&&this.ckjar.setCookieSync(s,null),e.cookieJar=this.ckjar}}catch(t){this.logErr(t)}}).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>{const{message:s,response:i}=t;e(s,i,i&&i.body)}))}post(t,e=(()=>{})){if(t.body&&t.headers&&!t.headers["Content-Type"]&&(t.headers["Content-Type"]="application/x-www-form-urlencoded"),t.headers&&delete t.headers["Content-Length"],this.isSurge()||this.isLoon())this.isSurge()&&this.isNeedRewrite&&(t.headers=t.headers||{},Object.assign(t.headers,{"X-Surge-Skip-Scripting":!1})),$httpClient.post(t,(t,s,i)=>{!t&&s&&(s.body=i,s.statusCode=s.status),e(t,s,i)});else if(this.isQuanX())t.method="POST",this.isNeedRewrite&&(t.opts=t.opts||{},Object.assign(t.opts,{hints:!1})),$task.fetch(t).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>e(t));else if(this.isNode()){this.initGotEnv(t);const{url:s,...i}=t;this.got.post(s,i).then(t=>{const{statusCode:s,statusCode:i,headers:r,body:o}=t;e(null,{status:s,statusCode:i,headers:r,body:o},o)},t=>{const{message:s,response:i}=t;e(s,i,i&&i.body)})}}time(t,e=null){const s=e?new Date(e):new Date;let i={"M+":s.getMonth()+1,"d+":s.getDate(),"H+":s.getHours(),"m+":s.getMinutes(),"s+":s.getSeconds(),"q+":Math.floor((s.getMonth()+3)/3),S:s.getMilliseconds()};/(y+)/.test(t)&&(t=t.replace(RegExp.$1,(s.getFullYear()+"").substr(4-RegExp.$1.length)));for(let e in i)new RegExp("("+e+")").test(t)&&(t=t.replace(RegExp.$1,1==RegExp.$1.length?i[e]:("00"+i[e]).substr((""+i[e]).length)));return t}msg(e=t,s="",i="",r){const o=t=>{if(!t)return t;if("string"==typeof t)return this.isLoon()?t:this.isQuanX()?{"open-url":t}:this.isSurge()?{url:t}:void 0;if("object"==typeof t){if(this.isLoon()){let e=t.openUrl||t.url||t["open-url"],s=t.mediaUrl||t["media-url"];return{openUrl:e,mediaUrl:s}}if(this.isQuanX()){let e=t["open-url"]||t.url||t.openUrl,s=t["media-url"]||t.mediaUrl;return{"open-url":e,"media-url":s}}if(this.isSurge()){let e=t.url||t.openUrl||t["open-url"];return{url:e}}}};if(this.isMute||(this.isSurge()||this.isLoon()?$notification.post(e,s,i,o(r)):this.isQuanX()&&$notify(e,s,i,o(r))),!this.isMuteLog){let t=["","==============📣系统通知📣=============="];t.push(e),s&&t.push(s),i&&t.push(i),console.log(t.join("\n")),this.logs=this.logs.concat(t)}}log(...t){t.length>0&&(this.logs=[...this.logs,...t]),console.log(t.join(this.logSeparator))}logErr(t,e){const s=!this.isSurge()&&!this.isQuanX()&&!this.isLoon();s?this.log("",`❗️${this.name}, 错误!`,t.stack):this.log("",`❗️${this.name}, 错误!`,t)}wait(t){return new Promise(e=>setTimeout(e,t))}done(t={}){const e=(new Date).getTime(),s=(e-this.startTime)/1e3;this.log("",`🔔${this.name}, 结束! 🕛 ${s} 秒`),this.log(),(this.isSurge()||this.isQuanX()||this.isLoon())&&$done(t)}}(t,e)}
