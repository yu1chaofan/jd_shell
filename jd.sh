#!/usr/bin/env bash

## Author: lan-tianxiang
## Source: https://github.com/lan-tianxiang/jd_shell
## Modified： 2021-03-31
## Version： v0.0.1

## 文件夹路径
ShellDir=${JD_DIR:-$(cd $(dirname $0); pwd)}
LogDir=${ShellDir}/log
PanelDir=${ShellDir}/panel
ConfigDir=${ShellDir}/config
WebshellDir=${ShellDir}/webshell
ScriptsDir=${ShellDir}/scripts
Scripts2Dir=${ShellDir}/scripts2
[ ! -d ${LogDir} ] && mkdir -p ${LogDir}
[ ! -d ${ScriptsDir} ] && mkdir -p ${ScriptsDir}

## 文件路径
FileDiy=${ConfigDir}/diy.sh
FileConf=${ConfigDir}/config.sh
FileConftemp=${ConfigDir}/config.sh.temp
FileConfSample=${ShellDir}/sample/config.sh.sample

ContentVersion=${ShellDir}/version
ContentNewTask=${ShellDir}/new_task
ContentDropTask=${ShellDir}/drop_task

panelpwd=${ConfigDir}/auth.json
panelpwdSample=${ShellDir}/sample/auth.json

HelpJd=jd.sh
ShellJd=${ShellDir}/jd.sh
SendCount=${ShellDir}/send_count
ListJs=${LogDir}/js.list
ListTask=${LogDir}/task.list
ListJsAdd=${LogDir}/js-add.list
ListJsDrop=${LogDir}/js-drop.list
ListCron=${ConfigDir}/crontab.list
ListCronLxk=${ScriptsDir}/docker/crontab_list.sh
ListCronShylocks=${Scripts2Dir}/docker/crontab_list.sh
ListScripts=($(cd ${ScriptsDir}; ls *.js | grep -E "j[drx]_"))

## 链接区
Scripts2URL=https://gitee.com/highdimen/jd_scripts


## 常量区
AutoHelpme=false
TasksTerminateTime=0
Tips="从日志中未找到任何互助码"

## 所有有互助码的活动，只需要把脚本名称去掉前缀 jd_ 后列在 Name1 中，将其中文名称列在 Name2 中，对应 config.sh 中互助码后缀列在 Name3 中即可。
## Name1、Name2 和 Name3 中的三个名称必须一一对应。
Name1=(fruit pet plantBean dreamFactory jdfactory crazy_joy jdzz jxnc bookshop cash sgmh cfd global)
Name2=(东东农场 东东萌宠 京东种豆得豆 京喜工厂 东东工厂 crazyJoy任务 京东赚赚 京喜农场 口袋书店 签到领现金 闪购盲盒 京喜财富岛 环球挑战赛)
Name3=(Fruit Pet Bean DreamFactory JdFactory Joy Jdzz Jxnc BookShop Cash Sgmh Cfd Global)


## 判断区
isTermux=${ANDROID_RUNTIME_ROOT}${ANDROID_ROOT}
[[ ${ANDROID_RUNTIME_ROOT}${ANDROID_ROOT} ]] && Opt="P" || Opt="E"
WhichDep=$(grep "/jd_shell" "${ShellDir}/.git/config")

if [[ ${WhichDep} == *github* ]]; then
  ScriptsURL=https://gitee.com/highdimen/clone_scripts
  ShellURL=https://gitee.com/highdimen/jd_shell
else
  ScriptsURL=https://gitee.com/highdimen/clone_scripts
  ShellURL=https://gitee.com/highdimen/jd_shell
fi




































































































































































































































## 1.==================================更新函数区==================================
## 脚本源替换
function SourceUrl_Update {
if [ -s ${ScriptsDir}/.git/config ]; then
    strAttttt=`grep "url" ${ScriptsDir}/.git/config`
    strBttttt="highdimen"
  if [[ $strAttttt =~ $strBttttt ]]
    then
    echo "1"
    else
    rm -rf ${ScriptsDir}
  fi
fi

if [ -s ${Scripts2Dir}/.git/config ]; then
    strAttttt=`grep "url" ${Scripts2Dir}/.git/config`
    strBttttt="highdimen"
  if [[ $strAttttt =~ $strBttttt ]]
    then
    echo "1"
    else
    rm -rf ${ScriptsDir}
  fi
fi

  strAttttt=`grep "url" ${ShellDir}/.git/config`
  strBttttt="highdimen"
if [[ $strAttttt =~ $strBttttt ]]
  then
  echo "3"
  else
  perl -i -pe "s|url \= https\:\/\/github.com\/lan-tianxiang\/jd_shell|url \= https\:\/\/gitee.com\/highdimen\/jd_shell|g" ${ShellDir}/.git/config
  perl -i -pe "s|url \= https\:\/\/gitee.com\/tianxiang-lan\/jd_shell|url \= https\:\/\/gitee.com\/highdimen\/jd_shell|g" ${ShellDir}/.git/config
  perl -i -pe "s|url \= http\:\/\/github.com\/lan-tianxiang\/jd_shell|url \= https\:\/\/gitee.com\/highdimen\/jd_shell|g" ${ShellDir}/.git/config
  perl -i -pe "s|url \= http\:\/\/gitee.com\/tianxiang-lan\/jd_shell|url \= https\:\/\/gitee.com\/highdimen\/jd_shell|g" ${ShellDir}/.git/config
fi
}

