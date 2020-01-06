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

## Installation

Download the code bundle and install the files into the collection's conf folder using the following structure

```
$SEARCH_HOME/conf/$COLLECTION_NAME
    /$PROFILE_NAME
         /web
            /js
                handlebars.js
                typeahead.bundle.js
                typeahead.fb.js
            /css
                typeahead.css
```

## Basic setup for a Funnelback template

Step 1. Replace the existing auto-completion imports

Replace:

```html
<script src="${GlobalResourcesPrefix}js/jquery/jquery-1.10.2.min.js"></script>
<script src="${GlobalResourcesPrefix}js/jquery/jquery-ui-1.10.3.custom.min.js"></script>
<script src="${GlobalResourcesPrefix}thirdparty/bootstrap-3.0.0/js/bootstrap.min.js"></script>
<script src="${GlobalResourcesPrefix}js/jquery/jquery.tmpl.min.js"></script>
<script src="${GlobalResourcesPrefix}js/jquery.funnelback-completion.js"></script>
```

With:

```html
<script src="${GlobalResourcesPrefix}js/jquery/jquery-1.10.2.min.js"></script>
<script src="${GlobalResourcesPrefix}thirdparty/bootstrap-3.0.0/js/bootstrap.min.js"></script>

<#-- Standard typeahead and handlebars libraries - required for auto-completion -->
<link rel="stylesheet" type="text/css" href="/s/resources/${question.collection.id}/${question.profile}/css/typeahead.css" />
<script type="text/javascript" src="/s/resources/${question.collection.id}/${question.profile}/js/typeahead.bundle.js"></script>
<script type="text/javascript" src="/s/resources/${question.collection.id}/${question.profile}/js/handlebars.js"></script>
<script type="text/javascript" src="/s/resources/${question.collection.id}/${question.profile}/js/typeahead.fb.js"></script>
```

Step 2. Replace the auto-completion search box setup

The following example replaces the existing jQuery based auto-completion with concierge providing an equivalent organic auto-completion.

Replace:

```html
    // Query completion setup.
    jQuery("input.query").fbcompletion({
      'enabled'    : '<@s.cfg>auto-completion</@s.cfg>',
      'standardCompletionEnabled': <@s.cfg>auto-completion.standard.enabled</@s.cfg>,
      'collection' : '<@s.cfg>collection</@s.cfg>',
      'program'    : '<@s.cfg>auto-completion.program</@s.cfg>',
      'format'     : '<@s.cfg>auto-completion.format</@s.cfg>',
      'alpha'      : '<@s.cfg>auto-completion.alpha</@s.cfg>',
      'show'       : '<@s.cfg>auto-completion.show</@s.cfg>',
      'sort'       : '<@s.cfg>auto-completion.sort</@s.cfg>',
      'length'     : '<@s.cfg>auto-completion.length</@s.cfg>',
      'delay'      : '<@s.cfg>auto-completion.delay</@s.cfg>',
      'profile'    : '${question.inputParameterMap["profile"]!}',
      'query'      : '${QueryString}',
      //Search based completion
      'searchBasedCompletionEnabled': <@s.cfg>auto-completion.search.enabled</@s.cfg>,
      'searchBasedCompletionProgram': '<@s.cfg>auto-completion.search.program</@s.cfg>',
    });
    ```

With:

```html
    jQuery('#query').qc({
        datasets:{
            organic: {
                collection: '<@s.cfg>collection</@s.cfg>',
                profile : '<@s.cfg>auto-completion.profile</@s.cfg>',
                program: '<@s.cfg>auto-completion.program</@s.cfg>',
                alpha: '<@s.cfg>auto-completion.alpha</@s.cfg>',
                show: '<@s.cfg>auto-completion.show</@s.cfg>',
                sort: '<@s.cfg>auto-completion.sort</@s.cfg>',
                length: '<@s.cfg>auto-completion.length</@s.cfg>'
            }
        }
    });
```

