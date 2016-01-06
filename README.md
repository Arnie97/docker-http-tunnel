### English
Chinese cloud computing startup [DaoCloud](https://daocloud.io) provides a hosting platform for docker containers.
They also provide a free community plan, which includes two containers.

However, you're only able to expose one HTTP port for each container, which limits the usage to web applications.

This `Dockerfile` starts a HTTP tunnel with [chisel](https://github.com/jpillora/chisel), so that you can easily access any open TCP ports in the container.

Take SSH as an example.
First deploy this repo on your DaoCloud console and start an instance.
Then forward remote port 22 to local port 2222 on your local machine:

    $ chisel client http://username-foobar.daoapp.io 2222:localhost:22
    $ ssh -p 2222 localhost

Hooray, now we've SSHed into the container.

Visit [chisel's home page](https://github.com/jpillora/chisel) on Github for detailed instructions.
Happy hacking!

### Chinese
[DaoCloud](https://daocloud.io)是我朝一家托管docker容器的云平台。
免费的社区版提供了两个单位的计算资源~~还送了我好多红包~~，简直良心。
可惜免费版只能绑定一个HTTP端口，限制了我折腾的空间。

为了解决这一问题，用[chisel](https://github.com/jpillora/chisel)建立一个HTTP隧道，之后就可以愉快的玩耍了～

以建立SSH连接为例。
先Fork我的仓库，在DaoCloud上[创建并启动一个新项目](https://dashboard.daocloud.io/build-flows/new)。
然后在本地运行：

    $ chisel client http://username-foobar.daoapp.io 2222:localhost:22
    $ ssh -p 2222 localhost

如果一切顺利，你已经通过转发到本地`2222`端口的SSH登入容器啦。

欲知具体的工作原理，请移步[chisel的首页](https://github.com/jpillora/chisel)。
开源大法好！