## 更新crontab，gitee服务器同一时间限制5个链接，因此每个人更新代码必须错开时间，每次执行git_pull随机生成。
## 每天次数随机，更新时间随机，更新秒数随机，至少6次，至多12次，大部分为8-10次，符合正态分布。
function Update_Cron() {
  if [[ $(date "+%-H") -le 2 ]] && [ -f ${ListCron} ]; then
    RanMin=$((${RANDOM} % 60))
    RanSleep=$((${RANDOM} % 56))
    RanHourArray[0]=$((${RANDOM} % 3))
    for ((i = 1; i < 14; i++)); do
      j=$(($i - 1))
      tmp=$((${RANDOM} % 3 + ${RanHourArray[j]} + 2))
      [[ ${tmp} -lt 24 ]] && RanHourArray[i]=${tmp} || break
    done
    RanHour=${RanHourArray[0]}
    for ((i = 1; i < ${#RanHourArray[*]}; i++)); do
      RanHour="${RanHour},${RanHourArray[i]}"
    done
    perl -i -pe "s|.+(bash.+git_pull.+log.*)|${RanMin} ${RanHour} \* \* \* sleep ${RanSleep} && \1|" ${ListCron}
    perl -i -pe "s|5 7,23 19-25 2 .* (.+jd_nzmh\W*.*)|5 7,23 19-25 2 * bash \1|" ${ListCron} # 紧急修复错误的cron
    perl -i -pe "s|30 8-20/4(.+jd_nian\W*.*)|28 8-20/4,21\1|" ${ListCron} # 修改默认错误的cron
    crontab ${ListCron}
  fi
}

## 更新shell脚本
function Git_PullShell {
  echo -e "更新shell脚本，原地址：${ShellURL}\n"
  cd ${ShellDir}
  git fetch --all
  ExitStatusShell=$?
  git reset --hard origin/A1
}


## 克隆scripts
function Git_CloneScripts {
  echo -e "克隆LXK9301脚本，原地址：${ScriptsURL}\n"
  git clone -b master ${ScriptsURL} ${ScriptsDir}
  ExitStatusScripts=$?
  echo
}

## 更新scripts
function Git_PullScripts {
  echo -e "更新LXK9301脚本，原地址：${ScriptsURL}\n"
  cd ${ScriptsDir}
  git fetch --all
  ExitStatusScripts=$?
  git reset --hard origin/master
  echo
}

## 克隆scripts2
function Git_CloneScripts2 {
  echo -e "克隆shylocks脚本，原地址：${Scripts2URL}\n"
  git clone -b master ${Scripts2URL} ${Scripts2Dir}
  ExitStatusScripts2=$?
  echo
}

## 更新scripts2
function Git_PullScripts2 {
  echo -e "更新shylocks脚本，原地址：${Scripts2URL}\n"
  cd ${Scripts2Dir}
  git fetch --all
  ExitStatusScripts2=$?
  git reset --hard origin/master
  echo
}

## 用户数量UserSum
function Count_UserSum {
  i=1
  while [ $i -le 1000 ]; do
    Tmp=Cookie$i
    CookieTmp=${!Tmp}
    [[ ${CookieTmp} ]] && UserSum=$i || break
    let i++
  done
}

## 把config.sh中提供的所有账户的PIN附加在jd_joy_run.js中，让各账户相互进行宠汪汪赛跑助力
## 你的账号将按Cookie顺序被优先助力，助力完成再助力我的账号和lxk0301大佬的账号
function Change_JoyRunPins {
  j=${UserSum}
  PinALL=""
  while [[ $j -ge 1 ]]
  do
    Tmp=Cookie$j
    CookieTemp=${!Tmp}
    PinTemp=$(echo ${CookieTemp} | perl -pe "{s|.*pt_pin=(.+);|\1|; s|%|\\\x|g}")
    PinTempFormat=$(printf ${PinTemp})
    PinALL="${PinTempFormat},${PinALL}"
    let j--
  done
  PinEvine="jd_620b506d07889,"
  PinALL="${PinALL}${PinEvine}"
  perl -i -pe "{s|(let invite_pins = \[\")(.+\"\];?)|\1${PinALL}\2|; s|(let run_pins = \[\")(.+\"\];?)|\1${PinALL}\2|}" ${ScriptsDir}/jd_joy_run.js
}

## 修改lxk0301大佬js文件的函数汇总
function Change_ALL {
  if [ -f ${FileConf} ]; then
    . ${FileConf}
    if [ -n "${Cookie1}" ]; then
      Count_UserSum
      Change_JoyRunPins
    fi
  fi
}

## 检测文件：LXK9301/jd_scripts 仓库中的 docker/crontab_list.sh，和 shylocks/Loon 仓库中的 docker/crontab_list.sh
## 检测定时任务是否有变化，此函数会在Log文件夹下生成四个文件，分别为：
## task.list    crontab.list中的所有任务清单，仅保留脚本名
## js.list      上述检测文件中用来运行js脚本的清单（去掉后缀.js，非运行脚本的不会包括在内）
## js-add.list  如果上述检测文件增加了定时任务，这个文件内容将不为空
## js-drop.list 如果上述检测文件删除了定时任务，这个文件内容将不为空
function Diff_Cron {
  if [ -f ${ListCron} ]; then
    if [ -n "${JD_DIR}" ]
    then
      grep -E " j[drx]_\w+" ${ListCron} | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | uniq | sort > ${ListTask}
    else
      grep "${ShellDir}/" ${ListCron} | grep -E " j[drx]_\w+" | perl -pe "s|.+ (j[drx]_\w+).*|\1|" | uniq | sort > ${ListTask}
    fi
    cat ${ListCronLxk} ${ListCronShylocks} | grep -E "j[drx]_\w+\.js" | perl -pe "s|.+(j[drx]_\w+)\.js.+|\1|" | sort > ${ListJs}
    grep -vwf ${ListTask} ${ListJs} > ${ListJsAdd}
    grep -vwf ${ListJs} ${ListTask} > ${ListJsDrop}
  else
    echo -e "${ListCron} 文件不存在，请先定义你自己的crontab.list...\n"
  fi
}

## 发送删除失效定时任务的消息
function Notify_DropTask {
  cd ${ShellDir}
  node update.js
  [ -f ${ContentDropTask} ] && rm -f ${ContentDropTask}
}

## 发送新的定时任务消息
function Notify_NewTask {
  cd ${ShellDir}
  node update.js
  [ -f ${ContentNewTask} ] && rm -f ${ContentNewTask}
}

## 检测配置文件版本
function Notify_Version {
  ## 识别出两个文件的版本号
  VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
  [ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")

  ## 删除旧的发送记录文件
  [ -f "${SendCount}" ] && [[ $(cat ${SendCount}) != ${VerConfSample} ]] && rm -f ${SendCount}

  ## 识别出更新日期和更新内容
  UpdateDate=$(grep " Date: " ${FileConfSample} | awk -F ": " '{print $2}')
  UpdateContent=$(grep " Update Content: " ${FileConfSample} | awk -F ": " '{print $2}')

  ## 如果是今天，并且版本号不一致，则发送通知
  if [ -f ${FileConf} ] && [[ "${VerConf}" != "${VerConfSample}" ]] && [[ ${UpdateDate} == $(date "+%Y-%m-%d") ]]; then
    if [ ! -f ${SendCount} ]; then
      echo -e "日期: ${UpdateDate}\n版本: ${VerConf} -> ${VerConfSample}\n内容: ${UpdateContent}\n\n" | tee ${ContentVersion}
      echo -e "如需更新请手动操作，仅更新当天通知一次!" >>${ContentVersion}
      cd ${ShellDir}
      node update.js
      if [ $? -eq 0 ]; then
        echo "${VerConfSample}" >${SendCount}
        [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
      fi
    fi
  else
    [ -f ${ContentVersion} ] && rm -f ${ContentVersion}
    [ -f ${SendCount} ] && rm -f ${SendCount}
  fi
}

## npm install 子程序，判断是否为安卓，判断是否安装有yarn
function Npm_InstallSub {
  if ! type yarn >/dev/null 2>&1
  then
    npm install || npm install --registry=https://registry.npm.taobao.org
  else
    echo -e "检测到本机安装了 yarn，使用 yarn 替代 npm...\n"
    yarn install || yarn install --registry=https://registry.npm.taobao.org
  fi
}

## npm install
function Npm_Install {
  cd ${ScriptsDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到package.json有变化，运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${ScriptsDir}/node_modules
    fi
    echo
  fi

  if [ ! -d ${ScriptsDir}/node_modules ]; then
    echo -e "运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n"
      echo -e "请进入 ${ScriptsDir} 目录后按照wiki教程手动运行 npm install...\n"
      echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务...\n"
      echo -e "3...\n"
      sleep 1
      echo -e "2...\n"
      sleep 1
      echo -e "1...\n"
      sleep 1
      rm -rf ${ScriptsDir}/node_modules
    fi
  fi
}

## 输出是否有新的定时任务
function Output_ListJsAdd {
  if [ -s ${ListJsAdd} ]; then
    echo -e "检测到有新的定时任务：\n"
    cat ${ListJsAdd}
    echo
  fi
}

## 输出是否有失效的定时任务
function Output_ListJsDrop {
  if [ ${ExitStatusScripts} -eq 0 ] && [ -s ${ListJsDrop} ]; then
    echo -e "检测到有失效的定时任务：\n"
    cat ${ListJsDrop}
    echo
  fi
}

## 自动删除失效的脚本与定时任务，需要5个条件：1.AutoDelCron 设置为 true；2.正常更新js脚本，没有报错；3.js-drop.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 检测文件：LXK9301/jd_scripts 仓库中的 docker/crontab_list.sh，和 shylocks/Loon 仓库中的 docker/crontab_list.sh
## 如果检测到某个定时任务在上述检测文件中已删除，那么在本地也删除对应定时任务
function Del_Cron {
  if [ "${AutoDelCron}" = "true" ] && [ -s ${ListJsDrop} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动删除定时任务如下：\n"
    cat ${ListJsDrop}
    echo
    JsDrop=$(cat ${ListJsDrop})
    for Cron in ${JsDrop}
    do
      perl -i -ne "{print unless / ${Cron}( |$)/}" ${ListCron}
    done
    crontab ${ListCron}
    echo -e "成功删除失效的脚本与定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
    crontab -l
    echo -e "\n--------------------------------------------------------------\n"
    if [ -d ${ScriptsDir}/node_modules ]; then
      echo -e "jd-base脚本成功删除失效的定时任务：\n\n${JsDrop}\n\n脚本地址：${ShellURL}" > ${ContentDropTask}
      Notify_DropTask
    fi
  fi
}

## 自动增加新的定时任务，需要5个条件：1.AutoAddCron 设置为 true；2.正常更新js脚本，没有报错；3.js-add.list不为空；4.crontab.list存在并且不为空；5.已经正常运行过npm install
## 检测文件：LXK9301/jd_scripts 仓库中的 docker/crontab_list.sh，和 shylocks/Loon 仓库中的 docker/crontab_list.sh
## 如果检测到检测文件中增加新的定时任务，那么在本地也增加
## 本功能生效时，会自动从检测文件新增加的任务中读取时间，该时间为北京时间
function Add_Cron {
  if [ "${AutoAddCron}" = "true" ] && [ -s ${ListJsAdd} ] && [ -s ${ListCron} ] && [ -d ${ScriptsDir}/node_modules ]; then
    echo -e "开始尝试自动添加定时任务如下：\n"
    cat ${ListJsAdd}
    echo
    JsAdd=$(cat ${ListJsAdd})

    for Cron in ${JsAdd}
    do
      if [[ ${Cron} == jd_bean_sign ]]
      then
        echo "4 0,9 * * * bash ${ShellJd} ${Cron}" >> ${ListCron}
      else
        cat ${ListCronLxk} ${ListCronShylocks} | grep -E "\/${Cron}\." | perl -pe "s|(^.+)node */scripts/(j[drx]_\w+)\.js.+|\1bash ${ShellJd} \2|" >> ${ListCron}
      fi
    done

    if [ $? -eq 0 ]
    then
      crontab ${ListCron}
      echo -e "成功添加新的定时任务，当前的定时任务清单如下：\n\n--------------------------------------------------------------\n"
      crontab -l
      echo -e "\n--------------------------------------------------------------\n"
      if [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "jd-base脚本成功添加新的定时任务：\n\n${JsAdd}\n\n脚本地址：${ShellURL}" > ${ContentNewTask}
        Notify_NewTask
      fi
    else
      echo -e "添加新的定时任务出错，请手动添加...\n"
      if [ -d ${ScriptsDir}/node_modules ]; then
        echo -e "jd-base脚本尝试自动添加以下新的定时任务出错，请手动添加：\n\n${JsAdd}" > ${ContentNewTask}
        Notify_NewTask
      fi
    fi
  fi
}


## 自定义脚本功能
function ExtraShell() {
  ## 自动同步用户自定义的diy.sh
  EnableExtraShellURL="https://gitee.com/highdimen/jd_shell/raw/A1/sample/diy.sh"
  if [[ ${EnableExtraShellUpdate} == true ]]; then
    wget -q $EnableExtraShellURL -O ${FileDiy}
    if [ $? -eq 0 ]; then
      echo -e "自定义 DIY 脚本同步完成......"
      echo -e ''
      sleep 2s
    else
      echo -e "\033[31m自定义 DIY 脚本同步失败！\033[0m"
      echo -e ''
      sleep 2s
    fi
  fi

  ## 调用用户自定义的diy.sh
  if [[ ${EnableExtraShell} == true ]]; then
    if [ -f ${FileDiy} ]; then
      . ${FileDiy}
    else
      echo -e "${FileDiy} 文件不存在，跳过执行自定义 DIY 脚本...\n"
      echo -e ''
    fi
  fi
}

## 一键执行所有活动脚本
function Run_All() {
  ## 临时删除以旧版脚本
  rm -rf ${ShellDir}/run-all.sh
  ## 默认将 "jd、jx、jr" 开头的活动脚本加入其中
  rm -rf ${ShellDir}/run_all.sh
  bash ${ShellDir}/jd.sh | grep -io 'j[drx]_[a-z].*' | grep -v 'bean_change' >${ShellDir}/run_all.sh
  sed -i "1i\jd_bean_change.js" ${ShellDir}/run_all.sh ## 置顶京豆变动通知
  sed -i "s#^#bash ${ShellDir}/jd.sh &#g" ${ShellDir}/run_all.sh
  sed -i 's#.js# now#g' ${ShellDir}/run_all.sh
  sed -i '1i\#!/bin/env bash' ${ShellDir}/run_all.sh
  ## 自定义添加脚本
  ## 例：echo "bash ${ShellDir}/jd.sh xxx now" >>${ShellDir}/run_all.sh

  ## 将挂机活动移至末尾从而最后执行
  ## 目前仅有 "疯狂的JOY" 这一个活动
  ## 模板如下 ：
  ## cat run_all.sh | grep xxx -wq
  ## if [ $? -eq 0 ];then
  ##   sed -i '/xxx/d' ${ShellDir}/run_all.sh
  ##   echo "bash jd.sh xxx now" >>${ShellDir}/run_all.sh
  ## fi
  cat ${ShellDir}/run_all.sh | grep jd_crazy_joy_coin -wq
  if [ $? -eq 0 ]; then
    sed -i '/jd_crazy_joy_coin/d' ${ShellDir}/run_all.sh
    echo "bash ${ShellDir}/jd.sh jd_crazy_joy_coin now" >>${ShellDir}/run_all.sh
  fi

  ## 去除不想加入到此脚本中的活动
  ## 例：sed -i '/xxx/d' ${ShellDir}/run_all.sh
  sed -i '/jd_delCoupon/d' ${ShellDir}/run_all.sh ## 不执行 "京东家庭号" 活动
  sed -i '/jd_family/d' ${ShellDir}/run_all.sh    ## 不执行 "删除优惠券" 活动

  ## 去除脚本中的空行
  sed -i '/^\s*$/d' ${ShellDir}/run_all.sh
  ## 赋权
  chmod 777 ${ShellDir}/run_all.sh
}

function panelinit {
  [ -f ${PanelDir}/package.json ] && PackageListOld=$(cat ${PanelDir}/package.json)
  cd ${PanelDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到package.json有变化，运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${PanelDir}/node_modules
    fi
    echo
  fi

  if [ ! -d ${PanelDir}/node_modules ]; then
    echo -e "运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n"
      echo -e "请进入 ${ScriptsDir} 目录后按照wiki教程手动运行 npm install...\n"
      echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务...\n"
      echo -e "3...\n"
      sleep 1
      echo -e "2...\n"
      sleep 1
      echo -e "1...\n"
      sleep 1
      rm -rf ${PanelDir}/node_modules
    fi
  fi
  echo -e "控制面板检查&更新完成"
  sleep 1
  if [ ! -s ${panelpwd} ]; then
    cp -f ${panelpwdSample} ${panelpwd}
    echo -e "检测到未设置密码，用户名：admin，密码：adminadmin\n"
  fi
}


function UpdateFuntionall {
## 在日志中记录时间与路径
echo -e ''
echo -e "+----------------- 开 始 执 行 更 新 脚 本 -----------------+"
echo -e ''
echo -e "   活动脚本目录：${ScriptsDir}"
echo -e ''
echo -e "   当前系统时间：$(date "+%Y-%m-%d %H:%M")"
echo -e ''
echo -e "+-----------------------------------------------------------+"
## 检测配置文件链接
SourceUrl_Update
## 更新shell脚本、检测配置文件版本并将sample/config.sh.sample复制到config目录下
Git_PullShell && Update_Cron
VerConfSample=$(grep " Version: " ${FileConfSample} | perl -pe "s|.+v((\d+\.?){3})|\1|")
[ -f ${FileConf} ] && VerConf=$(grep " Version: " ${FileConf} | perl -pe "s|.+v((\d+\.?){3})|\1|")
if [ ${ExitStatusShell} -eq 0 ]
then
  echo -e "\nshell脚本更新完成...\n"
  if [ -n "${JD_DIR}" ] && [ -d ${ConfigDir} ]; then
    cp -f ${FileConfSample} ${ConfigDir}/config.sh.sample
  fi
else
  echo -e "\nshell脚本更新失败，请检查原因后再次运行git_pull.sh，或等待定时任务自动再次运行git_pull.sh...\n"
fi

## 克隆或更新js脚本
if [ ${ExitStatusShell} -eq 0 ]; then
  echo -e "--------------------------------------------------------------\n"
  [ -f ${ScriptsDir}/package.json ] && PackageListOld=$(cat ${ScriptsDir}/package.json)
  [ -d ${ScriptsDir}/.git ] && Git_PullScripts || Git_CloneScripts
  #测试自写脚本
  [ -d ${Scripts2Dir}/.git ] && Git_PullScripts2 || Git_CloneScripts2
  cp -f ${Scripts2Dir}/jd_*.js ${ScriptsDir}
fi

## 执行各函数
if [[ ${ExitStatusScripts} -eq 0 ]]; then
  Change_ALL
  [ -d ${ScriptsDir}/node_modules ] && Notify_Version
  Diff_Cron
  Npm_Install
  Output_ListJsAdd
  Output_ListJsDrop
  Del_Cron
  Add_Cron
  ##ExtraShell
  Run_All
  panelinit
  echo -e "活动脚本更新完成......\n"
else
  echo -e "\033[31m活动脚本更新失败，请检查原因或再次运行 git_pull.sh ......\033[0m"
  Change_ALL
fi

## 清除配置缓存
[ -f ${FileConftemp} ] && rm -rf ${FileConftemp}
echo -e "脚本目录：${ShellDir}"
}



































































































































































































## 2.==================================启动脚本函数区==================================

## 导入config.sh
function Import_Conf {
  if [ -f ${FileConf} ]
  then
    . ${FileConf}
    if [ -z "${Cookie1}" ]; then
      echo -e "请先在config.sh中配置好Cookie...\n"
      exit 1
    fi
  else
    echo -e "配置文件 ${FileConf} 不存在，请先按教程配置好该文件...\n"
    exit 1
  fi
}

## 更新crontab
function Detect_Cron {
  if [[ $(cat ${ListCron}) != $(crontab -l) ]]; then
    crontab ${ListCron}
  fi
}

## 用户数量UserSum
function Count_UserSum {
  for ((i=1; i<=1000; i++)); do
    Tmp=Cookie$i
    CookieTmp=${!Tmp}
    [[ ${CookieTmp} ]] && UserSum=$i || break
  done
}


## 组合Cookie和互助码子程序
function Combin_Sub {
  CombinAll=""
  for ((i=1; i<=${UserSum}; i++)); do
    for num in ${TempBlockCookie}; do
      if [[ $i -eq $num ]]; then
        continue 2
      fi
    done
    Tmp1=$1$i
    Tmp2=${!Tmp1}
    case $# in
      1)
        CombinAll="${CombinAll}&${Tmp2}"
        ;;
      2)
        CombinAll="${CombinAll}&${Tmp2}@$2"
        ;;
      3)
        if [ $(($i % 2)) -eq 1 ]; then
          CombinAll="${CombinAll}&${Tmp2}@$2"
        else
          CombinAll="${CombinAll}&${Tmp2}@$3"
        fi
        ;;
      4)
        case $(($i % 3)) in
          1)
            CombinAll="${CombinAll}&${Tmp2}@$2"
            ;;
          2)
            CombinAll="${CombinAll}&${Tmp2}@$3"
            ;;
          0)
            CombinAll="${CombinAll}&${Tmp2}@$4"
            ;;
        esac
        ;;
    esac
  done
  echo ${CombinAll} | perl -pe "{s|^&||; s|^@+||; s|&@|&|g; s|@+|@|g}"
}

## 组合Cookie、Token与互助码
function Combin_All() {
  export JD_COOKIE=$(Combin_Sub Cookie)
  ## 东东农场(jd_fruit.js)
  export FRUITSHARECODES=$(Combin_Sub ForOtherFruit "588e4dd7ba134ad5aa255d9b9e1a38e3@520b92a9f0c34b34a0833f6c3bb41cac@e124f1c465554bf485983257743233d3" "7363f89a9d7248ae91a439794f854614@07b3cd1495524fa2b0f768e7639eab9f")
  ## 东东萌宠(jd_pet.js)
  export PETSHARECODES=$(Combin_Sub ForOtherPet "MTE1NDAxNzgwMDAwMDAwMzk3NDIzODc=@MTAxODEyMjkyMDAwMDAwMDQwMTEzNzA3@MTE1NDUyMjEwMDAwMDAwNDM3NDQzMzU=@MTEzMzI0OTE0NTAwMDAwMDA0Mzc0NjgzOQ==")
  ## 种豆得豆(jd_plantBean.js)
  export PLANT_BEAN_SHARECODES=$(Combin_Sub ForOtherBean "olmijoxgmjutzeajdig5vec453deq25pz7msb7i@okj5ibnh3onz6mkpbt6natnj7xdxeqeg53kjbsi@7oivz2mjbmnx4cbdwoeomdbqrr6bwbgsrhybhxa" "yvppbgio53ya5quolmjz6hiwlhu6yge7i7six5y@ebxm5lgxoknqdfx75eycfx6vy5n2tuflqhuhfia")
  ## 东东工厂(jd_jdfactory.js)
  export DDFACTORY_SHARECODES=$(Combin_Sub ForOtherJdFactory "T0225KkcRhwZp1HXJk70k_8CfQCjVWnYaS5kRrbA@T0205KkcAVhorA6EfG6dwb9ACjVWnYaS5kRrbA@T0205KkcG1tgqh22f1-s54tXCjVWnYaS5kRrbA" "T019__l2QBYe_UneIRj9lv8CjVWnYaS5kRrbA@T0205KkcNFd5nz6dXnCV4r9gCjVWnYaS5kRrbA")
  ## 京喜工厂(jd_dreamFactory.js)
  export DREAM_FACTORY_SHARE_CODES=$(Combin_Sub ForOtherDreamFactory "piDVq-y7O_2SyEzi5ZxxYw==@IzYimRViEUHMiUDFhPPLOg==@ieXM8XzpopOaevcW0f1OwA==@y0k9IDhCNqQvEov0x2ugNQ==")
  ## 京东赚赚(jd_jdzz.js)
  export JDZZ_SHARECODES=$(Combin_Sub ForOtherJdzz "S5KkcRhwZp1HXJk70k_8CfQ@S5KkcAVhorA6EfG6dwb9A@S5KkcG1tgqh22f1-s54tX")
  ## 疯狂的Joy(jd_crazy_joy.js)
  export JDJOY_SHARECODES=$(Combin_Sub ForOtherJoy "N1ihLmXRx9ahdnutDzc1Vqt9zd5YaBeE@o8k-j4vfLXWhsdA5HoPq-w==@zw2aNaUUBen1acOglloXVw==")
  ## 口袋书店(jd_bookshop.js)
  export BOOKSHOP_SHARECODES=$(Combin_Sub ForOtherBookShop)
  ## 签到领现金(jd_cash.js)
  export JD_CASH_SHARECODES=$(Combin_Sub ForOtherCash "eU9Yau6yNPkm9zrVzHsb3w@eU9YLarDP6Z1rRq8njtZ@eU9YN6nLObVHriuNuA9O")
  ## 京喜农场(jd_jxnc.js)
  export JXNC_SHARECODES=$(Combin_Sub ForOtherJxnc)
  ## 闪购盲盒(jd_sgmh.js)
  export JDSGMH_SHARECODES=$(Combin_Sub ForOtherSgmh)
  ## 京喜财富岛(jd_cfd.js)
  export JDCFD_SHARECODES=$(Combin_Sub ForOtherCfd)
  ## 环球挑战赛(jd_global.js)
  export JDGLOBAL_SHARECODES=$(Combin_Sub ForOtherGlobal "MjNtTnVxbXJvMGlWTHc5Sm9kUXZ3VUM4R241aDFjblhybHhTWFYvQmZUOD0")
  ## 城城领现金(jd_city.js)
  export CITY_SHARECODES=$(Combin_Sub ForOtherCity)
}

## 转换JD_BEAN_SIGN_STOP_NOTIFY或JD_BEAN_SIGN_NOTIFY_SIMPLE
function Trans_JD_BEAN_SIGN_NOTIFY() {
  case ${NotifyBeanSign} in
  0)
    export JD_BEAN_SIGN_STOP_NOTIFY="true"
    ;;
  1)
    export JD_BEAN_SIGN_NOTIFY_SIMPLE="true"
    ;;
  esac
}

