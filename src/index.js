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

// Change the URL upon request, inform app of the change.
app.ports.modifyUrl.subscribe(function(url) {
    history.replaceState({}, '', url);
    // app.ports.onUrlChange.send(location.href);
});

app.ports.playPause.subscribe(function(time) {
    const player = document.getElementById('player');
    if (player.paused) {
      player.play();
    } else {
      player.pause();
    }
});

// console.log(elmSeed);
