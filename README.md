# frontpage

1. 如何使用？

我的当前配置：Nodejs v0.12.0+，npm v2.7.3，less v2.4.0，grunt-cli v0.1.13，grunt v0.4.5，coffeescript v1.8.0

a.运行npm install 会自动安装node_modules所有需要的依赖包

b.运行grunt会根据Gruntfile.coffee自动创建build目录，产生src的构建文件

c.选择一个域名作为开发时的资源文件域名，例如项目名称叫myproject，那么可以选择static.myproject.com作为域名，并修改本机hosts文件，把域名映射到本地127.0.0.1

d.配置静态文件服务器，例如nginx或者apache，映射static.myproject.com主机的请求到src目录下，例如Nginx
    server {
        listen       80;
        server_name  static.myproject.com;
        location ~ .*\.(js|css|png|jpg|gif)$ {
            gzip on;
            root D:/code/assets/src;
        }
    }
    这里说明一下，为什么要采用域名映射这么麻烦呢，因为你在本地开发的项目不止一个，每个项目都有自己的静态文件，你在本地Nginx也不只是为静态文件而服务，所以static.myproject.com其实就是告诉Nginx我要请求哪个项目的静态文件，不然如果你只有一个项目，Nginx也只是为静态文件服务的话，你也可以直接请求http://localhost/xxx。

e.这时候，如果页面请求http://static.myproject.com/css/app/index.css，使用的文件则是本地的D:/code/assets/src/css/app/index.css，开发时运行grunt watch，当开发修改D:/code/assets/src/css/app/index.less，less任务将会重新编译生成新的D:/code/assets/src/css/app/index.css文件，这里我暂时采用手动刷新浏览器，有兴趣的同学可以配置自动刷新浏览器页面的工具。

f.由于项目上线的时候需要使用构建后的资源文件，按常理来说，需要修改请求的静态文件路径为build之后的文件，为了避免每个页面都需要修改引用的所有资源文件，这里采用了配置文件的方法，把dev开发环境和pro生产环境需要使用的不同的资源文件做了一个配置，放在resource文件夹中，命名跟页面名称保持一致，如果页面分了命名空间的，资源配置文件也分命名空间。所以下一步是修改页面的配置文件为相应的资源路径，html或者php页面就不需要显式引用资源文件，由使用的后台语言根据当前环境进行模板渲染，这个比较简单，这里就不细说了，留给后端处理。

g.走到这一步，开发环境应该是没问题了，上线时，确保线上引用的资源文件映射到build目录下的文件，这样子应该就问题不大了，还有几个todo的问题，先记下来：

1）js，css文件可以统一引用，但图片资源文件可能在css中出现，也可能img标签中出现，很难使用配置，如何不修改代码可以实现环境切换呢？
答：图片资源只是做了个压缩，甚至UI设计师已经做好了压缩，那就直接复制img目录到build目录下即可，开发环境js、css资源文件的路径采用staticdev.myproject.com域名，映射到src目录，img资源文件域名采用static.myproject.com（线上cdn域名），映射到build目录，生产环境js、css资源文件路径也统一采用static.myproject.com域名即可。

2）未使用过cdn，还未知道怎样配置，迟些有空买个阿里云的cdn实践一下。

3）资源更新问题，和缓存问题，本地开发环境不存在这个问题，但线上使用cdn的话，如何更新资源文件？

答：现在框架已经增加了文件的md5指纹文件生成，后台自动根据资源映射文件来更换相应的md5资源文件
4）资源文件更新以后，代码部署和资源文件的部署流程又是怎样？
答：先部署静态文件，因为增加了md5指纹，所以旧文件不会被覆盖，旧的HTML依然能正常运行，然后再部署HTML代码，改变引用，灰度部署！注意的是，build目录为了保持旧文件不会被覆盖，务必把clean目录注释掉！同时尽量减少整体grunt的次数，因为每一次构建都会产生一次新版本的文件，只要你的代码更改过。