## Configuration options

### URL settings

#### dataType <string>

**Description:** The type of data returned by the server. Possible values are:

* **json** - (default) Return auto completion in JSON format
* **jsonp** - Return auto-completion in JSONP format.

**Example:**

```json
dataType: 'jsonp'
```

### Default settings

These settings can be overwritten in general or per completion type (tier).

#### datasets: <[{}, {}, {}]>

**Description:** List of settings defining tiers for concierge auto-completion. Parameters can be defined in general (default settings) or per completion type or per dataset.

**Examples:**

```json
datasets: [
   set1: {profile: 'tier1'},
   set2: {profile: 'tier2'}
]
```

```json
datasets: [
   courses: {
      collection: 'course',
      name: 'courses'
   }, 
   staff : {
       collection: 'staff',
       name: 'people'
   }
]
```

#### defaultCall: <string|[]|{}>

**Description:** Used to trigger auto-completion when input value is focused and empty and parameter length=0. Possible values are:

* `string` - used to set as query to trigger auto-completion
* `[{value: '', label: ''}, {value: '', label: ''}]` - list of hardcoded data to fulfill dropdown menu
* `{data: [], filter: function(completion, data)}` - use filter function to map list of hardocded data
* `{filter: function(completion, data), params: {}, url: ''}` - use filter function to map data loaded from the server using a HTTP GET request by calling URL with given parameters

**Examples:**

```json
defaultCall: 'funnelback'
```

```json
defaultCall: [{value: "CSE", label:"CSE"}, {value: "Engineering", label:"Engineering"}]
```

```json
defaultCall: {
    data: [{title: "CSE", url: 'http://www.cse.unsw.edu.au/'}, {title: "Engineering", url: 'http://www.engineering.unsw.edu.au/'}],
    filter: function(item, data) {
        return jQuery.map(data, function(item, i) { return {value: item.title, label: item.title, extra: {action: item.url, action_t: 'U'}, rank: i + 1}; });
    }
}
```

```json
defaultCall: {
    filter: _processDataTopQueries
    params: {},
    url: ''
}
```

#### filter: <function(completion, suggestion, index)>

**Description:** Filter function used to map response data into a hash. Default filter function is called `_processData` and map:

```json
[{
    "key": "and",
    "disp": "and",
    "disp_t": "T",
    "wt": "5.568",
    "cat": "",
    "cat_t": "",
    "action": "",
    "action_t": "S"
},]
```

into:

```json
[{
    label: 'and'
    value: 'and'
    extra: {
        "key": "and",
        "disp": "and",
        "disp_t": "T",
        "wt": "5.568",
        "cat": "",
        "cat_t": "",
        "action": "",
        "action_t": "S"
    },
    category: 'Suggestions'
    rank: 1
}]
```

**Example:**

```json
filter: _processData
```

### Dataset types

#### organic: <{}>

**Description:** Settings applied to simple auto-completion

**Example:**

```json
dataset: [
    organic: {
        collection: 'mycollection',
        profile: '_default',        
        name: 'organic'
    }
]
```

#### <dataset_name>: <{}>

**Description:** Used to define a non-organic dataset

**Example:**

```json
dataset: [
    mycustomdataset: {
        collection: 'mycollection',
        profile: 'auto-completion',
        name: 'My dataset'
    }
]
```

### Dataset settings

Note: most of these data set settings can be set at the global level to apply to all auto-completion.

#### collection: <string>

**Description:** The ID of the collection.

**Example:**

```json
collection: 'my-collection'
```

#### profile: <string>

**Description:** Name of a profile

**Default:**

```json
profile: '_default'
```

**Example:**

```json
profile: 'auto-completion'
```

#### format: <string>

**Description:** This parameter sets the display format of the suggestions in the search results page. Possible values are:

