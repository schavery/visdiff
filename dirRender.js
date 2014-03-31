// javascript
// render pages in folder

var page = require('webpage').create(), loadInProgress = false, fs = require('fs');
var htmlFiles = new Array();
console.log(fs.workingDirectory);
var curdir = fs.list(fs.workingDirectory);

// loop through files and folders
for(var i = 0; i< curdir.length; i++)
{
    var fullpath = fs.workingDirectory + fs.separator + curdir[i];
    // check if item is a file
    if(fs.isFile(fullpath))
    {
        // check that file is html
        if(fullpath.indexOf('.html') != -1)
        {
            // show full path of file
            console.log('File path: ' + fullpath);
            htmlFiles.push(fullpath);
        }
    }
}

console.log('Number of Html Files: ' + htmlFiles.length);

// output pages as PNG
var pageindex = 0;

var interval = setInterval(function() {
    if (!loadInProgress && pageindex < htmlFiles.length) {
        console.log("image " + (pageindex + 1));
        page.open(htmlFiles[pageindex]);
    }
    if (pageindex == htmlFiles.length) {
        console.log("image render complete!");
        phantom.exit();
    }
}, 250); // probably too long for local files, esp. if the resources are local

page.onLoadStarted = function() {
    loadInProgress = true;
    console.log('page ' + (pageindex + 1) + ' load started');
    page.viewportSize = { width: 1920, height: 1800 };
};

page.onLoadFinished = function() {
    loadInProgress = false;

    page.render("images/output" + (pageindex + 1) + ".png");
    console.log('page ' + (pageindex + 1) + ' load finished');
    pageindex++;
}