#!/bin/bash
# 此脚本是对自动任务配置文件添加自动任务项
# 要添加的项在文件里，这里是ss.txt

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

#这里添加一个空行，防止格式缩进乱掉
insert_cont='   \
'
declare -i add_num=`grep "</Task>" ${source_file}  | wc -l`
declare -i temp_num=1
while IFS=  read -r line
do
    if [ -z "${line##*<\/Task>*}" ] 
    then 
        if [ ${temp_num} -lt ${add_num} ]
        then 
            temp_num+=1
            insert_cont="${insert_cont}${line}\\
"
        else
        insert_cont="${insert_cont}${line}"
        fi
    else
        insert_cont="${insert_cont}${line}\\
"
    fi
done < ${source_file}
echo -e "${insert_cont}"

# 追加内容
sed -i -e '/<\/TaskTab>/i\
    '"${insert_cont}" ${dest_file_name}

# 统计总个数并替换
curr_rec=`grep "Task TaskCol" ${dest_file_name}  | wc -l`
sed -i -e "s/\(<TaskTab RecNum=\"\)\([0-9]\{1,\}\)/\1${curr_rec}/" ${dest_file_name} 

# 去掉空行
sed -i -e '3,${
    /^ *$/d
}' ${dest_file_name}

