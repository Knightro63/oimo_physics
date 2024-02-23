'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "0d02abe329e862f1a2c4251d7077a1ee",
"index.html": "c53532373d3d578f866d9d0b26264cf1",
"/": "c53532373d3d578f866d9d0b26264cf1",
"main.dart.js": "750754ef89506822674a32a714782efb",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "d19dc292e879202587dd9faf5e858f96",
"assets/AssetManifest.json": "7efe2a4db084b8cf5ce669ba67479d53",
"assets/NOTICES": "cf516741669a6b48072f1d89c9936c82",
"assets/FontManifest.json": "f3afd2757415f61715dda260dd00a89c",
"assets/AssetManifest.bin.json": "50b49663b4759630fc53f9e0cc16d407",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/css/fonts/Klavika-Bold.otf": "3bf3d0ea7c93d0af167a55ec998f1109",
"assets/packages/css/fonts/MuseoSans-300.otf": "bdb59b808cfc4fb88f3963fa06e6c79b",
"assets/packages/css/fonts/MyFlutterApp.ttf": "de3dadbecb06a7a21503a5506673ce55",
"assets/packages/css/fonts/MuseoSans_500.otf": "62c0135163427c652ae397f327f85010",
"assets/packages/css/fonts/Klavika-Regular.otf": "a4291ca7070683edf50d92990e5a2a70",
"assets/packages/css/fonts/MuseoSans_700.otf": "10aaa353d22c131091d217c83f558343",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "a2a41a617a314aa73b2f1db02ba29aa4",
"assets/fonts/MaterialIcons-Regular.otf": "a3f0577d0595557e94ec39e44395aa8b",
"assets/assets/images/sunflower.jpg": "fc0580595d2f982e48a2b5d5fec0baab",
"assets/assets/images/container.png": "7ac1e6e5939b71ce14b7665b07c9551a",
"assets/assets/images/body_types.png": "a96fe4ac98fbe20b223b916d1fbf05b1",
"assets/assets/images/stacks.png": "01b79045b20100422a479dabb9dfe3a3",
"assets/assets/images/shapes.png": "dbb22828bebfa205e43c3efe750d4f12",
"assets/assets/images/hinge.png": "7b7338523375c579aab0c8bb02b489a1",
"assets/assets/images/threejs_voxel_fps.png": "0767b6f671d7162488b9e9f41b1c34c3",
"assets/assets/images/basic_physics.png": "35718874c94c5eb6fb199233a6c56e4d",
"assets/assets/images/split_solver.png": "44f9e4a0f94b358c7da03f21073ab42d",
"assets/assets/images/convex.png": "7de21496e7ddaf6595fb6b63066423ce",
"assets/assets/images/simple_friction.png": "e2a5a5ec775e9644735a7284b5482c33",
"assets/assets/images/trimesh.png": "bc6718707115e76f4bda870feb509846",
"assets/assets/images/sleep.png": "c9b3692279087224b96bb0b678a33a52",
"assets/assets/images/fps.png": "43fc75399eb8ff9003a1302350a883f3",
"assets/assets/images/jenga.png": "94e703e2c6cf33ff44439986e0c6dcf9",
"assets/assets/images/bounce.png": "adce9217e56b379f80be07efae38d53f",
"assets/assets/images/rigid_vehicle.png": "0023e090891b3bc839b97da7ad28ca08",
"assets/assets/images/games_fps.png": "3610907d461103d415b6afd2963df66f",
"assets/assets/images/raycast_vehicle.png": "a4d53b51e5c683fbbdf369c81789ad50",
"assets/assets/images/bunny.png": "cc2072c77514af95564168ff981fe3b3",
"assets/assets/images/friction.png": "e2a5a5ec775e9644735a7284b5482c33",
"assets/assets/images/sph.png": "e657ce53ad59fc8f4d8761299bd9a691",
"assets/assets/images/collision_filter.png": "d82b9081aa3c044343b30f4bf1fa4e59",
"assets/assets/images/constraints.png": "f882473ecf75e02346f27d35463cdf0c",
"assets/assets/images/friction_gravity.png": "e2a5a5ec775e9644735a7284b5482c33",
"assets/assets/images/single_body_on_plane.png": "9d42bae8983912ccaa39df13b958b45e",
"assets/assets/images/events.png": "af71ba950e3d4b5e70b3238027c6cff5",
"assets/assets/images/cloth.png": "889dc87381c6a4c4d81f0e883d19982c",
"assets/assets/images/boxes.png": "a69ac92f545919d1ac8dc112f36eb9f5",
"assets/assets/images/trigger.png": "db7e31f574dbc9ce8d4e2d3b2a3af779",
"assets/assets/images/pile.png": "34b322b383c49a48db3a5eb617eafebe",
"assets/assets/images/spring.png": "9acb7c1e838aec6eb1ebe56ffb6cd71a",
"assets/assets/images/callbacks.png": "7ea44e68325aa1a8723714ebeaeb6a90",
"assets/assets/images/collisions.png": "a2dcfb8d068eb309c5bbedf3165d71c4",
"assets/assets/images/examples.png": "c1fc7e4a850e456279d2bc2503d6c594",
"assets/assets/images/ragdoll.png": "8f4b21097774d9dc0a9bc29aa5e9b477",
"assets/assets/images/fixed_rotation.png": "b4887afccd95b50b1271c1a5d349861c",
"assets/assets/images/worker.png": "2a64ec42941f4a41a9f58a00506da887",
"assets/assets/images/canvas_interpolation.png": "1f1111d842540325f1c388d760ef918b",
"assets/assets/images/worker_sharedarraybuffer.png": "5e633776eecb137eec0c446c3b5696ab",
"assets/assets/images/docs.png": "aa96e24b7dc9b08831536c94ba2d3271",
"assets/assets/images/impulses.png": "3345e27678c2205668130a5a18eb2a55",
"assets/assets/images/tween.png": "d38218c263e3cc1a74e06b35b07e9781",
"assets/assets/images/heightfield.png": "fccba9a92f649bef5b08c1a549abe497",
"assets/assets/images/tear.png": "c3a29bcc4e6962243934ef5800814785",
"assets/assets/images/performance.png": "22736cd5f9294f15143df80722db8a3c",
"assets/assets/images/threejs.png": "335dbc1e38a4775a2281742640b9e67c",
"assets/assets/images/compound.png": "fb2ab67de65bbd5f02b6f474c32465fe",
"assets/assets/images/threejs_mousepick.png": "0a3cacc1d32b37623abca7cef4aee671",
"assets/assets/models/collision-world.glb": "2a1fe984a72270ec18c91e1b20ef2c33",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
