
function getimageSrc(prefixStr){
    var objs = document.getElementsByTagName("img");
    alert(prefixStr);
    for(var i=0;i<objs.length;i++)
    {
        objs[i].onclick=function()
        {
            document.location= prefixStr+this.src;
        };
    };
    return objs.length;
};
