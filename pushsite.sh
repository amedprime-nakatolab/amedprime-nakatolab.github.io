#!/bin/sh
# 阪大医学部python会のHP管理ページでのHTMLに出力するためのpushsite.sh

comment="$1"
sourcebranch=${2:-master}
targetbranch=${3:-master}
makecommand=`which gmake`
makecommand=${makecommand:-`which make`}
previewdir="preview"
outputdir="output"
cd $outputdir &&\
git pull origin $targetbranch &&\ # リモートリポジトリの変更を取り込む.
git checkout -f $targetbranch &&\ #masterブランチに切り替える
cd ../ &&\
if [ "$sourcebranch" = "master" ]; then
    if [ -d "./$outputdir/$previewdir" ]; then # ./output/previewが存在する時
        rm -rf $previewdir && mv "./$outputdir/$previewdir" ./
        #previewを削除して./output/previewを./に移動する
    else
        mkdir $previewdir
        #./output/previewがない時、./にpreviewを作っちゃう
    fi &&\
    $makecommand clean &&\ #make中に正常に作られる全てのファイルを削除するgmake cleanがどこにあるか（which）
    mv $previewdir output/ &&\ #previewをoutput以下に移動
    $makecommand publish #よくわかんない
else
    git fetch #リモートリポジトリの内容を確認したいだけの時
    if [ `git branch -a | sed 's/^[ \t]*//' | grep "^remotes/origin/$sourcebranch$"` ]; then
      #リモートブランチを含んだブランチの一覧を表示する。|
      #^[ \t]*つまり、行の始めがtabを削除する|
      #remotes/origin/masterというブランチがある時、
        git branch -D $sourcebranch
        #マージの状態に関わらず、masterブランチを削除する。
        $makecommand clean "OUTPUTDIR=./$outputdir/$previewdir/$sourcebranch" &&\
        #which gmake clean
        {
            echo
            echo "SITEURL += '/$previewdir/$sourcebranch'"
            echo "if 'PREVIEW_SITENAME_APPEND' in globals():"
            echo "    SITENAME += PREVIEW_SITENAME_APPEND"
            echo "    SITETAG += PREVIEW_SITENAME_APPEND"
            echo
        }  >> ./content/contentconf.py &&\
        #/content/contentconf.pyに上の行を追加する
        $makecommand html "OUTPUTDIR=./$outputdir/$previewdir/$sourcebranch"
        #which gmake html
    else # branch deleted
        rm -rf "./$outputdir/$previewdir/$sourcebranch"
    fi
fi &&\
cd $outputdir &&\
git add . &&\
git commit -m "${comment:-Update}" &&\
git push origin $targetbranch
