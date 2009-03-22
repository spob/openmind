// Thanks for doing your part to liber(IE)t the world from IE6!
// Original copy written by Jonathan Howard (jon@StaringIsPolite.com)
//
// GNU LGPL License v3
// SevenUp is released into the wild under a GNU LGPL v3
//
// Browser sniffing technique lovingly adapted from http://www.thefutureoftheweb.com/
// Simple CSS Lightbox technique adapted equally lovingly from http://www.emanueleferonato.com/
// Go read their blogs :)

// Constructor technique advocated by Doug Crockford (of LSlint, JSON) in his recent Google tech talk.
var sevenUp = function () {
  // Define private vars here.
	var downloadLink = "http://www.google.com/toolbar/ie7/";
	var needUpgrade = /(MSIE 6|MSIE 5.(\d+))/i.test(navigator.userAgent); // is IE6??
	var overlayColor  = "#000000";  // Change these to fit your color scheme.
	var lightboxColor = "#ffffff";  // " "
	var borderColor   = "#6699ff";  // " "
  // Hate to define CSS this way, but trying to keep to one file.
  // I'll keep it as pretty as possible.
  var overlayCSS =
    "display: block; position: absolute; top: 0%; left: 0%;" +
    "width: 100%; height: 100%; background-color: " + overlayColor + "; " +
    "z-index:1001; -moz-opacity: 0.8; opacity:.80; filter: alpha(opacity=80);";
  var lightboxCSS = 
    "display: block; position: absolute; top: 25%; left: 25%; width: 50%; " +
    "height: 50%; padding: 16px; border: 8px solid " + borderColor + "; " +
    "background-color:" + lightboxColor + "; " +
    "z-index:1002; overflow: auto;";
  var lightboxContents =
    "<div style='width: 100%; height: 95%'>" +
      "<h2>Your web browser is outdated and unsupported</h2>" +
      "<div style='text-align: center;'>" +
        "You can easily upgrade to the latest version by clicking " +
        "<a style='color: #0000EE' href='" + downloadLink + "'>here</a>" +
      "</div>" +
      "<h3 style='margin-top: 40px'>Why should I upgrade?</h3>" +
      "<ul><li><b>Websites load faster</b>, often double the speed of this older version</li>" +
      "<li><b>Websites look better</b> with more web standards compliance</li>" +
      "<li><b>Tabs</b> let you view multiple sites in one window</li>" +
      "<li><b>Safer browsing</b> with phishing protection</li>" +
      "<li><b>Convenient Printing</b> with fit-to-page capability</li>" +
      "</ul>" +
    "</div>" +
    "<div style='font-size: 11px; text-align: right;'>" +
      "<a href='#' onclick='sevenUp.quitBuggingMe();'" +
          "style='color: #0000EE'>" +
        "Quit bugging me" +
      "</a>" +
    "</div>";
  function isCookieSet() {
    if (document.cookie.length > 0) {
      var i = document.cookie.indexOf("sevenup=");
      return (i != -1);
    }
    return false;
  }
  
  return {  // Return object literal and public methods here.
  	test: function(allowSkip) {
  	  if (needUpgrade && !isCookieSet()) {
  	    // Write layer into the document.
  	    var layerHTML =
  	      "<div id='sevenUpOverlay' style='" + overlayCSS + "'>" +
  	        "<div style='" + lightboxCSS + "'>" +
              lightboxContents +
            "</div>" +
  		    "</div>";
        var layer = document.createElement('div');
        layer.innerHTML = layerHTML;
  	    document.body.appendChild(layer);
  	  }  
  	},
    setLightboxContents: function(newContents) {
      lightboxContents = newContents;
    },
    quitBuggingMe: function() {
      var exp = new Date();
      exp.setTime(exp.getTime()+(7*24*3600000));
      document.cookie = "sevenup=dontbugme; expires="+exp.toUTCString();
      this.close();
    },
    close: function() {
      var overlay = document.getElementById('sevenUpOverlay');
      if (overlay !== undefined) {
        overlay.style.display = 'none';
      }
    }
  };
}();

