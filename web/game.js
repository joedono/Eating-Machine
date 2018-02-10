
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

    var PACKAGE_PATH;
    if (typeof window === 'object') {
      PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
                              Module['locateFile'](REMOTE_PACKAGE_BASE) :
                              ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);
  
    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;
  
    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
          var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onload = function(event) {
        var packageData = xhr.response;
        callback(packageData);
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };
  
      var fetched = null, fetchedCallback = null;
      fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, function(data) {
        if (fetchedCallback) {
          fetchedCallback(data);
          fetchedCallback = null;
        } else {
          fetched = data;
        }
      }, handleError);
    
  function runWithFS() {

    function assert(check, msg) {
      if (!check) throw msg + new Error().stack;
    }
Module['FS_createPath']('/', 'asset', true, true);
Module['FS_createPath']('/asset', 'font', true, true);
Module['FS_createPath']('/asset', 'image', true, true);
Module['FS_createPath']('/asset/image', 'effect', true, true);
Module['FS_createPath']('/asset/image', 'hunter', true, true);
Module['FS_createPath']('/asset/image', 'prey', true, true);
Module['FS_createPath']('/asset/image', 'screen', true, true);
Module['FS_createPath']('/asset/image', 'splash', true, true);
Module['FS_createPath']('/asset', 'sound', true, true);
Module['FS_createPath']('/', 'config', true, true);
Module['FS_createPath']('/', 'hunter', true, true);
Module['FS_createPath']('/', 'lib', true, true);
Module['FS_createPath']('/lib', 'hump', true, true);
Module['FS_createPath']('/lib', 'o-ten-one', true, true);
Module['FS_createPath']('/', 'notes', true, true);
Module['FS_createPath']('/', 'prey', true, true);
Module['FS_createPath']('/', 'state', true, true);
Module['FS_createPath']('/', 'web', true, true);
Module['FS_createPath']('/', 'wip', true, true);
Module['FS_createPath']('/wip', 'image', true, true);

    function DataRequest(start, end, crunched, audio) {
      this.start = start;
      this.end = end;
      this.crunched = crunched;
      this.audio = audio;
    }
    DataRequest.prototype = {
      requests: {},
      open: function(mode, name) {
        this.name = name;
        this.requests[name] = this;
        Module['addRunDependency']('fp ' + this.name);
      },
      send: function() {},
      onload: function() {
        var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

      },
      finish: function(byteArray) {
        var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      },
    };

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
        }

  
    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;
      
        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);
  
          var files = metadata.files;
          for (i = 0; i < files.length; ++i) {
            DataRequest.prototype.requests[files[i].filename].onload();
          }
              Module['removeRunDependency']('datafile_game.data');

    };
    Module['addRunDependency']('datafile_game.data');
  
    if (!Module.preloadResults) Module.preloadResults = {};
  
      Module.preloadResults[PACKAGE_NAME] = {fromCache: false};
      if (fetched) {
        processPackageData(fetched);
        fetched = null;
      } else {
        fetchedCallback = processPackageData;
      }
    
  }
  if (Module['calledRun']) {
    runWithFS();
  } else {
    if (!Module['preRun']) Module['preRun'] = [];
    Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
  }

 }
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 3397, "filename": "/conf.lua"}, {"audio": 0, "start": 3397, "crunched": 0, "end": 4850, "filename": "/main.lua"}, {"audio": 0, "start": 4850, "crunched": 0, "end": 4940, "filename": "/README.md"}, {"audio": 0, "start": 4940, "crunched": 0, "end": 4949, "filename": "/RUNME.bat"}, {"audio": 0, "start": 4949, "crunched": 0, "end": 357173, "filename": "/asset/font/Arial-Bold.ttf"}, {"audio": 0, "start": 357173, "crunched": 0, "end": 455365, "filename": "/asset/font/RifficFree-Bold.ttf"}, {"audio": 0, "start": 455365, "crunched": 0, "end": 459817, "filename": "/asset/image/beach.png"}, {"audio": 0, "start": 459817, "crunched": 0, "end": 460060, "filename": "/asset/image/bird.png"}, {"audio": 0, "start": 460060, "crunched": 0, "end": 471662, "filename": "/asset/image/ocean.png"}, {"audio": 0, "start": 471662, "crunched": 0, "end": 473048, "filename": "/asset/image/player.png"}, {"audio": 0, "start": 473048, "crunched": 0, "end": 473299, "filename": "/asset/image/effect/corpse-blood.png"}, {"audio": 0, "start": 473299, "crunched": 0, "end": 474097, "filename": "/asset/image/hunter/gun_fire.png"}, {"audio": 0, "start": 474097, "crunched": 0, "end": 476284, "filename": "/asset/image/hunter/ship_big_gun.png"}, {"audio": 0, "start": 476284, "crunched": 0, "end": 487480, "filename": "/asset/image/hunter/ship_small_body.png"}, {"audio": 0, "start": 487480, "crunched": 0, "end": 566395, "filename": "/asset/image/hunter/water_ripple.png"}, {"audio": 0, "start": 566395, "crunched": 0, "end": 566849, "filename": "/asset/image/prey/swimmer.png"}, {"audio": 0, "start": 566849, "crunched": 0, "end": 573932, "filename": "/asset/image/screen/title.png"}, {"audio": 0, "start": 573932, "crunched": 0, "end": 589475, "filename": "/asset/image/splash/hive.png"}, {"audio": 1, "start": 589475, "crunched": 0, "end": 632631, "filename": "/asset/sound/beach.wav"}, {"audio": 1, "start": 632631, "crunched": 0, "end": 645033, "filename": "/asset/sound/gunshot.wav"}, {"audio": 1, "start": 645033, "crunched": 0, "end": 763349, "filename": "/asset/sound/shark-bite.wav"}, {"audio": 0, "start": 763349, "crunched": 0, "end": 764082, "filename": "/config/collisions.lua"}, {"audio": 0, "start": 764082, "crunched": 0, "end": 765134, "filename": "/config/constants.lua"}, {"audio": 0, "start": 765134, "crunched": 0, "end": 772792, "filename": "/hunter/hunter.lua"}, {"audio": 0, "start": 772792, "crunched": 0, "end": 776192, "filename": "/hunter/manager-hunter.lua"}, {"audio": 0, "start": 776192, "crunched": 0, "end": 780101, "filename": "/hunter/player.lua"}, {"audio": 0, "start": 780101, "crunched": 0, "end": 785392, "filename": "/hunter/shark.lua"}, {"audio": 0, "start": 785392, "crunched": 0, "end": 794186, "filename": "/lib/anim8.lua"}, {"audio": 0, "start": 794186, "crunched": 0, "end": 815645, "filename": "/lib/bump.lua"}, {"audio": 0, "start": 815645, "crunched": 0, "end": 819762, "filename": "/lib/general.lua"}, {"audio": 0, "start": 819762, "crunched": 0, "end": 829852, "filename": "/lib/inspect.lua"}, {"audio": 0, "start": 829852, "crunched": 0, "end": 835919, "filename": "/lib/hump/camera.lua"}, {"audio": 0, "start": 835919, "crunched": 0, "end": 838985, "filename": "/lib/hump/class.lua"}, {"audio": 0, "start": 838985, "crunched": 0, "end": 842518, "filename": "/lib/hump/gamestate.lua"}, {"audio": 0, "start": 842518, "crunched": 0, "end": 845180, "filename": "/lib/hump/signal.lua"}, {"audio": 0, "start": 845180, "crunched": 0, "end": 851713, "filename": "/lib/hump/timer.lua"}, {"audio": 0, "start": 851713, "crunched": 0, "end": 855897, "filename": "/lib/hump/vector-light.lua"}, {"audio": 0, "start": 855897, "crunched": 0, "end": 861875, "filename": "/lib/hump/vector.lua"}, {"audio": 0, "start": 861875, "crunched": 0, "end": 865050, "filename": "/lib/o-ten-one/baby.png"}, {"audio": 0, "start": 865050, "crunched": 0, "end": 891466, "filename": "/lib/o-ten-one/handy-andy.otf"}, {"audio": 0, "start": 891466, "crunched": 0, "end": 895306, "filename": "/lib/o-ten-one/heart.png"}, {"audio": 0, "start": 895306, "crunched": 0, "end": 907355, "filename": "/lib/o-ten-one/init.lua"}, {"audio": 0, "start": 907355, "crunched": 0, "end": 928437, "filename": "/lib/o-ten-one/logo-mask.png"}, {"audio": 0, "start": 928437, "crunched": 0, "end": 936026, "filename": "/lib/o-ten-one/logo.png"}, {"audio": 0, "start": 936026, "crunched": 0, "end": 942578, "filename": "/lib/o-ten-one/timer.lua"}, {"audio": 0, "start": 942578, "crunched": 0, "end": 942819, "filename": "/notes/credits.md"}, {"audio": 0, "start": 942819, "crunched": 0, "end": 944345, "filename": "/notes/notes.md"}, {"audio": 0, "start": 944345, "crunched": 0, "end": 945618, "filename": "/prey/corpse.lua"}, {"audio": 0, "start": 945618, "crunched": 0, "end": 948683, "filename": "/prey/manager-prey.lua"}, {"audio": 0, "start": 948683, "crunched": 0, "end": 952489, "filename": "/prey/swimmer.lua"}, {"audio": 0, "start": 952489, "crunched": 0, "end": 959995, "filename": "/state/state-game.lua"}, {"audio": 0, "start": 959995, "crunched": 0, "end": 960656, "filename": "/state/state-losing.lua"}, {"audio": 0, "start": 960656, "crunched": 0, "end": 962189, "filename": "/state/state-lost.lua"}, {"audio": 0, "start": 962189, "crunched": 0, "end": 963023, "filename": "/state/state-pause.lua"}, {"audio": 0, "start": 963023, "crunched": 0, "end": 965626, "filename": "/state/state-splash-hive.lua"}, {"audio": 0, "start": 965626, "crunched": 0, "end": 966383, "filename": "/state/state-splash-love.lua"}, {"audio": 0, "start": 966383, "crunched": 0, "end": 969990, "filename": "/state/state-title.lua"}, {"audio": 0, "start": 969990, "crunched": 0, "end": 1938075, "filename": "/web/game.data"}, {"audio": 0, "start": 1938075, "crunched": 0, "end": 1951036, "filename": "/web/game.js"}, {"audio": 0, "start": 1951036, "crunched": 0, "end": 1954862, "filename": "/web/index.html"}, {"audio": 0, "start": 1954862, "crunched": 0, "end": 8608904, "filename": "/web/love.js"}, {"audio": 0, "start": 8608904, "crunched": 0, "end": 9229922, "filename": "/web/love.js.mem"}, {"audio": 0, "start": 9229922, "crunched": 0, "end": 10139955, "filename": "/wip/image/background.xcf"}, {"audio": 0, "start": 10139955, "crunched": 0, "end": 10170359, "filename": "/wip/image/Basis.png"}, {"audio": 0, "start": 10170359, "crunched": 0, "end": 10190435, "filename": "/wip/image/Basis.tmx"}, {"audio": 0, "start": 10190435, "crunched": 0, "end": 10190625, "filename": "/wip/image/Basis.tsx"}, {"audio": 0, "start": 10190625, "crunched": 0, "end": 10193155, "filename": "/wip/image/bird.xcf"}, {"audio": 0, "start": 10193155, "crunched": 0, "end": 10194266, "filename": "/wip/image/corpse-blood.xcf"}, {"audio": 0, "start": 10194266, "crunched": 0, "end": 10199318, "filename": "/wip/image/player.xcf"}, {"audio": 0, "start": 10199318, "crunched": 0, "end": 10202656, "filename": "/wip/image/swimmer.xcf"}, {"audio": 0, "start": 10202656, "crunched": 0, "end": 10216924, "filename": "/wip/image/title.xcf"}, {"audio": 0, "start": 10216924, "crunched": 0, "end": 10241186, "filename": "/wip/image/water_ripple_small_001.png"}, {"audio": 0, "start": 10241186, "crunched": 0, "end": 10265800, "filename": "/wip/image/water_ripple_small_002.png"}, {"audio": 0, "start": 10265800, "crunched": 0, "end": 10290269, "filename": "/wip/image/water_ripple_small_003.png"}, {"audio": 0, "start": 10290269, "crunched": 0, "end": 10314427, "filename": "/wip/image/water_ripple_small_004.png"}], "remote_package_size": 10314427, "package_uuid": "7dec5b23-ded3-4b32-b17d-b52d4fb26286"});

})();
