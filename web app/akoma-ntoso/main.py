import webapp2
import os
import re
import urllib2
from lxml import etree
from datetime import date

us_url_pattern = re.compile('^(https?:\/\/)?www\.gpo\.gov\/fdsys\/pkg\/(.+)\/(html|xml|pdf)\/.+\.(htm|xml|pdf)$')
with open(os.path.dirname(__file__) + '/usfix.xsl') as file:
    us_fix = etree.XSLT(etree.parse(file))
with open(os.path.dirname(__file__) + '/us2an.xsl') as file:
    us_transform = etree.XSLT(etree.parse(file))

uk_url_pattern = re.compile('^(http:\/\/)?data\.parliament\.uk\/resources\/UK_Parliament_Bill_Data\/(.+)\/(.+)\.mif\.xml$')
with open(os.path.dirname(__file__) + '/ukfix.xsl') as file:
    uk_fix = etree.XSLT(etree.parse(file))
with open(os.path.dirname(__file__) + '/uk2an.xsl') as file:
    uk_transform = etree.XSLT(etree.parse(file))

with open(os.path.dirname(__file__) + '/index.html') as file:
    homepage = file.read()

class MainHandler(webapp2.RequestHandler):

    def convert(self, source_url, fix, transform, stylesheet):
        try:
            source_file = urllib2.urlopen(source_url)
        except urllib2.HTTPError as exception:
            self.abort(400, 'source file not found')
        source = etree.parse(source_file)
        fixed = fix(source)
        today = "'" + date.today().isoformat() + "'"
        if self.request.GET.get('style', 'false') != 'false':
            stylesheet = "'" + stylesheet + "'"
            result = transform(fixed, today=today, stylesheet=stylesheet)
        else:
            result = transform(fixed, today=today)
        indent = self.request.GET.get('indent', 'false') != 'false'
        self.response.content_type = 'text/xml'
        result.write(self.response, encoding = 'utf-8', xml_declaration=True, pretty_print=indent)

    def get(self):
        url_param = self.request.GET.get('source')
        if url_param is None:
            self.response.write(homepage)
        elif us_url_pattern.match(url_param) is not None:
            match = us_url_pattern.match(url_param)
            source_url = 'http://www.gpo.gov/fdsys/pkg/' + match.group(2) + '/xml/' + match.group(2) + '.xml'
            self.convert(source_url, us_fix, us_transform, 'usan.css')
        elif uk_url_pattern.match(url_param) is not None:
            match = uk_url_pattern.match(url_param)
            source_url = 'http://data.parliament.uk/resources/UK_Parliament_Bill_Data/' + match.group(2) + '/' + match.group(3) + '.mif.xml'
            self.convert(source_url, uk_fix, uk_transform, 'ukan.css')
        else:
            self.abort(400, 'unsupported source url')

    def handle_exception(self, exception, debug):
        self.response.set_status(exception.code if isinstance(exception, webapp2.HTTPException) else 500)
        self.response.content_type = 'text/plain'
        self.response.write(str(exception))

app = webapp2.WSGIApplication([('/', MainHandler)], debug=True)
