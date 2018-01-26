function loadURL(url) {
    var iFrame;
    iFrame = document.createElement("iframe");
    iFrame.setAttribute("src", url);
    iFrame.setAttribute("style", "display:none;");
    iFrame.setAttribute("height", "0px");
    iFrame.setAttribute("width", "0px");
    iFrame.setAttribute("frameborder", "0");
    document.body.appendChild(iFrame);
    iFrame.parentNode.removeChild(iFrame);
    iFrame = null;
};

function exec(funName, args) {
    var commend = {
        functionName : funName,
        arguments : args
    };
    var jsonStr = JSON.stringify(commend);
    var url = "qdstatistics:" + jsonStr;
    loadURL(url);
};

window.QDStatistics = {
    
    /**
     * 自定义事件
     * 
     * @param eventId String类型 事件ID
     * @param eventData Map<String,String>类型 当前事件的属性集合，最多支持10个K-V值
     */
    onEvent : function(eventId, eventData) {
        exec("onEvent", [ eventId, eventData ]);
    },
    
    /**
     * 页面统计开始时调用
     * 
     * @param pageId String类型 页面id
     * @param eventData Map<String,String>类型 当前页面的属性集合，最多支持10个K-V值
     */
    onPageStart : function(pageId, eventData) {
        exec("onPageStart", [ pageId, eventData ]);
    },

    /**
     * 页面统计结束时调用
     * 
     * @param pageId String类型 页面id
     */
    onPageEnd : function(pageId) {
        exec("onPageEnd", [ pageId ]);
    },

    /**
     * 统计帐号登录接口 *
     * 
     * @param UID 用户账号ID,长度小于64字节
     */
    onUserSignIn : function(UID) {
        exec("onUserSignIn", [ UID ]);
    },
    
    /**
     * 帐号统计退出接口
     */
    onUserSignOff : function() {
        exec("onUserSignOff", []);
    }
};

var readyEvent = document.createEvent('Events');
    readyEvent.initEvent('QDStatisticsReady');
    document.dispatchEvent(readyEvent);
