#!/bin/bash
# 设置文件下载路径
FLIE_PATH='/etc/naray/'
if [ ! -d "${FLIE_PATH}" ]; then

  mkdir -m 777 ${FLIE_PATH}

fi
cd ${FLIE_PATH}
install_naray(){
# ===========================================安装系统依赖=============================================
echo "===========安装系统依赖=============="
sudo apt-get update 

sudo apt-get install -y systemctl 

sudo apt-get install -y unzip bash curl wget

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -

sudo apt-get install -y nodejs

sudo apt-get install -y npm

sudo npm install express http-proxy-middleware request

echo " 已安装nodejs版本"
node -v
echo " 已安装npm版本"
npm -v

# ===========================================预设值变量=============================================

#设置nodejs端口


SPORT=${SPORT:-'80'}

#设置xr-ay路径


BOT_PATH=${BOT_PATH:-'vls'}

#设置xr-ay端口


BOT_PORT=${BOT_PORT:-'8002'}

#设置argo-token
read -p "设置argo-token :" TOK

TOK=${TOK:-'cloudflared.exe service install eyJhIjoiNTRhM2QyMDEwZTk0YmU5MDA3NWQxZmI0NGQ4ZTg2YWEiLCJ0IjoiOGYxOTliNjAtNjRjMi00ZjI0LTliMjEtYzM3ZjM1YjBjNjQ2IiwicyI6IllqbG1aRGswWVRZdFptWXdPQzAwTlRWaExUa3pOamN0TVdSa05HSTBORFZqTVdRMyJ9'}
TOK=$(echo ${TOK} | sed 's@cloudflared.exe service install ey@ey@g')
#设置哪吒
read -p "设置NEZHA_SERVER :" NEZHA_SERVER

NEZHA_SERVER=${NEZHA_SERVER:-'data.xxxxxx'}

read -p "设置NEZHA_KEY :" NEZHA_KEY

NEZHA_KEY=${NEZHA_KEY:-'LPkmAqDxxxx'}


#哪吒其他默认参数，无需更改
read -p "设置NEZHA_PORT(默认443) :" NEZHA_PORT

NEZHA_PORT=${NEZHA_PORT:-'443'}

# 设置NEZHA_TLS为1开启tls，删掉NEZHA_TLS是关闭tls
read -p "设置NEZHA_TLS为1开启tls,0关闭tls(默认1) :" NEZHA_TLS
NEZHA_TLS=${NEZHA_TLS:-'1'}
[ "${NEZHA_TLS}" = "1" ] && TLS='--tls'

# 设置amd64-bot下载地址

 URL_BOT=${URL_BOT:-'https://github.com/dsadsadsss/d/releases/download/sd/kano-6-amd-w'}

# 设置arm64_64-bot下载地址

 URL_BOT2=${URL_BOT2:-'https://github.com/dsadsadsss/d/releases/download/sd/kano-6-arm-w'}



# ===========================================生成nodejs文件=============================================
  cat > ${FLIE_PATH}index.js << \EOF

const express = require("express");
const app = express();
var exec = require("child_process").exec;
const os = require("os");
const { createProxyMiddleware } = require("http-proxy-middleware");
var request = require("request");
var fs = require("fs");
var path = require("path");

//======================分隔符==============================
const port = '${SPORT}';
const vmms = '${BOT_PATH}';
const vmmport = '${BOT_PORT}';
const nezhaser = '${NEZHA_SERVER}';
const nezhaKey = '${NEZHA_KEY}';
const nezport = '${NEZHA_PORT}';
const neztls = '${TLS}';
const argoKey = '${TOK}';
//======================分隔符==============================
// 网页信息
app.get("/", function (req, res) {
  res.send("hello world");
});

// 获取系统进程表
app.get("/stas", function (req, res) {
  let cmdStr = "ps -ef | sed 's@--token.*@--token ${TOKEN}@g;s@-s data.*@-s ${NEZHASERVER}@g'";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.type("html").send("<pre>命令行执行错误：\n" + err + "</pre>");
    } else {
      res.type("html").send("<pre>获取守护进程和系统进程表：\n" + stdout + "</pre>");
    }
  });
});
//获取系统版本、内存信息
app.get("/info", function (req, res) {
  let cmdStr = "cat /etc/*release | grep -E ^NAME";
  exec(cmdStr, function (err, stdout, stderr) {
    if (err) {
      res.send("命令行执行错误：" + err);
    }
    else {
      res.send(
        "命令行执行结果：\n" +
          "Linux System:" +
          stdout +
          "\nRAM:" +
          os.totalmem() / 1000 / 1000 +
          "MB"
      );
    }
  });
});
//获取节点数据
app.get("/list", function (req, res) {
    let cmdStr = "cat ${FLIE_PATH}list.log";
    exec(cmdStr, function (err, stdout, stderr) {
      if (err) {
        res.type("html").send("<pre>命令行执行错误：\n" + err + "</pre>");
      }
      else {
        res.type("html").send("<pre>节点数据：\n\n" + stdout + "</pre>");
      }
    });
  });

