(function() {
  function decodeHTMLEntities(str) {
    if(str && typeof str === 'string') {
      var e = document.createElement('div');
      e.innerHTML = str;
      str = e.innerHTML;
      e.remove();
    }
    return str;
  }
  function encodeHTMLEntities(str) {
    var buf = [];
    for (var i=str.length-1;i>=0;i--) {
      buf.unshift(['&#', str[i].charCodeAt(), ';'].join(''));
    }
    return buf.join('');
  };

  (function() {
    var elements = document.getElementsByClassName("hidden-email");
    Array.prototype.forEach.call(elements, function(element){
      var encoded = element.getAttribute("data-email");
      var plain_encoded = decodeHTMLEntities(encoded)
      var plain_decoded = plain_encoded.replace(/[!-~]/g,function(c){
        return String.fromCharCode(126>=(c=c.charCodeAt(0)+47)?c:c-94);
      });
      var decoded = encodeHTMLEntities(plain_decoded);

      var link = "<" + "a h" + "ref=\"mai" + "lto:" + decoded + "\">" + decoded + "</" + "a>";
      element.innerHTML = link;
    });
  })();
})();
