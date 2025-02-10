As mentioned in Release 2.1.47, we are coming out with version 3.0.0 with this Release. This could be a breaking change for your applications, since some of you may be using the versioned graph URIs that include  "2.1". Moving forward, those will include "3.0.x", but of course the un-versioned graphs will always resolve to the latest version. So, for example, if you use the owl:imports mechanism, your application could import http://qudt.org/2.1/vocab/unit if you want to stay with 2.1, http://qudt.org/3.0/vocab/unit if you want to explicitly migrate to the new Release, or http://qudt.org/vocab/unit if you want to always get the latest Release.

In Release 3.0, we are removing all the deprecated entities that have accumulated to date. They all contain the triple:

\<entity\> qudt:deprecated true