app.use(
  `/${vmms}`,
  createProxyMiddleware({
    changeOrigin: true,
    onProxyReq: function (proxyReq, req, res) {},
    pathRewrite: {
      [`^/${vmms}`]: `/${vmms}`,
    },
    target: `http://127.0.0.1:${vmmport}/`,
    ws: true,
  })
);

//======================分隔符==============================
//WEB保活
  function keep_web_alive() {
  // 1.请求主页，保持唤醒
  if (process.env.SPACE_HOST) {
    const url = "https://" + process.env.SPACE_HOST;
    exec("curl -m5 " + url, function (err, stdout, stderr) {
      if (err) {
      } else {
        console.log("请求主页-命令行执行成功"+stdout);
      }
    });
  } else if (process.env.BAOHUO_URL) {
    const url = "https://" + process.env.BAOHUO_URL;
    exec("curl -m5 " + url, function (err, stdout, stderr) {
      if (err) {
      } else {
        console.log("请求主页-命令行执行成功"+stdout);
      }
    });
  } else if (process.env.PROJECT_DOMAIN) {
    const url = "https://" + process.env.PROJECT_DOMAIN + ".glitch.me";
    exec("curl -m5 " + url, function (err, stdout, stderr) {
      if (err) {
      } else {
        console.log("请求主页-命令行执行成功"+stdout);
      }
    });
  } else {
  }

 // 2.请求服务器进程状态列表，若web没在运行，则调起
      exec("pidof web.js", function (err, stdout, stderr) {
  //如果pidof web.js查询不到可以尝试下面的几个命令
   // 'ps -ef | grep "web.js" | grep -v "grep"',
   // 'pgrep -lf web.js',
  //  'pidof web.js',
  //  'ps aux | grep "web.js" | grep -v "grep"',
  //  'ss -nltp | grep "web.js"',

        if (stdout) {
        } else {
          // web 未运行，命令行调起
          exec(`chmod +x ./web.js && nohup ./web.js >/dev/null 2>&1 &`, function (err, stdout, stderr) {
            if (err) {
              console.log("调起web-命令行执行错误");
            } else {
              console.log("调起web-命令行执行成功!");
            }
          });
        }
      });
  }
  setInterval(keep_web_alive, 20 * 1000);
// WEB结束

//======================分隔符==============================
//nez保活
if (nezhaKey) {
  function keep_nezha_alive() {
    if (nezhaKey) {
      exec("pidof nezha.js", function (err, stdout, stderr) {
  //如果pidof nezha.js查询不到可以尝试下面的几个命令
   // 'ps -ef | grep "nezha.js" | grep -v "grep"',
   // 'pgrep -lf nezha.js',
  //  'pidof nezha.js',
  //  'ps aux | grep "nezha.js" | grep -v "grep"',
  //  'ss -nltp | grep "nezha.js"',

        if (stdout) {
        } else {
          // nezha 未运行，命令行调起
          exec(`chmod +x ./nezha.js && nohup ./nezha.js -s ${nezhaser}:${nezport} -p ${nezhaKey} ${neztls} >/dev/null 2>&1 &`, function (err, stdout, stderr) {
            if (err) {
              console.log("调起nezha-命令行执行错误");
            } else {
              console.log("调起nezha-命令行执行成功!");
            }
          });
        }
      });
    } else {
    }
  }

  setInterval(keep_nezha_alive, 20 * 1000);
} else {
}

