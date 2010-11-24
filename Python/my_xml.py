from xml.dom.ext.reader import Sax2

def node_text(node):
    text = u''
    for c in node.childNodes:
        if c.nodeType == 3:
            text = text + c.nodeValue
    return text
