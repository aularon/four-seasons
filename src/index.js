'use strict';
require('./style.less')
// const data = require('./data/')
const page = require('./index.html');
const Elm = require('./Main.elm');
const main = document.getElementById('main')
main.innerHTML = ''
// const elmSeed = {
//   title: 'Four Seasons!!!',
//   movements: data.Movements.map( (m, i) => ({
//     start: m.abs_start_audio,
//     hue: m.hue,
//     label: m.label,
//     length: (data.Movements[i + 1]? data.Movements[i + 1].abs_start_audio : 42 * 60) - m.abs_start_audio
//   }))
// }


var app = Elm.Elm.FourSeasonsApp.init({
  flags: {
    now: Date.now()
  }
});

// const app = Elm.Elm.FourSeasonsApp.init({
//   flags
// });

app.ports.setCurrentTime.subscribe(function(time) {
    document.getElementById('player').currentTime = time;
});

// app.ports.modifyUrl.subscribe(function(url) {
//     history.replaceState({}, '', url);
// });

app.ports.externalAction.subscribe(function(action) {
  // console.log(action)
    const player = document.getElementById('player');
    if (action === 'play') {
      player.play();
    } else if (action === 'pause') {
      player.pause();
    } else if (action === 'share') {
      try {
        navigator.share({
          title: document.title,
          text: 'Text goes here...',
          url: document.location.href,
        }); // share the URL of MDN
      } catch (e) {
        console.log(e)
      }
    }
});

// console.log(elmSeed);
// g analytics
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());

gtag('config', 'UA-47316095-2');
