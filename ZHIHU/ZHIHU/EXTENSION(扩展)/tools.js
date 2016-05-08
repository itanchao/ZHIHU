
/// 获取图片路径
var getimageSrc = function (prefixStr){
    var objs = document.getElementsByTagName("img");
    var imageList = [];
    for(var i=0;i<objs.length;i++)
    {
        /**
         *  @author 谈超, 16-05-06 17:05:11
         *
         *  遍历每一个图片元素，添加点击事件
         */
        objs[i].onclick=function()
        {
//            alert(this.src);
//            var rect = this.getBoundingClientRect();
//            alert(rect.top + '|' + rect.left + '|' + rect.right + '|' + rect.height);
            document.location= prefixStr+this.src;
        };
        imageList.push(objs[i].src);
    };
    /**
     *  @author 谈超, 16-05-06 17:05:19
     *
     *  第一次加载获取所有图片路径
     */
    document.location= "imagelist:"+imageList;
    return imageList;
};

