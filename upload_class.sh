#!/bin/bash 
# 上传最新编译的class文件到服务器上
# 支持选择服务器环境，选择上传的文件个数。
#
read -p "请输入要上传的环境: 
    1-SIT
    2-UAT
你的选择是：" tag

remote_user=""
remote_ip=""
remote_passwd="" 
remote_dir_pre=""

local_dir=""

case ${tag} in
    "1")
        #echo "sit"
        #TODO 替换具体值
        remote_ip=""
        remote_user=""
        remote_passwd="" 
        local_dir=""
        remote_dir_pre=""
        ;;
    "2")
        #echo "uat"
        remote_ip=""
        remote_user=""
        remote_passwd="" 
        local_dir=""
        remote_dir_pre=""
        ;;
    *)
        echo "未输入或输入非法，默认为sit"
        # tag设置过值后，无论是否为空都把+后面的内容替换给tag变量
        # tag=${tag+1}
        ip=""
        user=""
        ;;
esac
echo 上传地址为："${remote_user}"@"${remote_ip}"
read -p "请输入文件上传个数: " count
cd ${local_dir}
echo 当前目录："`pwd`"
#找到最新的修改的class文件
file_list=`find . -type f -printf "%T@ %p\n"  | grep "\<class\>" | sort -n | tail -"${count}" | cut -f2 -d ' '`
for f in $file_list
do
    remote_dis_suf=${f%/*.class}
    echo ${local_dir}${f}-${remote_user}-${remote_ip}-${remote_passwd}-"${remote_dir_pre}"/"${remote_dis_suf}"/
    /usr/bin/expect ~/bin/exp_files/scp.exp ${local_dir}${f} ${remote_user} ${remote_ip} ${remote_passwd} "${remote_dir_pre}"/"${remote_dis_suf}"/
done

echo "上传完毕，开始重启服务器..."
#/usr/bin/expect ~/bin/exp_files/restart.exp bin/restart.sh ${remote_ip} ${remote_user} ${remote_passwd}
