//js cookbook/scripts/doc.js

load('steal/rhino/steal.js');
steal.plugins("documentjs").then(function(){
	DocumentJS('dreamcatcher/dreamcatcher.html');
});