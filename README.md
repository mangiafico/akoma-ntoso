Akoma Ntoso Converter is a set of simple tools for converting US and UK legislative documents to the Akoma Ntoso document format. The conversions are defined as XSL transforms and may be performed by any of the many widely available XSLT processors. XSLT is a mature technology upon which it is easy to build both server-side and client-side applications. I have included a couple such applications by way of example.

### Web app

The included web application, an instance of which is running at [akoma-ntoso.appspot.com](http://akoma-ntoso.appspot.com), converts documents to Akoma Ntoso in response to common HTTP requests. Visit the app with a web browser, enter the URL of the source XML into the form, and the app responds with an Akoma Ntoso representation of the source document. Requests can even be made without a browser by passing the source document's URL directly as the "source" parameter, e.g.,

* http://akoma-ntoso.appspot.com/?source=www.gpo.gov/fdsys/pkg/BILLS-112hconres83eh/xml/BILLS-112hconres83eh.xml
* http://akoma-ntoso.appspot.com/?source=data.parliament.uk/resources/UK\_Parliament\_Bill\_Data/Wild\_Animals\_Bill/hc036wildanimalsbook.mif.xml

Including an "indent" parameter with the value of "true" (by appending `&indent=true` to the URL) indents or "pretty prints" the output. Appending `&style=true` produces a document with a stylesheet instruction, allowing the Akoma Ntoso document to approximate the appearance of its original when viewed with a modern web browser.

### Chrome extension

Also included is an extension for Google's Chrome browser, which converts documents to Akoma Ntoso directly within the browser. The extension can be installed from the included source files by following  [thsee instructions](http://developer.chrome.com/extensions/getstarted.html#unpacked) or [downloaded from the Chrome Web Store](https://chrome.google.com/webstore/detail/enobdkimiadjdaphjbjegihkganhkimj).

With the extension installed:

1. Navigate to the source page of any US document on the GPO's [Federal Digital System website](http://www.gpo.gov/fdsys/search/home.action) or any UK document on data.parliament.uk, e.g., http://www.gpo.gov/fdsys/pkg/BILLS-112hconres83eh/xml/BILLS-112hconres83eh.xml, or http://data.parliament.uk/resources/UK\_Parliament\_Bill\_Data/Wild\_Animals\_Bill/hc036wildanimalsbook.mif.xml.
2. A button with the Akoma Ntoso logo will appear at the right of the address bar.
3. Click the button, and the converted document appears in the window.

In addition, the extension adds links to Akoma Ntoso formatted documents within document overview pages on the GPO's website, e.g., http://www.gpo.gov/fdsys/pkg/BILLS-112hconres83eh/content-detail.html.

Once the Akoma Ntoso document appears, you may save it to your computer and use it as you wish. To view a styled version of the document, right click anywhere in the browser window and choose "Show style" from the context menu.

### Other XSLT processors

Converting document to Akoma Ntoso with the included XSL transforms does not require a custom application like the above and can be done manually by any XSLT processor.

Each conversion requires two passes: the first to correct errors and irregularities in the source file and the second to effect the conversion to Akoma Ntoso. The first step is necessary because the source documents are in formats considerably more permissive than Akoma Ntoso. (See the discussion in the included documentation of errors and other irregularities in the source documents.) Although a single XSLT file could be written to perform both steps together, I chose to separate the concerns for the sake of code clarity and maintainability.

Included are four XSLT files: usfix.xsl, us2an.xsl, ukfix.xsl & uk2an.xsl. Converting a US document requires first transforming it with usfix.xsl and then transforming the result with us2an.xsl. Similarly, UK documents should be processed first with ukfix.xsl and then with uk2an.xsl.