// nez结束

//======================分隔符==============================
//ar-go保活
if (argoKey) {
  function keep_cff_alive() {
    if (argoKey) {
      exec("pidof cff.js", function (err, stdout, stderr) {
  //如果pidof cff.js查询不到可以尝试下面的几个命令
   // 'ps -ef | grep "cff.js" | grep -v "grep"',
   // 'pgrep -lf cff.js',
  //  'pidof cff.js',
  //  'ps aux | grep "cff.js" | grep -v "grep"',
  //  'ss -nltp | grep "cff.js"',

        if (stdout) {
        } else {
          // ar-go 未运行，命令行调起
          exec(`chmod +x ./cff.js && nohup ./cff.js tunnel --edge-ip-version auto run --token ${argoKey} >/dev/null 2>&1 &`, function (err, stdout, stderr) {
            if (err) {
              console.log("调起ar-go-命令行执行错误");
            } else {
              console.log("调起ar-go-命令行执行成功!");
            }
          });
        }
      });
    } else {

    }
  }

  setInterval(keep_cff_alive, 20 * 1000);
} else {

}

// ar-go保活结束


//======================分隔符==============================
//初始化，下载web
function download_web(callback) {
    let fileName = "web.js";
    let web_url;
    
    if (os.arch() === 'x64' || os.arch() === 'amd64') {

      web_url = '${URL_BOT}';
    } else {

      web_url = '${URL_BOT2}';
    }
    
    
    let stream = fs.createWriteStream(path.join("./", fileName));
    request(web_url)
      .pipe(stream)
      .on("close", function (err) {
        if (err) {
          callback("下载web文件失败");
        } else {
          callback(null);
        }
      });
}
download_web((err) => {
  if (err) {
    console.log("下载web文件失败");
  } else {
    console.log("下载web文件成功");
  }
});

//======================分隔符==============================
//初始化，下载nez
if (nezhaKey) {
function download_nezhan(callback) {
    let fileName = "nezha.js";
    let nez_url;
    
    if (os.arch() === 'x64' || os.arch() === 'amd64') {

      nez_url = process.env.URL_NEZHA || 'https://github.com/dsadsadsss/d/releases/download/sd/nezha-amd';
    } else {

      nez_url = process.env.URL_NEZHA2 || 'https://github.com/dsadsadsss/d/releases/download/sd/nezha-arm';
    }
    
    let stream = fs.createWriteStream(path.join("./", fileName));
    request(nez_url)
      .pipe(stream)
      .on("close", function (err) {
        if (err) {
          callback("下载nez文件失败");
        } else {
          callback(null);
        }
      });
}
download_nezhan((err) => {
  if (err) {
    console.log("下载nez文件失败");
  } else {
    console.log("下载nez文件成功");
  }
});
} else {
    console.log("");
}

//======================分隔符==============================
//初始化，下载ar-go
if (argoKey) {
  function download_cff(callback) {
      let fileName = "cff.js";
      let cff_url;
      
      if (os.arch() === 'x64' || os.arch() === 'amd64') {
  
        cff_url = process.env.URL_CF || 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64';
      } else {
  
        cff_url = process.env.URL_CF2 || 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64';
      }
      
      let stream = fs.createWriteStream(path.join("./", fileName));
      request(cff_url)
        .pipe(stream)
        .on("close", function (err) {
          if (err) {
            callback("下载ar-go文件失败");
          } else {
            callback(null);
          }
        });
  }
  download_cff((err) => {
    if (err) {
      console.log("下载ar-go文件失败");
    } else {
      console.log("下载ar-go文件成功");
    }
  });
  } else {
      console.log("");
  }
