import glob
import pandas as pd
import re
import os
import pytablewriter

category = ["date","Speaker","Title","Article"]
date = []
Speaker = []
Title = []
Article = []

files = glob.glob("./content/Seminar/*")
for file in files:
    dirname, basename = os.path.split(file)
    filename, ext = os.path.splitext(basename)
    with open(file) as f:
        md = f.read()
        date.append(re.findall('<dd class="date">(.*)</dd>', md)[0])
        Speaker.append(re.findall('<dd class="Speaker">(.*)</dd>', md)[0])
        Title.append(re.findall('<dd class="Title">(.*)</dd>', md)[0])
        Article.append('<a href="https://amedprime-nakatolab.github.io/Seminar/'+filename+'.html">詳細')
df = pd.DataFrame({"Date" : date,
                "Speaker": Speaker,
                "Title":Title,
                "Article":Article})


df['Speaker'] = df['Speaker'].str.replace('先生', '')
df['Speaker'] = df['Speaker'].str.replace('（', '<br>（')
writer = pytablewriter.MarkdownTableWriter()
writer.from_dataframe(df)
print(df)
tags = "Title: セミナー一覧\nDate: 2020-12-15 22:00\nCategory: セミナー一覧\nTags: セミナー一覧\nTemplate: page_before\n\n"

with open("./content/pages/output.md", mode='w') as f:
    f.write(tags)
    writer.stream = f
    writer.write_table()
