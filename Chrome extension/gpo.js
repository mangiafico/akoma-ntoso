var td = document.querySelectorAll("table[class='page-details-budget-metadata-table'] > tbody > tr > td")[1];
var sizeNode = td.lastChild.cloneNode();
td.appendChild(document.createTextNode(" | "));
var link = document.createElement('a');
var xmlLink = td.lastElementChild.getAttribute('href');
link.setAttribute('href', '#');
link.appendChild(document.createTextNode("Akoma Ntoso"));
td.appendChild(link);
td.appendChild(sizeNode);
link.addEventListener('click', function(e) {
	chrome.runtime.sendMessage(null, xmlLink); e.preventDefault();
}, false);
