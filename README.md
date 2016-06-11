## 简介
利用Ruby编写爬虫，自动登陆我们学校的教务系统，获取成绩页面，得到成绩数据，并格式化输出，自动计算绩点等。

具体原理可参考[我的博客](http://www.jasonsi.com/2016/03/29/3/)

Tesseract相关配置可参考[RTesseract使用文档](https://github.com/dannnylo/rtesseract)

## 使用方式
1. 安装Tesseract-ocr

  ```bash
  sudo apt-get install tesseract-ocr
  sudo apt-get install ImageMagick
  ```
2. 安装必需gem

  ```bash
  sudo gem install rtesseract mini_magick mechanize nokogiri mail
  ```
3. 配置Tesseract的环境(可能不需要)

  ```bash
  #从Google官网下载
  wget https://tesseract-ocr.googlecode.com/files/eng.traineddata.gz
  #下载完成后，移动到相应文件夹，可选择/usr或者/opt
  sudo mv -v eng.traineddata /usr/local/share/tessdata/
  #sudo mv -v eng.traineddata /opt/local/share/tessdata/
  ```
4. 在`public`目录下新建`account.yml`和`email.yml`文件，内容格式如下

  ```yaml
  -
    - 100000000002  # 学号
    - 010001  # 密码
    - xx@xxx.com  # 邮箱
  -
    - 100000000002
    - 100002
    - xx@xxx.com, yy@yyy.com # 可以用逗号隔开多个邮箱

  ```
  ```yaml
  smtp_server: smtp.xx.com
  account: xx@xxx.com
  password: xxxxxxxx
  ```
5. 运行`index.rb`

  ```bash
  ruby index.rb -w
  ```


## TODO
- 从`指导性教学计划`页面获取成绩，可避免得到类似“优秀”、“中等”的成绩，以获取确切分数  `OK`
- 分析表格，将每学期的成绩分离，以便更友好的输出以及更多的计算功能  `OK`
- 按考试日期分学期应该有容错，保证在一个学期内就可以，不必相等  `OK`
- 运行后十分钟查询一次成绩，与上一次结果对比，并写入yml文件，如果有新增则发邮件通知  `OK`
- 尝试编写一键评估功能
