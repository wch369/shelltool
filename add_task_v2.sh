#!/bin/bash
# 此脚本是对自动任务配置文件添加自动任务项
# 要添加的项在文件里，这里是ss.txt
set -e

if [ $# != 2 ]
then
    echo "用法：$0 源文件 目的文件"
    echo "e.g: $0 ~/update/20201205/task_ncrd.xml ~/etc/BUSI/NCRD/TaskTab.xml"
    exit 1
fi

source_file=$1
dest_file=$2
dest_file_name=${dest_file##*/}

if [ "${dest_file_name}" != "TaskTab.xml" ]
then 
    echo "目标文件不是自动任务配置文件（TaskTab.xml):${dest_file_name}"
    exit 1
fi

for i in `grep TaskLogic ${source_file} | sort -u | awk -F'"' '{print $2}'`
do
    result=`grep $i ${dest_file}`
    if [ -n "${result}" ]
    then
        echo "目标文件已存在自动任务[${i}]"
        exit 1
    fi
done

work_dir=${dest_file%/TaskTab.xml}
cd ${work_dir}
echo `pwd`

bak_file="TaskTab.xml.`date +'%F_%T'`"
echo ${bak_file}
cp TaskTab.xml ${bak_file}
if [ ! -f ${bak_file} ] 
then
    echo "备份失败, 请检查文件路径是否正确！"
    exit 1
fi

#翻转源文件
tac ${source_file} > src.temp

#从翻转后插入</TaskTab>后面，再次翻转为</TaskTab>前面
tac ${dest_file_name} | sed '/<\/TaskTab>/r src.temp' | tac > ${dest_file_name}.temp

mv ${dest_file_name}.temp ${dest_file_name}

# 统计总个数并替换
curr_rec=`grep "Task TaskCol" ${dest_file_name}  | wc -l`
sed -i -e "s/\(<TaskTab RecNum=\"\)\([0-9]\{1,\}\)/\1${curr_rec}/" ${dest_file_name} 

rm -f src.temp
rm -f ${dest_file_name}.temp
