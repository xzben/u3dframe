# u3dframe
学习交流群 qq 743905788

基于tolua 实现的一套 框架，业务结构使用 MVP 设计
此框架内置功能
1、热更新的实现，以及热更新打包流程相关工具实现
2、资源管理方案实现
3、业务 MVP 结构设计
4、内置 ugui 没有的 虚拟列表，网格虚拟列表，PageView，动态元素虚拟列表 等常规好用的基础组件
5、内置网络模块，和pbc 的protobuf 协议封装

使用mvp 的设计结构，游戏核心为数据驱动，而非界面驱动的方式
M 层包含两个部分
1、 service 这个是负责和服务器通信，并持有业务所有的数据model属性，按业务模块实现的单例实现，统一由 service_manager 管理。
2、model 数据，主要是将复杂的业务数据模型，封装成类，方便维护时能清晰看到每个业务数据模块的属性信息和接口信息

V 层就是编辑器中编辑的 prefab 组件/界面
view层对象的基类为 ui_base/view_base, 分别对应界面的组件或者界面基类，他是由 presenter 对象持有并管理的。在各种业务情况下，可能会持有presenter但是释放view,然后在合适的时候再根据presenter 恢复 view 

P 层是业务的骨架，整个游戏的运行通过内置的管理器驱动 各个业务模块的presenter数据然后显示界面驱动游戏逻辑的运行，p层只负责界面逻辑的处理，比如数据从哪里来，怎么变化数据到界面上，然后view层只做数据如何显示相关的处理。这样后期界面不一样的类似逻辑可以由一个precenter 驱动不同的view来实现。