* `extended` - Allow display of complex suggestions (HTML content, Javascript callbacks, etc.), and complex actions when a selection is selected (Run a query, open an URL, call a Javascript function, etc.)

**Source:** https://docs.funnelback.com/query_completion_format_collection_cfg.html

**Example:**

```json
format: 'extended'
```

#### itemLabel: <string|function(suggestion)>

**Description:** Name of a field to be displayed as label in input field and for default template in dropdown menu.

The function must be defined to return the suggestion if using a JSON suggestion, otherwise [Object Object] will be displayed as the description

**Examples:**

```json
itemLabel: 'label'
```

```json
itemLabel: 'label.title'
```

```json
itemLabel: function(suggestion) {
    return suggestion.label.firstname + " " + suggestion.label.lastname;
}
```

Display correct label for group when customised label for suggestion

```json
itemLabel: function(suggestion) {
    return suggestion.label.title ? suggestion.label.title : suggestion.label;
}
```

#### program: <string>

**Description:** This parameter sets the program to use to generate auto-completion suggestions.

**source:** https://docs.funnelback.com/query_completion_program_collection_cfg.html

**Default:**

```json
program: 'suggest.json'
```

**Example:**

```json
program: 'search.html'
```

#### show: <integer>

**Description:** Maximum number of suggestions to display in dropdown menu.

**Default:**

```json
show: 10
```

**Example:**

```json
show: 5
```

#### sort: <integer>

**Description:** This parameter sets the auto-completion suggestions sort order. It can take 3 values:

* `0` – Suggestions will be sorted by score, with the most relevant ones in first.
* `1` – Suggestions will be sorted by length, with the shorter ones in first.
* `2` – Suggestions will be sorted alphabetically in ascending order.

**Source:** https://docs.funnelback.com/query_completion_sort_collection_cfg.html

**Default:**

```json
sort: 0
```

**Example:**

```json
sort: 2
```

#### template: <{}>

**Description:** A hash of templates to be used when rendering the dataset. Note a precompiled template is a function that takes a JavaScript object as its first argument and returns a HTML string.

* `notFound` - Rendered when 0 suggestions are available for the given query. Can be either a HTML string or a precompiled template. If it's a precompiled template, the passed in context will contain query.
* `pending` - Rendered when 0 synchronous suggestions are available but asynchronous suggestions are expected. Can be either a HTML string or a precompiled template. If it's a precompiled template, the passed in context will contain query.
* `header` - Rendered at the top of the dataset when suggestions are present. Can be either a HTML string or a precompiled template. If it's a precompiled template, the passed in context will contain query and suggestions.
* `footer` - Rendered at the bottom of the dataset when suggestions are present. Can be either a HTML string or a precompiled template. If it's a precompiled template, the passed in context will contain query and suggestions.
* `suggestion` - Used to render a single suggestion. If set, this has to be a precompiled template. The associated suggestion object will serve as the context. Defaults to the value of display wrapped in a div tag i.e.<div>{{value}}</div>.
** :warning: When using with HTML completions, this template needs to be set to a function that will inject the completion as HTML: `suggestion: function(data) { return $('<span>').html(data.extra.disp); }`. If this is skipped the HTML snippet of the completion will be inserted as text instead and be displayed as-is.

**Source:** https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md#datasets

**Example:**

```json
template: {
    header: $('<h4>').text('Category name').addClass('tt-category'),
    suggestion: $('<div>').text('{{extra.disp.title}}'),
    notFound: $('<div>').html('<em>No suggestions found</em>')
}
```

Display different header for empty and non-empty query

```json
template: {
    header: function(context) {
        return $('<h4>').text(context.query ? 'Suggestions' : 'Quick Links').addClass('tt-category');
    }
}
```

#### templateHeader: <string>

**Description:** Default template to display category header when concierge auto-completion is enabled. Value of parameter requires to contain substring '{{category}}'.

**Example:**

```json
templateHeader: '<h5 class="tt-category">{{category}}</h5>'
```

