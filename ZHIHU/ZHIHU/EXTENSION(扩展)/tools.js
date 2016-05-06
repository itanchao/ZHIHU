
var getimageSrc = function (prefixStr){
    var objs = document.getElementsByTagName("img");
    var imageList = [];
    for(var i=0;i<objs.length;i++)
    {
        objs[i].onclick=function()
        {
            alert(this.src);
            document.location= prefixStr+this.src;
        };
        imageList.push(objs[i].src);
    };
    document.location= "imagelist:"+imageList;
    return imageList;
//    return objs.length;
};