## 转换UN_SUBSCRIBES
function Trans_UN_SUBSCRIBES {
  export UN_SUBSCRIBES="${goodPageSize}\n${shopPageSize}\n${jdUnsubscribeStopGoods}\n${jdUnsubscribeStopShop}"
}

## 申明全部变量
function Set_Env {
  Count_UserSum
  Combin_All
  Trans_JD_BEAN_SIGN_NOTIFY
  Trans_UN_SUBSCRIBES
}

## 随机延迟
function Random_Delay() {
  if [[ -n ${RandomDelay} ]] && [[ ${RandomDelay} -gt 0 ]]; then
    CurMin=$(date "+%-M")
    if [[ ${CurMin} -gt 2 && ${CurMin} -lt 30 ]] || [[ ${CurMin} -gt 31 && ${CurMin} -lt 59 ]]; then
      CurDelay=$((${RANDOM} % ${RandomDelay} + 1))
      echo -e "\n命令未添加 \"now\"，随机延迟 ${CurDelay} 秒后再执行任务，如需立即终止，请按 CTRL+C...\n"
      sleep ${CurDelay}
    fi
  fi
}

## 使用说明
function Help {
  echo -e "本脚本的用法为："
  echo -e "1. bash ${HelpJd} jd_xxx       # 如果设置了随机延迟并且当时时间不在0-2、30-31、59分内，将随机延迟一定秒数"
  echo -e "2. bash ${HelpJd} jd_xxx now   # 无论是否设置了随机延迟，均立即运行"
  echo -e "3. bash ${HelpJd} hangup    # 重启挂机程序"
  echo -e "4. bash ${HelpJd} panelon   # 开启控制面板"
  echo -e "5. bash ${HelpJd} paneloff  # 关闭控制面板"
  echo -e "5. bash ${HelpJd} panelinfo # 控制面板状态"
  echo -e "5. bash ${HelpJd} panelud # 更新面板(不丢失数据)"
  echo -e "6. bash ${HelpJd} resetpwd   # 重置控制面板用户名和密码"
  echo -e "7. bash ${HelpJd} shellon   # 开启shell面板"
  echo -e "8. bash ${HelpJd} shelloff  # 关闭shell面板"
  echo -e "9. bash ${HelpJd} update  # 更新"
  echo -e "10. bash ${HelpJd} clear  # 清理日记"
  cd ${ScriptsDir}
  for ((i=0; i<${#ListScripts[*]}; i++)); do
    Name=$(grep "new Env" ${ListScripts[i]} | awk -F "'|\"" '{print $2}')
    echo -e "$(($i + 1)).${Name}：${ListScripts[i]}"
  done
}

## nohup
function Run_Nohup {
  for js in ${HangUpJs}
  do
    if [[ $(ps -ef | grep "${js}" | grep -v "grep") != "" ]]; then
      ps -ef | grep "${js}" | grep -v "grep" | awk '{print $2}' | xargs kill -9
    fi
  done

  for js in ${HangUpJs}
  do
    [ ! -d ${LogDir}/${js} ] && mkdir -p ${LogDir}/${js}
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${js}/${LogTime}.log"
    nohup node ${js}.js > ${LogFile} &
  done
}

## pm2
function Run_Pm2 {
  pm2 flush
  for js in ${HangUpJs}
  do
    pm2 restart ${js}.js || pm2 start ${js}.js
  done
}

## 运行挂机脚本
function Run_HangUp {
  Import_Conf && Detect_Cron && Set_Env
  HangUpJs="jd_crazy_joy_coin"
  cd ${ScriptsDir}
  if type pm2 >/dev/null 2>&1; then
    Run_Pm2 2>/dev/null
  else
    Run_Nohup >/dev/null 2>&1
  fi
}

## npm install 子程序，判断是否为安卓，判断是否安装有yarn
function Npm_InstallSub {
  if [ -n "${isTermux}" ]
  then
    npm install --no-bin-links || npm install --no-bin-links --registry=https://registry.npm.taobao.org
  elif ! type yarn >/dev/null 2>&1
  then
    npm install || npm install --registry=https://registry.npm.taobao.org
  else
    echo -e "检测到本机安装了 yarn，使用 yarn 替代 npm...\n"
    yarn install || yarn install --registry=https://registry.npm.taobao.org
  fi
}

## panel install
function panelon {
  [ -f ${PanelDir}/package.json ] && PackageListOld=$(cat ${PanelDir}/package.json)
  cd ${PanelDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到package.json有变化，运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules 后再次尝试一遍..."
      rm -rf ${PanelDir}/node_modules
    fi
    echo
  fi

  if [ ! -d ${PanelDir}/node_modules ]; then
    echo -e "运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${ScriptsDir}/node_modules...\n"
      echo -e "请进入 ${ScriptsDir} 目录后按照wiki教程手动运行 npm install...\n"
      echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务...\n"
      echo -e "3...\n"
      sleep 1
      echo -e "2...\n"
      sleep 1
      echo -e "1...\n"
      sleep 1
      rm -rf ${PanelDir}/node_modules
    fi
  fi
  echo -e "记得开启前先认真看Wiki中，功能页里关于控制面板的事项\n"
  sleep 1
  if [ ! -f "$panelpwd" ]; then
  cp -f ${ShellDir}/sample/auth.json ${ConfigDir}/auth.json
  echo -e "检测到未设置密码，用户名：admin，密码：adminadmin\n"
  fi
  if [ ! -x "$(command -v pm2)" ]; then
      echo "正在安装pm2,方便后续集成并发功能"
      npm install pm2@latest -g
  fi
  cd ${PanelDir}
  pm2 start ecosystem.config.js
  if [ $? -ne 0 ]; then
  echo -e "开启失败，请截图并复制错误代码并提交Issues！\n"
  else
  echo -e "确认看过WIKI，打开浏览器，地址为你的127.0.0.1:5678\n"
  fi
}


## 关闭面板
function paneloff {
  cd ${PanelDir}
  pm2 delete server
  pm2 flush
}

## 面板状态
function panelinfo {
  cd ${PanelDir}
  pm2 status ecosystem.config.js
}

## 面板更新
function panelud {
  pm2 flush
  cd ${PanelDir}
  paneloff
  Npm_InstallSub
  pm2 update
  panelon
}

## webshellon
function shellon {
  [ -f ${WebshellDir}/package.json ] && PackageListOld=$(cat ${WebshellDir}/package.json)
  cd ${WebshellDir}
  if [[ "${PackageListOld}" != "$(cat package.json)" ]]; then
    echo -e "检测到package.json有变化，运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${WebshellDir}/node_modules 后再次尝试一遍..."
      rm -rf ${WebshellDir}/node_modules
    fi
    echo
  fi

  if [ ! -d ${WebshellDir}/node_modules ]; then
    echo -e "运行 npm install...\n"
    Npm_InstallSub
    if [ $? -ne 0 ]; then
      echo -e "\nnpm install 运行不成功，自动删除 ${WebshellDir}/node_modules...\n"
      echo -e "请进入 ${WebshellDir} 目录后按照wiki教程手动运行 npm install...\n"
      echo -e "当 npm install 失败时，如果检测到有新任务或失效任务，只会输出日志，不会自动增加或删除定时任务...\n"
      echo -e "3...\n"
      sleep 1
      echo -e "2...\n"
      sleep 1
      echo -e "1...\n"
      sleep 1
      rm -rf ${WebshellDir}/node_modules
    fi
  fi
  echo -e "记得开启前先认真看Wiki中，功能页里关于Webshell的事项\n"
  cd ${WebshellDir}
  pm2 start ecosystem.config.js
  if [ $? -ne 0 ]; then
  echo -e "开启失败，请截图并复制错误代码并提交Issues！\n"
  else
  echo -e "确认看过WIKI，打开浏览器，地址为   127.0.0.1:9999/ssh/host/127.0.0.1\n"
  fi
}
## webshellon
function shelloff {
  pm2 flush
  cd ${WebshellDir}
  pm2 delete ecosystem.config.js
}

## 重置密码
function Reset_Pwd {
  cp -f ${ShellDir}/sample/auth.json ${ConfigDir}/auth.json
  echo -e "控制面板重置成功，用户名：admin，密码：adminadmin\n"
}

## 运行京东脚本
function Run_Normal {
  Import_Conf && Detect_Cron && Set_Env

  if [ ${AutoHelpme} = true ]; then
    if [ -f ${LogDir}/export_sharecodes/export_sharecodes.log ]; then
      [ ! -s ${FileConftemp} ] && cp -f ${FileConf} ${ConfigDir}/config.sh.temp && cat ${LogDir}/export_sharecodes/export_sharecodes.log >> ${ConfigDir}/config.sh.temp
      FileConf=${ConfigDir}/config.sh.temp
      Import_Conf && Detect_Cron && Set_Env
    else
      echo "暂时没有助力码"
    fi
  else
    echo "0000"
  fi
  
  FileNameTmp1=$(echo $1 | perl -pe "s|\.js||")
  FileNameTmp2=$(echo $1 | perl -pe "{s|jd_||; s|\.js||; s|^|jd_|}")
  SeekDir="${ScriptsDir} ${ScriptsDir}/backUp ${ConfigDir}"
  FileName=""
  WhichDir=""

  for dir in ${SeekDir}
  do
    if [ -f ${dir}/${FileNameTmp1}.js ]; then
      FileName=${FileNameTmp1}
      WhichDir=${dir}
      break
    elif [ -f ${dir}/${FileNameTmp2}.js ]; then
      FileName=${FileNameTmp2}
      WhichDir=${dir}
      break
    fi
  done
  
  if [ -n "${FileName}" ] && [ -n "${WhichDir}" ]
  then
    [ $# -eq 1 ] && Random_Delay
    LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
    LogFile="${LogDir}/${FileName}/${LogTime}.log"
    [ ! -d ${LogDir}/${FileName} ] && mkdir -p ${LogDir}/${FileName}
    cd ${WhichDir}
#    env
    [ ${TasksTerminateTime} = 0 ] &&  node ${FileName}.js | tee ${LogFile}
    [ ${TasksTerminateTime} -ne 0 ] && timeout ${TasksTerminateTime} node ${FileName}.js | tee ${LogFile}
  else
    echo -e "\n在${ScriptsDir}、${ScriptsDir}/backUp、${ConfigDir}三个目录下均未检测到 $1 脚本的存在，请确认...\n"
    Help
  fi
}







































































































## 3.==================================自动互助函数区==================================

## 导出互助码的通用程序
function Cat_Scodes() {
  if [ -d ${LogDir}/jd_$1 ] && [[ $(ls ${LogDir}/jd_$1) != "" ]]; then
    cd ${LogDir}/jd_$1

    ## 导出助力码变量（My）
    for log in $(ls -r); do
      case $# in
      2)
        codes=$(cat ${log} | grep -${Opt} "开始【京东账号|您的(好友)?助力码为" | uniq | perl -0777 -pe "{s|\*||g; s|开始||g; s|\n您的(好友)?助力码为(：)?:?|：|g; s|，.+||g}" | sed -r "s/【京东账号/My$2/;s/】.*?：/='/;s/】.*?/='/;s/$/'/;s/\(每次运行都变化,不影响\)//")
        ;;
      3)
        codes=$(grep -${Opt} $3 ${log} | uniq | sed -r "s/【京东账号/My$2/;s/（.*?】/='/;s/$/'/")
        ;;
      esac
      if [[ ${codes} ]]; then
        ## 添加判断，若未找到该用户互助码，则设置为空值
        for ((user_num = 1; user_num <= ${UserSum}; user_num++)); do
          echo -e "${codes}" | grep -${Opt}q "My$2${user_num}="
          if [ $? -eq 1 ]; then
            if [ $user_num == 1 ]; then
              codes=$(echo "${codes}" | sed -r "1i My${2}1=''")
            else
              codes=$(echo "${codes}" | sed -r "/My$2$(expr ${user_num} - 1)=/a\My$2${user_num}=''")
            fi
          fi
        done
        break
      fi
    done

    ## 导出为他人助力变量（ForOther）
    if [[ ${codes} ]]; then
      help_code=""
      for ((user_num = 1; user_num <= ${UserSum}; user_num++)); do
        echo -e "${codes}" | grep -${Opt}q "My$2${user_num}=''"
        if [ $? -eq 1 ]; then
          help_code=${help_code}"\${My"$2${user_num}"}@"
        fi
      done
      ## 生成互助规则模板
      for_other_codes=""
      case $HelpType in
      0) ### 统一优先级助力模板
        new_code=$(echo ${help_code} | sed "s/@$//")
        for ((user_num = 1; user_num <= ${UserSum}; user_num++)); do
          if [ $user_num == 1 ]; then
            for_other_codes=${for_other_codes}"ForOther"$2${user_num}"=\""${new_code}"\"\n"
          else
            for_other_codes=${for_other_codes}"ForOther"$2${user_num}"=\"\${ForOther"${2}1"}\"\n"
          fi
        done
        ;;
      1) ### 均匀助力模板
        for ((user_num = 1; user_num <= ${UserSum}; user_num++)); do
          echo ${help_code} | grep "\${My"$2${user_num}"}@" >/dev/null
          if [ $? -eq 0 ]; then
            left_str=$(echo ${help_code} | sed "s/\${My$2${user_num}}@/ /g" | awk '{print $1}')
            right_str=$(echo ${help_code} | sed "s/\${My$2${user_num}}@/ /g" | awk '{print $2}')
            mark="\${My$2${user_num}}@"
          else
            left_str=$(echo ${help_code} | sed "s/${mark}/ /g" | awk '{print $1}')${mark}
            right_str=$(echo ${help_code} | sed "s/${mark}/ /g" | awk '{print $2}')
          fi
          new_code=$(echo ${right_str}${left_str} | sed "s/@$//")
          for_other_codes=${for_other_codes}"ForOther"$2${user_num}"=\""${new_code}"\"\n"
        done
        ;;
      *) ### 普通优先级助力模板
        for ((user_num = 1; user_num <= ${UserSum}; user_num++)); do
          new_code=$(echo ${help_code} | sed "s/\${My"$2${user_num}"}@//;s/@$//")
          for_other_codes=${for_other_codes}"ForOther"$2${user_num}"=\""${new_code}"\"\n"
        done
        ;;
      esac
      echo -e "${codes}\n\n${for_other_codes}" | sed s/[[:space:]]//g
    else
      echo ${Tips}
    fi
  else
    echo "## 未运行过 jd_$1 脚本，未产生日志"
  fi
}

