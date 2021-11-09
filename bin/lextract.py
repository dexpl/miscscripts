# Many thanks to https://stackoverflow.com/a/63754566
from __future__ import print_function
import sys
import re

try:
    from html.parser import HTMLParser
except ImportError:
    from HTMLParser import HTMLParser

try:
    import urllib.request as rq
except ImportError:
    import urllib as rq

class LinkScrape(HTMLParser):

    def handle_starttag(self, tag, attrs):
        [print(re.sub(r_what, r_with, link)) for link in [v if v.find('http') == 0 else baseurl + v for k, v in attrs if k == 'href' if tag == 'a'] if re.search(regex, link)]

if __name__ == '__main__':
    try:
        url = sys.argv[1]
        regex = sys.argv[2] if len(sys.argv) > 2 else '.'
        try:
            r_what = sys.argv[3]
            r_with = sys.argv[4]
        except IndexError:
            r_what = r_with = ''
        baseurl = '/'.join(url.split('/')[0:3])
        LinkScrape().feed(rq.urlopen(url).read().decode('utf-8'))
    except IndexError:
        # TODO read stdin
        print('Usage: %s URL [regex]' % sys.argv[0], file=sys.stderr)
