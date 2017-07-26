(function() {
  domready(function () {
    document.querySelectorAll('.menu-button, .nav-cover, .nav-close').forEach(function(element) {
      element.addEventListener('click', function(event) {
        event.preventDefault();

        var body_classes = document.body.className.split(' ');
        ["nav-opened", "nav-closed"].forEach(function(klass){
          var i = body_classes.indexOf(klass);
          i >= 0 ? body_classes.splice(i, 1) : body_classes.push(klass);
        });
        document.body.className = body_classes.join(' ');
      });
    });
  });

  // slightly adapted from http://stackoverflow.com/a/26798337/421705
  window.requestAnimFrame = (function(){
    return  window.requestAnimationFrame       ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame    ||
            function( callback ){
              window.setTimeout(callback, 1000 / 60);
            };
  })();

  function scrollToY(scrollTargetY, speed, easing) {
    // scrollTargetY: the target scrollY property of the window
    // speed: time in pixels per second
    // easing: easing equation to use

    // Don't scroll slowly if the user requested reduced motion
    if (matchMedia('(prefers-reduced-motion)').matches) {
      window.scrollTo(0, scrollTargetY);
      return;
    }

    var scrollY = window.scrollY,
        scrollTargetY = scrollTargetY || 0,
        speed = speed || 2000,
        easing = easing || 'easeOutSine',
        currentTime = 0;

    // min time .1, max time .8 seconds
    var time = Math.max(.1, Math.min(Math.abs(scrollY - scrollTargetY) / speed, .8));

    // easing equations from https://github.com/danro/easing-js/blob/master/easing.js
    var PI_D2 = Math.PI / 2,
        easingEquations = {
          easeOutSine: function (pos) {
            return Math.sin(pos * (Math.PI / 2));
          },
          easeInOutSine: function (pos) {
            return (-0.5 * (Math.cos(Math.PI * pos) - 1));
          },
          easeInOutQuint: function (pos) {
            if ((pos /= 0.5) < 1) {
              return 0.5 * Math.pow(pos, 5);
            }
            return 0.5 * (Math.pow((pos - 2), 5) + 2);
          },
          easeOutQuint: function(pos) {
            return (Math.pow((pos-1), 5) +1);
          },
        };

    // add animation loop
    function tick() {
      currentTime += 1 / 60;

      var p = currentTime / time;
      var t = easingEquations[easing](p);

      if (p < 1) {
        requestAnimFrame(tick);
        window.scrollTo(0, scrollY + ((scrollTargetY - scrollY) * t));
      } else {
        window.scrollTo(0, scrollTargetY);
      }
    }

    // call it once to get started
    tick();
  }

  domready(function () {
    document.querySelectorAll('.scroll-down').forEach(function(element) {
      element.addEventListener('click', function(event) {
        event.preventDefault();

        var speed = 500,
            offset = this.getAttribute('data-offset') ? this.getAttribute('data-offset') : false,
            position = this.getAttribute('data-position') ? this.getAttribute('data-position') : false,
            toMove;

        var elementBottom = this.getBoundingClientRect().bottom + window.pageYOffset - (document.clientTop || 0);

        if (offset) {
          toMove = parseInt(offset);
          scrollToY(elementBottom + toMove, speed, 'easeOutQuint')
        } else if (position) {
          toMove = parseInt(position);
          scrollToY(toMove, speed, 'easeOutQuint')
        } else {
          scrollToY(elementBottom, speed, 'easeOutQuint')
        }
      });
    });
  });
})();
