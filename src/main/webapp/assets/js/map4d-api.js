(function (global) {
    'use strict';

    function getApiKey() {
        if (global.MAP4D_API_KEY && String(global.MAP4D_API_KEY).trim()) {
            return String(global.MAP4D_API_KEY).trim();
        }
        var saved = '';
        try {
            saved = global.localStorage ? global.localStorage.getItem('MAP4D_API_KEY') : '';
        } catch (e) {
            saved = '';
        }
        return saved ? String(saved).trim() : '';
    }

    function getTileTemplate() {
        if (global.MAP4D_TILE_URL_TEMPLATE && String(global.MAP4D_TILE_URL_TEMPLATE).trim()) {
            return String(global.MAP4D_TILE_URL_TEMPLATE).trim();
        }
        var saved = '';
        try {
            saved = global.localStorage ? global.localStorage.getItem('MAP4D_TILE_URL_TEMPLATE') : '';
        } catch (e) {
            saved = '';
        }
        return saved ? String(saved).trim() : '';
    }

    function buildUrl(path, params) {
        var key = getApiKey();
        if (!key) {
            throw new Error('missing-map4d-key');
        }
        var query = new URLSearchParams(params || {});
        query.set('key', key);
        return 'https://api.map4d.vn/' + path + '?' + query.toString();
    }

    async function request(path, params) {
        var url = buildUrl(path, params);
        var response = await fetch(url, { headers: { 'Accept': 'application/json' } });
        if (!response.ok) {
            throw new Error('map4d-http-' + response.status);
        }
        return response.json();
    }

    function addBaseTileLayer(map, options) {
        if (!map || !global.L || typeof global.L.tileLayer !== 'function') {
            return null;
        }

        var opts = options || {};
        var fallbackAttr = opts.fallbackAttribution || '&copy; OpenStreetMap contributors';
        var fallbackMaxZoom = Number(opts.fallbackMaxZoom || 19);

        function addFallbackLayer() {
            return global.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: fallbackAttr,
                maxZoom: fallbackMaxZoom
            }).addTo(map);
        }

        var template = getTileTemplate();
        if (!template) {
            return addFallbackLayer();
        }

        var key = getApiKey();
        var tileUrl = template;
        if (key) {
            tileUrl = tileUrl.replace('{key}', encodeURIComponent(key));
        }

        var layer = global.L.tileLayer(tileUrl, {
            attribution: opts.attribution || '&copy; Map4D',
            maxZoom: Number(opts.maxZoom || 20)
        }).addTo(map);

        var switched = false;
        layer.on('tileerror', function () {
            if (switched) {
                return;
            }
            switched = true;
            map.removeLayer(layer);
            addFallbackLayer();
        });

        return layer;
    }

    function toArray(value) {
        return Array.isArray(value) ? value : [];
    }

    function pickFirstArray(data) {
        var keys = ['result', 'results', 'data', 'items', 'predictions', 'routes', 'paths'];
        for (var i = 0; i < keys.length; i += 1) {
            if (Array.isArray(data && data[keys[i]])) {
                return data[keys[i]];
            }
        }
        if (Array.isArray(data)) {
            return data;
        }
        return [];
    }

    function toLatLngPair(first, second) {
        var a = Number(first);
        var b = Number(second);
        if (Number.isNaN(a) || Number.isNaN(b)) {
            return null;
        }

        // If the first value looks like longitude and second looks like latitude, swap.
        if (Math.abs(a) > 90 && Math.abs(a) <= 180 && Math.abs(b) <= 90) {
            return [b, a];
        }
        // If second value cannot be latitude, treat pair as [lng, lat].
        if (Math.abs(b) > 90 && Math.abs(a) <= 90) {
            return [a, b];
        }
        // Ambiguous cases default to [lat, lng].
        return [a, b];
    }

    function normalizeCoordinateList(list) {
        if (!Array.isArray(list)) {
            return [];
        }
        return list.map(function (coord) {
            if (Array.isArray(coord) && coord.length >= 2) {
                return toLatLngPair(coord[0], coord[1]);
            }
            var ll = extractLatLng(coord);
            return ll ? [ll.lat, ll.lng] : null;
        }).filter(Boolean);
    }

    function extractLatLng(item) {
        if (!item || typeof item !== 'object') {
            return null;
        }

        var candidates = [
            [item.lat, item.lng],
            [item.latitude, item.longitude],
            [item.lat, item.lon],
            [item.location && item.location.lat, item.location && (item.location.lng || item.location.lon)],
            [item.geometry && item.geometry.location && item.geometry.location.lat, item.geometry && item.geometry.location && (item.geometry.location.lng || item.geometry.location.lon)]
        ];

        for (var i = 0; i < candidates.length; i += 1) {
            var lat = Number(candidates[i][0]);
            var lng = Number(candidates[i][1]);
            if (!Number.isNaN(lat) && !Number.isNaN(lng)) {
                return { lat: lat, lng: lng };
            }
        }
        return null;
    }

    function normalizeAddressResult(item) {
        var ll = extractLatLng(item);
        if (!ll) {
            return null;
        }
        return {
            lat: ll.lat,
            lng: ll.lng,
            display_name: item.formattedAddress || item.display_name || item.address || item.name || '',
            raw: item
        };
    }

    async function geocode(keyword, limit) {
        var payload = await request('sdk/v2/geocode', {
            address: keyword
        });
        var raw = pickFirstArray(payload);
        var arr = raw.slice(0, Number(limit || 5)).map(normalizeAddressResult).filter(Boolean);
        return toArray(arr);
    }

    async function reverse(lat, lng) {
        var payload = await request('sdk/v2/geocode', {
            location: lat + ',' + lng
        });

        var first = pickFirstArray(payload)[0];
        if (first) {
            return first.address || first.formattedAddress || first.name || '';
        }
        return '';
    }

    function decodePolyline(encoded) {
        if (!encoded || typeof encoded !== 'string') {
            return [];
        }
        var points = [];
        var index = 0;
        var lat = 0;
        var lng = 0;

        while (index < encoded.length) {
            var b;
            var shift = 0;
            var result = 0;
            do {
                b = encoded.charCodeAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20 && index < encoded.length);
            var dlat = (result & 1) ? ~(result >> 1) : (result >> 1);
            lat += dlat;

            shift = 0;
            result = 0;
            do {
                b = encoded.charCodeAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20 && index < encoded.length);
            var dlng = (result & 1) ? ~(result >> 1) : (result >> 1);
            lng += dlng;

            points.push([lat / 1e5, lng / 1e5]);
        }
        return points;
    }

    function normalizeRoute(routeObj) {
        if (!routeObj || typeof routeObj !== 'object') {
            return null;
        }

        // Some payloads wrap route candidates under routes[]/paths[].
        if (Array.isArray(routeObj.routes) && routeObj.routes.length > 0) {
            return normalizeRoute(routeObj.routes[0]);
        }
        if (Array.isArray(routeObj.paths) && routeObj.paths.length > 0) {
            return normalizeRoute(routeObj.paths[0]);
        }

        var distance = Number(routeObj.distance || routeObj.length || routeObj.totalDistance || 0);
        var duration = Number(routeObj.duration || routeObj.time || routeObj.totalDuration || 0);
        var coordinates = [];

        if (Array.isArray(routeObj.coordinates)) {
            coordinates = normalizeCoordinateList(routeObj.coordinates);
        } else if (routeObj.geometry && Array.isArray(routeObj.geometry.coordinates)) {
            coordinates = normalizeCoordinateList(routeObj.geometry.coordinates);
        } else if (Array.isArray(routeObj.path)) {
            coordinates = normalizeCoordinateList(routeObj.path);
        } else if (Array.isArray(routeObj.points)) {
            coordinates = routeObj.points.map(function (point) {
                var ll = extractLatLng(point);
                return ll ? [ll.lat, ll.lng] : null;
            }).filter(Boolean);
        } else if (typeof routeObj.polyline === 'string') {
            coordinates = decodePolyline(routeObj.polyline);
        } else if (typeof routeObj.overviewPolyline === 'string') {
            coordinates = decodePolyline(routeObj.overviewPolyline);
        } else if (routeObj.overview_polyline && typeof routeObj.overview_polyline.points === 'string') {
            coordinates = decodePolyline(routeObj.overview_polyline.points);
        } else if (Array.isArray(routeObj.legs) && routeObj.legs.length > 0) {
            var stepCoordinates = [];
            routeObj.legs.forEach(function (leg) {
                if (!leg || !Array.isArray(leg.steps)) {
                    return;
                }
                leg.steps.forEach(function (step) {
                    if (Array.isArray(step.coordinates)) {
                        stepCoordinates = stepCoordinates.concat(normalizeCoordinateList(step.coordinates));
                    } else if (typeof step.polyline === 'string') {
                        stepCoordinates = stepCoordinates.concat(decodePolyline(step.polyline));
                    } else if (step.polyline && typeof step.polyline.points === 'string') {
                        stepCoordinates = stepCoordinates.concat(decodePolyline(step.polyline.points));
                    }
                });
            });
            coordinates = stepCoordinates;
        }

        return {
            distance: Number.isNaN(distance) ? 0 : distance,
            duration: Number.isNaN(duration) ? 0 : duration,
            coordinates: coordinates
        };
    }

    function pickRouteObject(payload) {
        if (payload && payload.result && typeof payload.result === 'object') {
            return payload.result;
        }
        if (payload && Array.isArray(payload.routes) && payload.routes.length > 0) {
            return payload.routes[0];
        }
        var arr = pickFirstArray(payload);
        return arr.length > 0 ? arr[0] : payload;
    }

    function haversineDistanceMeters(lat1, lng1, lat2, lng2) {
        var earthRadius = 6371000;
        var toRad = Math.PI / 180;
        var dLat = (lat2 - lat1) * toRad;
        var dLng = (lng2 - lng1) * toRad;
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
            + Math.cos(lat1 * toRad) * Math.cos(lat2 * toRad)
            * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    function buildStraightLineFallback(originLat, originLng, destLat, destLng) {
        var distance = haversineDistanceMeters(originLat, originLng, destLat, destLng);
        var avgSpeedMps = 8.33; // ~30 km/h for urban fallback estimate
        var duration = Math.max(60, Math.round(distance / avgSpeedMps));
        return {
            distance: distance,
            duration: duration,
            coordinates: [
                [originLat, originLng],
                [destLat, destLng]
            ]
        };
    }

    async function routeViaOsrmFallback(originLat, originLng, destLat, destLng) {
        var osrmUrl = 'https://router.project-osrm.org/route/v1/driving/'
            + originLng + ',' + originLat + ';'
            + destLng + ',' + destLat
            + '?overview=full&geometries=geojson';

        var response = await fetch(osrmUrl, { headers: { 'Accept': 'application/json' } });
        if (!response.ok) {
            throw new Error('osrm-http-' + response.status);
        }

        var payload = await response.json();
        if (!payload || !Array.isArray(payload.routes) || payload.routes.length === 0) {
            throw new Error('osrm-route-empty');
        }

        var firstRoute = payload.routes[0];
        var coords = [];
        if (firstRoute.geometry && Array.isArray(firstRoute.geometry.coordinates)) {
            coords = firstRoute.geometry.coordinates.map(function (pair) {
                return toLatLngPair(pair[1], pair[0]);
            }).filter(Boolean);
        }

        if (!Array.isArray(coords) || coords.length === 0) {
            throw new Error('osrm-route-empty');
        }

        return {
            distance: Number(firstRoute.distance || 0),
            duration: Number(firstRoute.duration || 0),
            coordinates: coords
        };
    }

    async function requestAndNormalizeRoute(originLat, originLng, destLat, destLng, swapOrder) {
        var origin = swapOrder
            ? originLng + ',' + originLat
            : originLat + ',' + originLng;
        var destination = swapOrder
            ? destLng + ',' + destLat
            : destLat + ',' + destLng;

        var payload = await request('sdk/v2/route', {
            origin: origin,
            destination: destination,
            mode: 'car'
        });

        return normalizeRoute(pickRouteObject(payload));
    }

    async function route(originLat, originLng, destLat, destLng) {
        var lat1 = Number(originLat);
        var lng1 = Number(originLng);
        var lat2 = Number(destLat);
        var lng2 = Number(destLng);

        if (Number.isNaN(lat1) || Number.isNaN(lng1) || Number.isNaN(lat2) || Number.isNaN(lng2)) {
            throw new Error('map4d-route-empty');
        }

        var normalized = null;
        var firstError = null;

        try {
            normalized = await requestAndNormalizeRoute(lat1, lng1, lat2, lng2, false);
        } catch (err) {
            firstError = err;
        }

        if (!normalized || !Array.isArray(normalized.coordinates) || normalized.coordinates.length === 0) {
            try {
                normalized = await requestAndNormalizeRoute(lat1, lng1, lat2, lng2, true);
            } catch (err2) {
                if (!firstError) {
                    firstError = err2;
                }
            }
        }

        if (!normalized || !Array.isArray(normalized.coordinates) || normalized.coordinates.length === 0) {
            if (firstError && String(firstError.message || '').indexOf('map4d-http-') === 0) {
                // Keep trying another provider when Map4D endpoint is unreachable.
            }
            try {
                normalized = await routeViaOsrmFallback(lat1, lng1, lat2, lng2);
            } catch (ignoreFallbackError) {
                normalized = null;
            }
        }

        if (!normalized || !Array.isArray(normalized.coordinates) || normalized.coordinates.length === 0) {
            normalized = buildStraightLineFallback(lat1, lng1, lat2, lng2);
        }
        return normalized;
    }

    function messageFromError(error, fallbackMessage) {
        var code = error && error.message ? String(error.message) : '';
        if (code === 'missing-map4d-key') {
            return 'Thiếu cấu hình MAP4D API key. Vui lòng cập nhật web.xml (map4d.api.key).';
        }
        if (code === 'map4d-route-empty') {
            return 'Map4D chưa trả về lộ trình phù hợp cho điểm đã chọn.';
        }
        if (code.indexOf('map4d-http-') === 0) {
            return 'Map4D API tạm thời lỗi (' + code.replace('map4d-http-', 'HTTP ') + '). Vui lòng thử lại sau.';
        }
        return fallbackMessage || 'Có lỗi khi kết nối Map4D. Vui lòng thử lại.';
    }

    global.ClickEatMap4D = {
        request: request,
        geocode: geocode,
        reverse: reverse,
        route: route,
        addBaseTileLayer: addBaseTileLayer,
        messageFromError: messageFromError
    };
})(window);
