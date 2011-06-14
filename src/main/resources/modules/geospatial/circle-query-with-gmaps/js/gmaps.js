var map;
var markers = [];
var infoWindow;
var locationSelect;
//kill this?
var milesRadius = 0.3;

function init() {
    /* initial setup */
    var myOptions = {
        zoom: 13, mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map"), myOptions);
    infoWindow = new google.maps.InfoWindow();
    
    /* prepare feed */
    
    downloadUrl(searchUrl, function (data) {
        var xml = parseXml(data);
        var markerNodes = xml.documentElement.getElementsByTagName("Marker");
        var bounds = new google.maps.LatLngBounds();
        
        for (var i = 0; i < markerNodes.length; i++) {
            var name = markerNodes[i].getAttribute("name");
            var address = markerNodes[i].getAttribute("address");
            //var distance = parseFloat(markerNodes[i].getAttribute("distance"));
            var latlng = new google.maps.LatLng(
            parseFloat(markerNodes[i].getAttribute("lat")),
            parseFloat(markerNodes[i].getAttribute("lng")));
            var marker = createMarker(latlng, name, address);
            bounds.extend(latlng);
            
            if (i === 0){
            	generateCircle(marker);
        	}
        }
        
        map.fitBounds(bounds);
    });
}

function generateCircle(marker){
    var circle = new google.maps.Circle({
        map: map,
        // 0.1 mile = 1609.344m
        radius: (milesRadius * 1610)
    });
    circle.bindTo('center', markers[0], 'position');
}

function createMarker(latlng, name, address) {
    // console.log(latlng, name, address)
    var html = "<b>" + name + "</b> <br/>" + address;
    var marker = new google.maps.Marker({
        map: map,
        position: latlng,
		animation:google.maps.Animation.DROP
    });
    google.maps.event.addListener(marker, 'click', function () {
        infoWindow.setContent(html);
        infoWindow.open(map, marker);
    });
    markers.push(marker);
}

function downloadUrl(url, callback) {
    var request = window.ActiveXObject?
    new ActiveXObject('Microsoft.XMLHTTP'):
    new XMLHttpRequest;
    
    request.onreadystatechange = function () {
        if (request.readyState == 4) {
            request.onreadystatechange = doNothing;
            callback(request.responseText, request.status);
        }
    };
    
    request.open('GET', url, true);
    request.send(null);
}

function parseXml(str) {
    if (window.ActiveXObject) {
        var doc = new ActiveXObject('Microsoft.XMLDOM');
        doc.loadXML(str);
        return doc;
    } else if (window.DOMParser) {
        return (new DOMParser).parseFromString(str, 'text/xml');
    }
}

function doNothing() {
}