#### templateMerge: <boolean>

**Description:** If true, wrap notFound and pending template with header and footer templates.

**Example:**

```json
templateMerge: true
```

#### group: <boolean>

**Description:** Group structured suggestions by their category field.

**Example:**

```json
group: true
```

#### groupOrder: <[]>

**Description:** Defines the order that groups are displayed.

**Example:**

```json
groupOrder: ['Forms', 'Policies', 'News']
```

#### wildcard: <string>

**Description:** A value to be replaced in URL with the URI encoded query.

**Source:** https://github.com/twitter/typeahead.js/blob/master/doc/bloodhound.md#remote

**Example:**

```json
wildcard: '%QUERY'
```

#### name: <string>

**Description:** The name of the completion type. This will be appended to {{classNames.dataset}}- to form the class name of the containing DOM element. Must only consist of underscores, dashes, letters (a-z), and numbers. Defaults to a random number.

**Source:** https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md#datasets

**Examples:**

```json
dataset: [
    organic: {
        name: 'organic'
    }
]
```

```json
dataset: [
    organic: {
        name: 'Suggestions'
    },
    people: {
        name: 'People'
    }
]
```

#### length: <integer>

**Description:** The minimum character length typed in input field to trigger auto-completion.

**Example:**

```json
length: 3
```

### Display settings

#### horizontal: <boolean>

**Description:** This parameter displays tiers in columns when set true, else as a list one below the other.

To change the width of dropdown menu modify file css/typeahead.css and set CSS min-width property for class 'tt-horizontal'

`css/typeahead.css`

```css
.tt-horizontal {min-width: 700px;}
```

To change the width of column modify file css/typeahead.css and set CSS width property for class 'tt-dataset'

`css/typeahead.css`

```css
.tt-horizontal .tt-dataset {width: 33.3%;}
```

**Examples:**

```json
horizontal: true
```

#### scrollable: <boolean>

**Description:** Limit height of a menu dropdown to maximum height defined as CSS style. If the height of menu dropdown is bigger than defined value, the vertical scroll will be displayed.

To change maximum height modify file css/typeahead.css and set up CSS 'max-height' property for class 'tt-scrollable'

`css/typeahead.css`

```css
.tt-scrollable {max-height: 460px;} 
```

**Example:**

```css
scrollable: true
```

### Typeahead settings

#### typeahead: <{}>

**Description:** Typeahead settings

**Example:**

```json
typeahead: {
    classNames: {},
    highlight: true,
    hint: false
}
```

#### typeahead.classNames: <{}>

**Description:** Provides options to override default Typeahead classes:

* input - Added to input that's initialized into a typeahead. Defaults to tt-input.
* hint - Added to hint input. Defaults to tt-hint.
* menu -Added to menu element. Defaults to tt-menu.
* dataset -Added to dataset elements. to Defaults to tt-dataset.
* suggestion -Added to suggestion elements. Defaults to tt-suggestion.
* empty -Added to menu element when it contains no content. Defaults to tt-empty.
* open -Added to menu element when it is opened. Defaults to tt-open.
* cursor -Added to suggestion element when menu cursor moves to said suggestion. Defaults to tt-cursor.
* highlight -Added to the element that wraps highlighted text. Defaults to tt-highlight.

**Source:** https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md#class-names

**Example:**

```json
typeahead: {
    classNames: {
        input: 'Typeahead-input',
        hint: 'Typeahead-hint',
        selectable: 'Typeahead-selectable'
    }
}
```

#### typeahead.highlight: <boolean>

**Description:** When suggestions are rendered, pattern matches for the current query in text nodes will be wrapped in a strong element with its class set to {{classNames.highlight}}

**Example:**

```json
typeahead: {
    highlight: false
}
```

#### typeahead.hint: <boolean>

**Description:** Allows to show a hint in input field. To change hint style modify file css/typeahead.css and set up CSS properties for class 'tt-hint'

