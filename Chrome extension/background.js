var usre = /^https?:\/\/www\.gpo\.gov(:\d+)?\/fdsys\/pkg\/(.+)\/(html|xml|pdf)\/.+\.(htm|xml|pdf)$/;
var ukre = /^http:\/\/data\.parliament\.uk\/resources\/UK_Parliament_Bill_Data\/(.+)\/(.+)\.mif\.xml$/;

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
	if (usre.test(tab.url) || ukre.test(tab.url))
		chrome.pageAction.show(tabId);
	else
		chrome.pageAction.hide(tabId);
});

var usFix = new XSLTProcessor();
var usTransform = new XSLTProcessor();
(function() {
	var request = new XMLHttpRequest();
	request.open("GET", chrome.extension.getURL('usfix.xsl'), false);
	request.send(null);
	usFix.importStylesheet(request.responseXML);
	request = new XMLHttpRequest();
	request.open("GET", chrome.extension.getURL('us2an.xsl'), false);
	request.send(null);
	usTransform.importStylesheet(request.responseXML);
	usTransform.setParameter(null, 'today', (new Date()).toISOString().substr(0,10));
})();

var ukFix = new XSLTProcessor();
var ukTransform = new XSLTProcessor();
(function() {
	var request = new XMLHttpRequest();
	request.open("GET", chrome.extension.getURL('ukfix.xsl'), false);
	request.send(null);
	ukFix.importStylesheet(request.responseXML);
	request = new XMLHttpRequest();
	request.open("GET", chrome.extension.getURL('uk2an.xsl'), false);
	request.send(null);
	ukTransform.importStylesheet(request.responseXML);
	ukTransform.setParameter(null, 'today', (new Date()).toISOString().substr(0,10));
})();

function getXML(url, callback) {
	var request = new XMLHttpRequest();
	request.open("GET", url, false);
    request.send(null);
    callback(request.responseXML);
}
function saveBlob(blob, filename, callback) {
	window.webkitRequestFileSystem(window.TEMPORARY, 5*1024*1024, function(fs) {
		fs.root.getFile(filename, {create: true, exclusive: false}, function(fileEntry) {
			fileEntry.createWriter(function(fileWriter) {
				var truncated = false;
				fileWriter.onwriteend = function(e) {
					if (truncated) {
						callback(fileEntry.toURL());
					} else {
						truncated = true;
						this.truncate(this.position);
					}
				};
				fileWriter.write(blob);
			});
		});
	});
}
function saveXML(xmlDocument, filename, callback) {
	var blob = new Blob([(new XMLSerializer()).serializeToString(xmlDocument)], {type: 'text/xml'});
	saveBlob(blob, filename, callback);
}

function convertAndSave(sourceUrl, callback) {
	var filename;
	if (usre.test(sourceUrl)) {
		filename = usre.exec(sourceUrl)[2];
		sourceUrl = "http://www.gpo.gov/fdsys/pkg/" + filename + "/xml/" + filename + ".xml";
		getXML(sourceUrl, function(source) {
			var fixed = usFix.transformToDocument(source);
			var result = usTransform.transformToDocument(fixed);

			// documents created with XSLTProcessor are not given XML declarations by WebKit's XMLSerializer
			var pi = result.createProcessingInstruction('xml', 'version="1.0" encoding="utf-8"');
			result.insertBefore(pi, result.firstChild);

			saveXML(result, filename.substring(6) + '.akn.xml', callback);
		});
	} else {
		var billname = ukre.exec(sourceUrl)[1];
		filename = ukre.exec(sourceUrl)[2];
		sourceUrl = "http://data.parliament.uk/resources/UK_Parliament_Bill_Data/" + billname + "/" + filename + ".mif.xml";
		getXML(sourceUrl, function(source) {
			var fixed = ukFix.transformToDocument(source);
			var result = ukTransform.transformToDocument(fixed);
			var pi = result.createProcessingInstruction('xml', 'version="1.0" encoding="utf-8"');
			result.insertBefore(pi, result.firstChild);
			saveXML(result, filename + '.akn.xml', callback);
		});
	}
}

chrome.pageAction.onClicked.addListener(function(tab) {
	convertAndSave(tab.url, function(fileUrl) { chrome.tabs.update(tab.id, {url: fileUrl}); });
});

chrome.contextMenus.create({
	id: 'convert',
	title: 'Convert to Akoma Ntoso',
	documentUrlPatterns: [
		'http://www.gpo.gov/fdsys/pkg/*/*/*.xml',
		'https://www.gpo.gov/fdsys/pkg/*/*/*.xml',
		'http://data.parliament.uk/resources/UK_Parliament_Bill_Data/*/*.mif.xml'
	]
});

chrome.contextMenus.create({
	id: 'show-style',
	title: 'Show style',
	documentUrlPatterns: ['chrome-extension://' + chrome.runtime.id + '/temporary/*.akn.xml']
});

chrome.contextMenus.onClicked.addListener(function(info, tab) {
	if (info.menuItemId == 'convert') {
		convertAndSave(tab.url, function(fileUrl) { chrome.tabs.update(tab.id, {url: fileUrl}); });
	} else if (info.menuItemId == 'show-style') {
		getXML(tab.url, function(doc) {
			var country = doc.querySelector('FRBRWork > FRBRthis').getAttribute('value').split('/',2)[1];
			var stylesheet = country == 'us' ? 'usan.css' : 'ukan.css';
			var pi = doc.createProcessingInstruction('xml-stylesheet', 'type="text/css" href="' + chrome.extension.getURL(stylesheet) + '"');
			doc.insertBefore(pi, doc.firstChild);
			var filename = tab.url.substring(tab.url.lastIndexOf('/'), tab.url.length - 8);
			saveXML(doc, filename + '.akn.style.xml', function(fileUrl) { chrome.tabs.update(tab.id, {url: fileUrl}); });
		});
	}
});

chrome.runtime.onMessage.addListener(function(xmlUrl) {
	console.log(xmlUrl);
	convertAndSave(xmlUrl, function(fileUrl) { chrome.tabs.create({url: fileUrl}); });
});