## 汇总
function Cat_All() {
  echo -e "\n# 从最后一个日志提取互助码，受日志内容影响，仅供参考。"
  echo -e "\n# 用法： 检查无误后，将以下内容直接复制到config.sh的最后面专区中！！！"
  echo -e "\n################################" 
  for ((i = 0; i < ${#Name1[*]}; i++)); do
    echo -e "\n# ${Name2[i]}："
    [[ $(Cat_Scodes "${Name1[i]}" "${Name3[i]}" "的${Name2[i]}好友互助码") == ${Tips} ]] && Cat_Scodes "${Name1[i]}" "${Name3[i]}" || Cat_Scodes "${Name1[i]}" "${Name3[i]}" "的${Name2[i]}好友互助码"
 done
}

function OutPutHelpCode() {
## 执行并写入日志
#LogTime=$(date "+%Y-%m-%d-%H-%M-%S")
#LogFile="${LogDir}/export_sharecodes/${LogTime}.log"
LogFile="${LogDir}/export_sharecodes/export_sharecodes.log"
[ ! -d "${LogDir}/export_sharecodes" ] && mkdir -p ${LogDir}/export_sharecodes
Import_Conf && Count_UserSum && Cat_All | perl -pe "{s|京东种豆|种豆|; s|crazyJoy任务|疯狂的JOY|}" | tee ${LogFile}
}































































































## 4.==================================清理日记函数区==================================

## 删除运行js脚本的旧日志
function Rm_JsLog {
  LogFileList=$(ls -l ${LogDir}/*/*.log | awk '{print $9}')
  for log in ${LogFileList}
  do
    LogDate=$(echo ${log} | awk -F "/" '{print $NF}' | cut -c1-10)   #文件名比文件属性获得的日期要可靠
    if [[ $(uname -s) == Darwin ]]
    then
      DiffTime=$(($(date +%s) - $(date -j -f "%Y-%m-%d" "${LogDate}" +%s)))
    else
      DiffTime=$(($(date +%s) - $(date +%s -d "${LogDate}")))
    fi
    [ ${DiffTime} -gt $((${RmLogDaysAgo} * 86400)) ] && rm -vf ${log}
  done
}

## 删除git_pull.sh的运行日志
function Rm_GitPullLog {
  if [[ $(uname -s) == Darwin ]]
  then
    DateDelLog=$(date -v-${RmLogDaysAgo}d "+%Y-%m-%d")
  else
    Stmp=$(($(date "+%s") - 86400 * ${RmLogDaysAgo}))
    DateDelLog=$(date -d "@${Stmp}" "+%Y-%m-%d")
  fi
  LineEndGitPull=$[$(cat ${LogDir}/git_pull.log | grep -n "${DateDelLog} " | head -1 | awk -F ":" '{print $1}') - 3]
  [ ${LineEndGitPull} -gt 0 ] && perl -i -ne "{print unless 1 .. ${LineEndGitPull} }" ${LogDir}/git_pull.log
}

## 删除空文件夹
function Rm_EmptyDir {
  cd ${LogDir}
  for dir in $(ls)
  do
    if [ -d ${dir} ] && [[ $(ls ${dir}) == "" ]]; then
      rm -rf ${dir}
    fi
  done
}

## 运行
function RemoveExbiredLog {
if [ -n "${RmLogDaysAgo}" ]; then
  Rm_JsLog
  Rm_GitPullLog
  Rm_EmptyDir
fi
}


















































## 5.==================================命令接受函数区==================================
## 命令检测
case $# in
  0)
    echo
    Help
    ;;
  1)
    if [[ $1 == hangup ]]; then
      Run_HangUp
    elif [[ $1 == resetpwd ]]; then
      Reset_Pwd
    elif [[ $1 == panelon ]]; then
      panelon
    elif [[ $1 == paneloff ]]; then
      paneloff
    elif [[ $1 == panelinfo ]]; then
      panelinfo
    elif [[ $1 == panelud ]]; then
      panelud
    elif [[ $1 == shellon ]]; then
      shellon
    elif [[ $1 == shelloff ]]; then
      shelloff
    elif [[ $1 == update ]]; then
      UpdateFuntionall
    elif [[ $1 == help ]]; then
      OutPutHelpCode
    elif [[ $1 == clear ]]; then
      RemoveExbiredLog
    else
      Run_Normal $1
    fi
    ;;
  2)
    if [[ $2 == now ]]; then
      Run_Normal $1 $2
    else
      echo -e "\n命令输入错误...\n"
      Help
    fi
    ;;
  *)
    echo -e "\n命令过多...\n"
    Help
    ;;
esac