app.listen(port, () => console.log(`Example app listening on port ${port}!`));

EOF
sed -i "s#\${SPORT}#${SPORT}#g" ${FLIE_PATH}index.js
sed -i "s#\${BOT_PATH}#${BOT_PATH}#g" ${FLIE_PATH}index.js
sed -i "s#\${BOT_PORT}#${BOT_PORT}#g" ${FLIE_PATH}index.js
sed -i "s#\${NEZHA_SERVER}#${NEZHA_SERVER}#g" ${FLIE_PATH}index.js
sed -i "s#\${NEZHA_KEY}#${NEZHA_KEY}#g" ${FLIE_PATH}index.js
sed -i "s#\${NEZHA_PORT}#${NEZHA_PORT}#g" ${FLIE_PATH}index.js
sed -i "s#\${TLS}#${TLS}#g" ${FLIE_PATH}index.js
sed -i "s#\${TOK}#${TOK}#g" ${FLIE_PATH}index.js
sed -i "s#\${URL_BOT}#${URL_BOT}#g" ${FLIE_PATH}index.js
sed -i "s#\${URL_BOT2}#${URL_BOT2}#g" ${FLIE_PATH}index.js
sed -i "s#\${FLIE_PATH}#${FLIE_PATH}#g" ${FLIE_PATH}index.js
  cat > ${FLIE_PATH}list.log << \EOF
# ===========================================节点格式=============================================
 
                     复制粘贴下面的vless地址，安装格式根据自己的配置修改即可
  
                  本节点需要套CF或使用隧道，修改优选IP和域名，其他配置根据你的配置修改
  
# =================================================================================================
  
  
vless://fd80f56e-93f3-4c85-b2a8-c77216c509a7@cdn.xn--b6gac.eu.org:443?host=ARGO%E9%9A%A7%E9%81%93%E5%9F%9F%E5%90%8D%E6%88%96%E5%A5%97%E4%BA%86CF%E7%9A%84%E5%9F%9F%E5%90%8D&path=%2Fvls%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=ARGO%E9%9A%A7%E9%81%93%E5%9F%9F%E5%90%8D%E6%88%96%E5%A5%97%E4%BA%86CF%E7%9A%84%E5%9F%9F%E5%90%8D#vps-vless


# =================================================================================================
  
EOF
  cat > ${FLIE_PATH}start.sh << EOF
#!/bin/bash
cd ${FLIE_PATH}
node ${FLIE_PATH}index.js
EOF
chmod +x ${FLIE_PATH}start.sh
# ===========================================添加开机启动=============================================
  cat > /etc/systemd/system/naray.service << EOF
[Unit]
Description=naray service
After=network.target network-online.target syslog.target
Wants=network.target network-online.target

[Service]
Type=simple


ExecStart=${FLIE_PATH}start.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
sleep 3
systemctl enable --now naray
sleep 3
echo "========================================================================"
echo "        "
[ "$(systemctl is-active naray)" = 'active' ] && echo "                      X-RA-Y安装成功!"

[ "$(systemctl is-active naray)" != 'active' ] && echo "                      X-RA-Y安装失败!"
echo "         "
echo "                      输入域名/list查看节点信息         "
echo "         "
echo "========================================================================"
}

install_bbr(){
[ ! -s ./tcp.sh ] && wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"

chmod +x ./tcp.sh
./tcp.sh
}

start_menu1(){
echo "————————————选择菜单————————————"
echo " "
echo "————————————1、安装 X-R-A-Y————————————"
echo " "
echo "————————————2、安装 bbr加速————————————"
echo " "
echo "————————————3、退出脚本————————————"
echo " "
read -p " 请输入数字 [1-3]:" numb
case "$numb" in
	1)
	install_naray
	;;
	2)
	install_bbr
	;;
	2)
	check_sys_bbrplus
	;;
	3)
		exit 1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-3]"
	sleep 5s
	start_menu1
	;;
esac
}
start_menu1
