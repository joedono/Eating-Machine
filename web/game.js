
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
Module['FS_createPath']('/', 'prey', true, true);
Module['FS_createPath']('/', 'state', true, true);

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
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 3397, "filename": "/conf.lua"}, {"audio": 0, "start": 3397, "crunched": 0, "end": 4850, "filename": "/main.lua"}, {"audio": 0, "start": 4850, "crunched": 0, "end": 357074, "filename": "/asset/font/Arial-Bold.ttf"}, {"audio": 0, "start": 357074, "crunched": 0, "end": 455266, "filename": "/asset/font/RifficFree-Bold.ttf"}, {"audio": 0, "start": 455266, "crunched": 0, "end": 459718, "filename": "/asset/image/beach.png"}, {"audio": 0, "start": 459718, "crunched": 0, "end": 459961, "filename": "/asset/image/bird.png"}, {"audio": 0, "start": 459961, "crunched": 0, "end": 471563, "filename": "/asset/image/ocean.png"}, {"audio": 0, "start": 471563, "crunched": 0, "end": 472949, "filename": "/asset/image/player.png"}, {"audio": 0, "start": 472949, "crunched": 0, "end": 473200, "filename": "/asset/image/effect/corpse-blood.png"}, {"audio": 0, "start": 473200, "crunched": 0, "end": 473998, "filename": "/asset/image/hunter/gun_fire.png"}, {"audio": 0, "start": 473998, "crunched": 0, "end": 476185, "filename": "/asset/image/hunter/ship_big_gun.png"}, {"audio": 0, "start": 476185, "crunched": 0, "end": 487381, "filename": "/asset/image/hunter/ship_small_body.png"}, {"audio": 0, "start": 487381, "crunched": 0, "end": 566296, "filename": "/asset/image/hunter/water_ripple.png"}, {"audio": 0, "start": 566296, "crunched": 0, "end": 566750, "filename": "/asset/image/prey/swimmer.png"}, {"audio": 0, "start": 566750, "crunched": 0, "end": 573833, "filename": "/asset/image/screen/title.png"}, {"audio": 0, "start": 573833, "crunched": 0, "end": 589376, "filename": "/asset/image/splash/hive.png"}, {"audio": 1, "start": 589376, "crunched": 0, "end": 632532, "filename": "/asset/sound/beach.wav"}, {"audio": 1, "start": 632532, "crunched": 0, "end": 644934, "filename": "/asset/sound/gunshot.wav"}, {"audio": 1, "start": 644934, "crunched": 0, "end": 763250, "filename": "/asset/sound/shark-bite.wav"}, {"audio": 0, "start": 763250, "crunched": 0, "end": 763983, "filename": "/config/collisions.lua"}, {"audio": 0, "start": 763983, "crunched": 0, "end": 765035, "filename": "/config/constants.lua"}, {"audio": 0, "start": 765035, "crunched": 0, "end": 772693, "filename": "/hunter/hunter.lua"}, {"audio": 0, "start": 772693, "crunched": 0, "end": 776093, "filename": "/hunter/manager-hunter.lua"}, {"audio": 0, "start": 776093, "crunched": 0, "end": 780002, "filename": "/hunter/player.lua"}, {"audio": 0, "start": 780002, "crunched": 0, "end": 785293, "filename": "/hunter/shark.lua"}, {"audio": 0, "start": 785293, "crunched": 0, "end": 794087, "filename": "/lib/anim8.lua"}, {"audio": 0, "start": 794087, "crunched": 0, "end": 815546, "filename": "/lib/bump.lua"}, {"audio": 0, "start": 815546, "crunched": 0, "end": 819663, "filename": "/lib/general.lua"}, {"audio": 0, "start": 819663, "crunched": 0, "end": 829753, "filename": "/lib/inspect.lua"}, {"audio": 0, "start": 829753, "crunched": 0, "end": 835820, "filename": "/lib/hump/camera.lua"}, {"audio": 0, "start": 835820, "crunched": 0, "end": 838886, "filename": "/lib/hump/class.lua"}, {"audio": 0, "start": 838886, "crunched": 0, "end": 842419, "filename": "/lib/hump/gamestate.lua"}, {"audio": 0, "start": 842419, "crunched": 0, "end": 845081, "filename": "/lib/hump/signal.lua"}, {"audio": 0, "start": 845081, "crunched": 0, "end": 851614, "filename": "/lib/hump/timer.lua"}, {"audio": 0, "start": 851614, "crunched": 0, "end": 855798, "filename": "/lib/hump/vector-light.lua"}, {"audio": 0, "start": 855798, "crunched": 0, "end": 861776, "filename": "/lib/hump/vector.lua"}, {"audio": 0, "start": 861776, "crunched": 0, "end": 864951, "filename": "/lib/o-ten-one/baby.png"}, {"audio": 0, "start": 864951, "crunched": 0, "end": 891367, "filename": "/lib/o-ten-one/handy-andy.otf"}, {"audio": 0, "start": 891367, "crunched": 0, "end": 895207, "filename": "/lib/o-ten-one/heart.png"}, {"audio": 0, "start": 895207, "crunched": 0, "end": 907256, "filename": "/lib/o-ten-one/init.lua"}, {"audio": 0, "start": 907256, "crunched": 0, "end": 928338, "filename": "/lib/o-ten-one/logo-mask.png"}, {"audio": 0, "start": 928338, "crunched": 0, "end": 935927, "filename": "/lib/o-ten-one/logo.png"}, {"audio": 0, "start": 935927, "crunched": 0, "end": 942479, "filename": "/lib/o-ten-one/timer.lua"}, {"audio": 0, "start": 942479, "crunched": 0, "end": 943752, "filename": "/prey/corpse.lua"}, {"audio": 0, "start": 943752, "crunched": 0, "end": 946817, "filename": "/prey/manager-prey.lua"}, {"audio": 0, "start": 946817, "crunched": 0, "end": 950623, "filename": "/prey/swimmer.lua"}, {"audio": 0, "start": 950623, "crunched": 0, "end": 958090, "filename": "/state/state-game.lua"}, {"audio": 0, "start": 958090, "crunched": 0, "end": 958751, "filename": "/state/state-losing.lua"}, {"audio": 0, "start": 958751, "crunched": 0, "end": 960284, "filename": "/state/state-lost.lua"}, {"audio": 0, "start": 960284, "crunched": 0, "end": 961118, "filename": "/state/state-pause.lua"}, {"audio": 0, "start": 961118, "crunched": 0, "end": 963721, "filename": "/state/state-splash-hive.lua"}, {"audio": 0, "start": 963721, "crunched": 0, "end": 964478, "filename": "/state/state-splash-love.lua"}, {"audio": 0, "start": 964478, "crunched": 0, "end": 968085, "filename": "/state/state-title.lua"}], "remote_package_size": 968085, "package_uuid": "5ee6f362-5281-4117-a024-7dcef10d805f"});

})();
