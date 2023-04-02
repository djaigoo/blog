cmd=$1
if [ "$cmd" == "" ];then
  cmd=merge
fi

git add middleware-mysql*
git commit -m 'update'

base_file=middleware/mysql/mysql讲义.md
if [ "$cmd" == "init" ];then
  title=$(cat ${base_file} |grep -E '^## |^# ' |sed -e 's/#/00/g' -e 's/ /-/g')
  for t in ${title};do
    line=$(echo $title|sed -e 's/ /\n/g' | sed -n -e "/${t}$/=")
    new=middleware-mysql-${line}-${t}
    old=$(ls |grep $t.md)
    if [ "${old}" == "" ];then
      echo $new
      hexo new $new
    else
      if [ "$old" == "$new.md" ];then
        echo $old not change
        continue
      fi
      echo mv "$old ---> $new.md"
      mv $old $new.md
    fi
  done
fi

if [ "$cmd" == "merge" ];then
  file=middleware-mysql.md
  echo --- > ${file}
  for f in $(ls |grep middleware-mysql- | sort -n -t '-' -k 3);do
    echo $f | awk -F '-00' '{print $2}' | sed -e 's/^/#/' -e 's/00/#/g' -e 's/#-/# /' -e 's/.md$//' >> ${file}
    sed -n -e 's/^#/###/g' -e '9,$p' $f >> ${file} 
  done
fi
