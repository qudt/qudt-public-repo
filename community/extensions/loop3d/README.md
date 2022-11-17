# Loop3D Community

This folder contains a _profile_ of QUDT which is a part view of the whole created for the [Loop3D](https://loop3d.org/) community. 

The _profile_ is a specification formulated according to [the W3C's Profiles Vocabulary](https://w3c.github.io/dx-prof/prof/) which contains potentially many parts. This particular profile only contains one part currently: a vocbaulary of units used by the Loop3D cmmunity. In the future, this profile may be expanded, perhaps with more vocabularies (e.g. of QuantityKinds) or perhaps with supporting assets such as documentation (e.g. about appropriate use of QUDT for Looop3D purposed) or other things.

The current profile elements are stored as files in this repository folder but should be accessed or refered to by their QUDT web addresses (persistent identifiers):

* the Loop3D profile - <http://qudt.org/community/loop3d>
    * the units vocabulary - <http://qudt.org/community/loop3d/voc>

### Profile technical access

Those elements can be accessed in _Linked Data_ forms via their web addresses too, i.e. as HTML web pages for humans (the default) or RDF documents for machines. _Content Negotiation_ can be used to get the RDF forms, for example a `curl` (command line program) request like this for the vocabulary in the _Turtle_ RDF format:

```bash
curl -L -H 'Accept: text/turtle' http://qudt.org/community/loop3d/voc
```


## Contact

The Loop3D community can be reached via the contributor of this profile:

**Nicholas J. Car**  
*Data Systems Architect*  
SURROUND Australia Pty Ltd
<nicholas.car@surroundaustralia.com>  
GitHub: @nicholascar  