`css/typeahead.css`

```css
.tt-hint {color: #ccc;}
```

**Example:**

```json
typeahead: {
    hint: true
}
```

#### typeahead.events: <{}>

**Description:** Allows to apply events triggered on the input element during the life-cycle of a Typeahead:

* active - Fired when the typeahead moves to active state.
* idle - Fired when the typeahead moves to idle state.
* open - Fired when the results container is opened.
* close - Fired when the results container is closed.
* change - Normalized version of the native change event. Fired when input loses focus and the value has changed since it originally received focus.
* render - Fired when suggestions are rendered for a dataset. The event handler will be invoked with 4 arguments: the jQuery event object, the suggestions that were rendered, a flag indicating whether the suggestions were fetched asynchronously, and the name of the dataset the rendering occurred in.
* select - Fired when a suggestion is selected. The event handler will be invoked with 2 arguments: the jQuery event object and the suggestion object that was selected.
* autocomplete - Fired when a autocompletion occurs. The event handler will be invoked with 2 arguments: the jQuery event object and the suggestion object that was used for autocompletion.
* cursorchange - Fired when the results container cursor moves. The event handler will be invoked with 2 arguments: the jQuery event object and the suggestion object that was moved to.
* asyncrequest - Fired when an async request for suggestions is sent. The event handler will be invoked with 3 arguments: the jQuery event object, the current query, and the name of the dataset the async request belongs to.
* asynccancel - Fired when an async request is cancelled. The event handler will be invoked with 3 arguments: the jQuery event object, the current query, and the name of the dataset the async request belonged to.
* asyncreceive - Fired when an async request completes. The event handler will be invoked with 3 arguments: the jQuery event object, the current query, and the name of the dataset the async request belongs to.

**Source:** https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md#custom-events

**Example:**

```json
typeahead: {
    events: {
        select: function(event, suggestion) {
            this.itemSelect(suggestion);
        }
    }
}
```

### Mapping data functions

#### Default mapping function

**Description:** Function that maps the extended suggest.json response, mapping the additional JSON fields into the suggestion object.

**Function:**

```javascript
function _processData(completion, suggestion, i) {
    return {
      label    : (suggestion.disp) ? suggestion.disp : suggestion.key,
      value    : (suggestion.action_t == 'Q') ? suggestion.action : suggestion.key,
      extra    : suggestion,
      category : suggestion.cat ? suggestion.cat : completion.category,
      rank     : i + 1
    };
}
```

**Input:**

```json
[{
"key": "and",
"disp": "and",
"disp_t": "T",
"wt": "5.568",
"cat": "",
"cat_t": "",
"action": "",
"action_t": "S"
},
{
"key": "are",
"disp": "are",
"disp_t": "T",
"wt": "5.477",
"cat": "",
"cat_t": "",
"action": "",
"action_t": "S"
}]
```

**Output:**

```json
[{
label: "and",
value: "and",
extra: {
    "key": "and",
    "disp": "and",
    "disp_t": "T",
    "wt": "5.568",
    "cat": "",
    "cat_t": "",
    "action": "",
    "action_t": "S"
    },
category: "",
rank: 1
},
{
label: "are",
value: "are",
extra: {
    "key": "are",
    "disp": "are",
    "disp_t": "T",
    "wt": "5.477",
    "cat": "",
    "cat_t": "",
    "action": "",
    "action_t": "S"
    },
category: "",
rank: 2
}]
```

## Dependencies

The following third party code is used for this implementation:

* jQuery
* [Twitter Typeahead](http://twitter.github.io/typeahead.js/)
* Bloodhound - Typeahead.js engine, manages pre-fetching, caching, etc
* Handlebars - JS templating

# Working demonstration

* [Autocompletion showcase demo](http://showcase.funnelback.com/s/search.html?collection=showcase-autocompletion)