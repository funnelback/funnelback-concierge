# Introduction

**This is only applicable to Funnelback 15.10 and earlier.  Funnelback 15.12 and newer should use the supported Concierge auto-completion code which provides all the functionality detailed here.**

This code implements next-generation auto-completion functionality for Funnelback and is designed to replace the jQuery UI-based funnelback-completion.js that ships with Funnelback.

The concierge implementation is based on Twitter Typeahead, Handlebars and Bloodhound and provides a rich auto-completion feature set.

Features include:

* Support for multiple auto-completion sources
* Supported auto-completion sources:
  * simple (organic)
  * structured (rich) - based off CSV
  * faceted
  * search-based
* Various display options including multi-column support
* Each source can be independently configured and templated
* Simplified integration with existing websites

# Usage and installation

* [Installation instructions and documentation](https://github.com/funnelback/funnelback-concierge/wiki/Documentation)

# Working demonstration

* [Autocompletion showcase demo](http://showcase.funnelback.com/s/search.html?collection=showcase-autocompletion)